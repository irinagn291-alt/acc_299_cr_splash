import XCTest
@testable import Perchseal

final class ReviewLaunchTests: XCTestCase {
    func testReviewScreenParser() {
        XCTAssertEqual(ReviewLaunch.screen(from: ["App", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(from: ["-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(from: ["-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(from: ["-ReviewScreen"]))
        XCTAssertNil(ReviewLaunch.screen(from: []))
    }
}

final class FlockLedgerTests: XCTestCase {
    func testCostPerUnitFeedKgAndHealthScore() {
        let feeds = [Feed(cost: 10, kilograms: 14)]
        let eggs = [Production(quantity: 7)]
        let costPerUnit = FlockLedger.costPerUnit(feeds: feeds, production: eggs)
        let feedKg = FlockLedger.fcr(feeds: feeds, production: eggs)
        XCTAssertEqual(costPerUnit, Decimal(10) / Decimal(7))
        XCTAssertEqual(feedKg, 2)
        XCTAssertNil(FlockLedger.costPerUnit(feeds: feeds, production: []))
        XCTAssertNil(FlockLedger.fcr(feeds: [], production: [Production(quantity: 0)]))
        XCTAssertEqual(FlockLedger.healthScore(mortality: 0, notes: 0), 100)
        XCTAssertEqual(FlockLedger.healthScore(mortality: 0, notes: 30), 80)
        XCTAssertEqual(FlockLedger.healthScore(mortality: 1, notes: 0), 0)
        let events = [HealthEvent(mortality: 0, notes: 5)]
        XCTAssertEqual(FlockLedger.healthScore(events: events), 95)
    }
}

final class RollFoldTests: XCTestCase {
    private let day = 20260927

    private func roster(_ count: Int) -> PerchChart {
        var chart = PerchChart.empty
        for index in 0..<count {
            let bird = chart.books.band(name: "Bird \(index)", code: "BAND-\(index)", daykey: day)
            chart.islands.append(bird)
        }
        return chart
    }

    func testEmptyRosterStaysBare() {
        var chart = PerchChart.empty
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .bare)
        XCTAssertEqual(RollFold.scan(&chart, payload: "BAND-0", daykey: day), .bare)
        XCTAssertTrue(chart.rhumbs.isEmpty)
    }

    func testScanKnownBandFoldsOpenToTallying() {
        var chart = roster(2)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .open)
        XCTAssertEqual(RollFold.scan(&chart, payload: "band-0", daykey: day), .present)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .tallying)
        XCTAssertEqual(chart.presents(on: day).count, 1)
    }

    func testUnknownPayloadWritesStray() {
        var chart = roster(1)
        XCTAssertEqual(RollFold.scan(&chart, payload: "NOT-A-BAND", daykey: day), .stray)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .open)
    }

    func testManualMarkOncePerWeekThenPresent() {
        var chart = roster(1)
        let bird = chart.birds[0]
        XCTAssertEqual(RollFold.tapPresent(&chart, birdID: bird.id, daykey: day), .manualThenPresent)
        XCTAssertEqual(chart.presents(on: day).count, 1)
        XCTAssertEqual(chart.manuals(on: day).count, 1)
        _ = RollFold.peel(&chart, daykey: day)
        let again = RollFold.tapPresent(&chart, birdID: bird.id, daykey: day)
        XCTAssertEqual(again, .refused("Manual mark already used this week. Scan the band."))
    }

