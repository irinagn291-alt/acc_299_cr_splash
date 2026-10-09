import Combine
import Foundation

/// The only seam between the roll and storage. Views talk to this type, not to UserDefaults or files.
@MainActor
final class PerchStore: ObservableObject {
    static let chartKey = "psl.chart.v1"
    static let demoKey = "psl.demo.v1"

    @Published private(set) var chart: PerchChart
    @Published private(set) var recoveryNote: String?
    @Published private(set) var lastEffect: RollEffect?

    private let defaults: UserDefaults
    private let disk: ChartDisk
    private let photos: GapPhotoStore
    private let calendar: Calendar
    private let allowsDemoSeed: Bool
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var saveTask: Task<Void, Never>?
    private var boot: Task<Void, Never>?
    private var generation = 0

    init(
        defaults: UserDefaults = .standard,
        directory: URL? = nil,
        calendar: Calendar = .current,
        allowsDemoSeed: Bool = true
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.allowsDemoSeed = allowsDemoSeed
        let root = directory ?? PerchStore.supportDirectory()
        self.disk = ChartDisk(fileURL: root.appendingPathComponent("chart.json"))
        self.photos = GapPhotoStore(root: root.appendingPathComponent("gaps", isDirectory: true))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
        self.chart = .empty
        boot = Task { await self.load() }
    }

    func waitUntilReady() async {
        await boot?.value
    }

    func reload() async {
        recoveryNote = nil
        await load()
    }

    var daykey: Int { Daykey.make(Date(), calendar: calendar) }

    func flock() -> Flock { RollFold.flock(chart, daykey: daykey) }

    func scan(payload: String) {
        lastEffect = RollFold.scan(&chart, payload: payload, daykey: daykey)
        if lastEffect != .bare { scheduleSave() }
    }

    func tapPresent(birdID: UUID) {
        lastEffect = RollFold.tapPresent(&chart, birdID: birdID, daykey: daykey, calendar: calendar)
        if case .manualThenPresent = lastEffect { scheduleSave() }
    }

    func snapGap(note: String, jpeg: Data) async {
        let name = UUID().uuidString + ".jpg"
        do {
            let file = try await photos.writeJPEG(jpeg, fileName: name)
            lastEffect = RollFold.snapGap(&chart, daykey: daykey, note: note, photoFile: file)
            if case .gap = lastEffect { scheduleSave() }
        } catch {
            recoveryNote = "The gap photo could not be saved. Photograph the empty perch again."
            lastEffect = RollFold.markHollow(chart: &chart, daykey: daykey)
            scheduleSave()
        }
    }

    func gapWithoutSnap() {
        lastEffect = RollFold.markHollow(chart: &chart, daykey: daykey)
        scheduleSave()
    }

    func seal() {
        lastEffect = RollFold.seal(&chart, daykey: daykey)
        scheduleSave()
    }

    func peel() {
        lastEffect = RollFold.peel(&chart, daykey: daykey)
        scheduleSave()
    }

    func bandBird(name: String, code: String) {
        let bird = chart.books.band(name: name, code: code, daykey: daykey)
        chart.islands.append(bird)
        scheduleSave()
    }

    func retire(birdID: UUID) {
        chart.books.retire(birdID, daykey: daykey)
        if let index = chart.islands.firstIndex(where: { $0.id == birdID }) {
            chart.islands[index].retiredOn = daykey
        }
        scheduleSave()
    }

    func completeOnboarding() {
        chart.onboardingComplete = true
        scheduleSave()
    }

    func scheduleSave() {
        generation += 1
        let token = generation
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled, let self else { return }
            await self.flush(expected: token)
        }
    }

    func flush() async {
        saveTask?.cancel()
        generation += 1
        await flush(expected: generation)
    }

    func resetAllData() async {
        saveTask?.cancel()
        generation += 1
        chart = .empty
        recoveryNote = nil
        lastEffect = nil
        defaults.removeObject(forKey: Self.chartKey)
        do {
            try await disk.deleteDocument()
            try await photos.deleteAll()
        } catch {
            recoveryNote = "Reset cleared the roll, but a photo file could not be removed."
        }
        await flush(expected: generation)
    }

    private func load() async {
        if let data = defaults.data(forKey: Self.chartKey), let decoded = decode(data) {
            chart = decoded
        } else if let backup = await disk.readBackup(), let decoded = decode(backup) {
            chart = decoded
            recoveryNote = "The saved roll was damaged. Perchseal restored the last good copy."
            await persist(chart)
        } else if let primary = await disk.readPrimary(), let decoded = decode(primary) {
            chart = decoded
        } else if defaults.data(forKey: Self.chartKey) != nil {
            chart = .empty
            recoveryNote = "The saved roll could not be read. Perchseal started from an empty roster."
        }
        await seedIfNeeded()
    }

    private func seedIfNeeded() async {
        guard allowsDemoSeed else { return }
        #if targetEnvironment(simulator)
        if defaults.bool(forKey: Self.demoKey) { return }
        if !chart.birds.isEmpty || !chart.rhumbs.isEmpty { return }
        chart = PerchChart.demo(daykey: daykey)
        defaults.set(true, forKey: Self.demoKey)
        await persist(chart)
        #endif
    }

    private func flush(expected: Int) async {
        guard expected == generation else { return }
        let snapshot = chart
        await persist(snapshot)
        if generation != expected {
            await flush(expected: generation)
        }
    }

    private func persist(_ snapshot: PerchChart) async {
        do {
            let data = try encoder.encode(snapshot)
            try await disk.write(data)
            defaults.set(data, forKey: Self.chartKey)
        } catch {
            recoveryNote = "Tonight's roll is on screen, and the last save did not finish. It will try again."
        }
    }

    private func decode(_ data: Data) -> PerchChart? {
        do {
            return try decoder.decode(PerchChart.self, from: data)
        } catch {
            return nil
        }
    }

    private static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("CR Splash", isDirectory: true)
    }
}