    func testPresentThenGapThenSeal() {
        var chart = roster(2)
        _ = RollFold.scan(&chart, payload: "BAND-0", daykey: day)
        XCTAssertEqual(RollFold.seal(&chart, daykey: day), .early)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .tallying)
        XCTAssertEqual(RollFold.snapGap(&chart, daykey: day, note: "Empty end perch", photoFile: "gap.jpg"), .gap)
        XCTAssertEqual(RollFold.seal(&chart, daykey: day), .sealed)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .sealed)
    }

    func testGapWithoutSnapWritesHollowAndBlocksSeal() {
        var chart = roster(1)
        XCTAssertEqual(RollFold.markHollow(chart: &chart, daykey: day), .hollow)
        XCTAssertEqual(RollFold.seal(&chart, daykey: day), .hollow)
        XCTAssertNotEqual(RollFold.phase(chart, daykey: day), .sealed)
    }

    func testGapFillsRosterThenScanDoesNotAddPresent() {
        var chart = roster(2)
        XCTAssertEqual(RollFold.scan(&chart, payload: "BAND-0", daykey: day), .present)
        XCTAssertEqual(RollFold.snapGap(&chart, daykey: day, note: "Empty end perch", photoFile: "gap.jpg"), .gap)
        let again = RollFold.scan(&chart, payload: "BAND-1", daykey: day)
        XCTAssertEqual(again, .refused("Counts already match. Seal the night."))
        let covered = chart.birds[1]
        XCTAssertEqual(
            RollFold.tapPresent(&chart, birdID: covered.id, daykey: day),
            .refused("Counts already match. Seal the night.")
        )
        XCTAssertEqual(chart.presents(on: day).count, 1)
        XCTAssertEqual(chart.gaps(on: day).count, 1)
        XCTAssertEqual(RollFold.seal(&chart, daykey: day), .sealed)
    }

    func testPeelReopensSealedRoll() {
        var chart = roster(1)
        _ = RollFold.scan(&chart, payload: "BAND-0", daykey: day)
        XCTAssertEqual(RollFold.seal(&chart, daykey: day), .sealed)
        XCTAssertEqual(RollFold.peel(&chart, daykey: day), .peeled)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .open)
        XCTAssertTrue(chart.presents(on: day).isEmpty)
    }

    func testDemoLeavesOneBirdUnmarked() {
        let chart = PerchChart.demo(daykey: day)
        let active = chart.books.active(on: day)
        XCTAssertEqual(active.count, 4)
        XCTAssertEqual(chart.presents(on: day).count, 3)
        XCTAssertTrue(chart.onboardingComplete)
        XCTAssertEqual(RollFold.phase(chart, daykey: day), .tallying)
    }
}

@MainActor
final class PerchStoreTests: XCTestCase {
    private struct Harness {
        let store: PerchStore
        let defaults: UserDefaults
        let root: URL
    }

    private func makeStore() throws -> Harness {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let name = "perchseal.tests." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: name) else {
            XCTFail("Could not open a defaults suite")
            throw CocoaError(.fileNoSuchFile)
        }
        defaults.removePersistentDomain(forName: name)
        let store = PerchStore(defaults: defaults, directory: root, allowsDemoSeed: false)
        return Harness(store: store, defaults: defaults, root: root)
    }

    func testRoundTripReload() async throws {
        let harness = try makeStore()
        await harness.store.waitUntilReady()
        harness.store.bandBird(name: "Maple", code: "PSL-1")
        harness.store.scan(payload: "PSL-1")
        await harness.store.flush()
        let reloaded = PerchStore(defaults: harness.defaults, directory: harness.root, allowsDemoSeed: false)
        await reloaded.waitUntilReady()
        XCTAssertEqual(reloaded.chart.birds.count, 1)
        XCTAssertEqual(reloaded.chart.presents(on: reloaded.daykey).count, 1)
        XCTAssertEqual(reloaded.chart.schemaVersion, 1)
    }

    func testCorruptChartFallsBackToBackup() async throws {
        let harness = try makeStore()
        await harness.store.waitUntilReady()
        harness.store.bandBird(name: "Brass", code: "PSL-2")
        await harness.store.flush()
        let primary = harness.root.appendingPathComponent("chart.json")
        let backup = harness.root.appendingPathComponent("chart.json.backup")
        let good = try Data(contentsOf: primary)
        try good.write(to: backup, options: .atomic)
        harness.defaults.set(Data("not-json".utf8), forKey: PerchStore.chartKey)
        let reloaded = PerchStore(defaults: harness.defaults, directory: harness.root, allowsDemoSeed: false)
        await reloaded.waitUntilReady()
        XCTAssertEqual(reloaded.chart.birds.first?.name, "Brass")
        XCTAssertNotNil(reloaded.recoveryNote)
    }

    func testResetClearsPhotosAndReloadsEmpty() async throws {
        let harness = try makeStore()
        await harness.store.waitUntilReady()
        harness.store.bandBird(name: "Cinder", code: "PSL-3")
        await harness.store.snapGap(note: "Missing", jpeg: Data([0xFF, 0xD8, 0xFF]))
        await harness.store.flush()
        await harness.store.resetAllData()
        XCTAssertTrue(harness.store.chart.birds.isEmpty)
        let gaps = harness.root.appendingPathComponent("gaps")
        XCTAssertFalse(FileManager.default.fileExists(atPath: gaps.path))
        let reloaded = PerchStore(defaults: harness.defaults, directory: harness.root, allowsDemoSeed: false)
        await reloaded.waitUntilReady()
        XCTAssertTrue(reloaded.chart.rhumbs.isEmpty)
    }
}
