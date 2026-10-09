import SwiftUI
import UIKit

/// Home is the run preview and the perch strip. Scan, Present, Gap snap, and Seal fuse here.
struct FlockScreen: View {
    @EnvironmentObject private var store: PerchStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var lens = PerchLens()
    @Binding var cover: FlockCover?
    @State private var note = "Empty perch"
    @State private var manualCode = ""
    @State private var snapping = false
    @State private var showSpinner = false
    @State private var strayPayload: String?
    @State private var lastScan = ""
    @State private var lastScanAt = Date.distantPast
    @State private var sealFlash = false
    @State private var clock = Date()
    @State private var reloading = false
    @State private var reloadSpinner = false
    @FocusState private var focus: StripField?
    @ScaledMetric(relativeTo: .largeTitle) private var displayPoints: CGFloat = 28

    private enum StripField: Hashable {
        case note
        case code
    }

    private var flock: Flock { store.flock() }
    private var day: Int {
        _ = clock
        return store.daykey
    }
    private var active: [Bird] { flock.activeBirds }
    private var shortfall: Int {
        max(0, active.count - store.chart.presents(on: day).count - store.chart.gaps(on: day).count)
    }
    private var sealed: Bool { store.chart.isSealed(on: day) }

    var body: some View {
        Group {
            if let recovery = store.recoveryNote, active.isEmpty {
                statusPage(
                    title: "The roll did not load",
                    line: recovery,
                    action: "Try again",
                    retry: true
                )
            } else if active.isEmpty {
                statusPage(
                    title: "No flock yet",
                    line: "Add the birds first",
                    action: "Band a bird",
                    retry: false
                )
            } else {
                run
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WingColor.bg)
        .alert(strayTitle, isPresented: strayPresented) {
            Button(addRosterTitle) {
                if let strayPayload {
                    store.bandBird(name: "New bird", code: strayPayload)
                }
                strayPayload = nil
            }
            Button("Leave it", role: .cancel) { strayPayload = nil }
        } message: {
            Text(strayMessage)
        }
        .onAppear {
            lens.onPayload = { payload in
                acceptScan(payload)
            }
            lens.refresh()
        }
        .onDisappear { lens.halt() }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { lens.halt() }
            if phase == .active {
                clock = Date()
                lens.refresh()
            }
        }
    }

    private var strayTitle: String { "Unknown code" }
    private var addRosterTitle: String { "Add to roster" }
    private var strayMessage: String { "That code is not on the roster. Add the bird, then scan again." }
    private var photographTitle: String { "Photograph the gap" }
    private var reopenTitle: String { "Reopen" }
    private var countedWord: String { "Counted" }
    private var bandPrompt: String { "Band a bird" }

    private var strayPresented: Binding<Bool> {
        Binding(get: { strayPayload != nil }, set: { if !$0 { strayPayload = nil } })
    }

    private var run: some View {
        ZStack(alignment: .bottom) {
            preview
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: WingSpace.x4) {
                    header
                    if lens.gate == .live {
                        Color.clear
                            .frame(height: WingSpace.x12 * 5)
                            .contentShape(Rectangle())
                            .onTapGesture { focus = nil }
                            .accessibilityHidden(true)
                    } else {
                        gateCard
                    }
                    if let recovery = store.recoveryNote {
                        Text(recovery)
                            .font(WingFont.caption)
                            .foregroundStyle(WingColor.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(WingSpace.x3)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
                    }
                    strip
                }
                .padding(.horizontal, WingSpace.x4)
                .padding(.top, WingSpace.x4)
                .padding(.bottom, WingSpace.x4)
            }
            .scrollDismissesKeyboard(.immediately)
            if sealFlash {
                Image("psl_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: WingSpace.x12 * 3, height: WingSpace.x12 * 3)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .animation(WingMotion.ease, value: sealFlash)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus = nil }
            }
        }
    }

    private var preview: some View {
        PerchPreview(session: lens.session)
    }

    private var cameraAsk: String {
        "The perch camera reads the wing band and photographs an empty spot."
    }

    private var gateCard: some View {
        VStack(alignment: .leading, spacing: WingSpace.x4) {
            Text(gateLine)
                .font(WingFont.body)
                .foregroundStyle(WingColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            switch lens.gate {
            case .ask:
                Button("Continue") { lens.proceed() }
                    .buttonStyle(WingPress(kind: .quiet))
            case .denied:
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(WingPress(kind: .quiet))
            case .checking, .live, .unavailable:
                EmptyView()
            }
        }
        .padding(WingSpace.x4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: WingRadius.card, style: .continuous))
    }

    private var gateLine: String {
        switch lens.gate {
        case .checking:
            return "Starting the perch camera."
        case .ask:
            return cameraAsk
        case .denied:
            return "The camera is off. Open Settings to use the live perch, or type the code on the strip."
        case .unavailable:
            return "This device has no camera. Type the code on the strip."
        case .live:
            return ""
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: WingSpace.x3) {
            VStack(alignment: .leading, spacing: WingSpace.x2) {
                Text("Tonight")
                    .font(WingFont.display(points: displayPoints, size: typeSize))
                    .foregroundStyle(WingColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(jobLine)
                    .font(WingFont.body)
                    .foregroundStyle(WingColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(countLine)
                    .font(WingFont.headline)
                    .foregroundStyle(WingColor.accent)
                    .monospacedDigit()
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(WingSpace.x4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.card, style: .continuous))
            .accessibilityElement(children: .combine)

            VStack(spacing: WingSpace.x2) {
                iconButton("list.bullet", label: "Birds") { cover = .roster }
                iconButton("chart.bar", label: "This week") { cover = .analytics }
                iconButton("gearshape", label: "Settings") { cover = .settings }
            }
        }
    }

    private var countLine: String {
        let counted = WingCount.integer(store.chart.presents(on: day).count)
        let total = WingCount.integer(active.count)
        return "\(counted) of \(total) on the perch"
    }

    private var jobLine: String {
        if sealed {
            return "Tonight is sealed. Reopen if a count needs to change."
        }
        if let missing = waiting.first {
            return "\(missing.name) is still out. Scan \(missing.name), or photograph the empty perch."
        }
        return "Counts match. Seal the night."
    }

    /// Birds with no Present. A Gap that already fills the roster covers them, so they are not a scan target.
    private var unmarked: [Bird] {
        let marked = Set(store.chart.presents(on: day).map(\.birdID))
        return active.filter { !marked.contains($0.id) }
    }

    private var waiting: [Bird] {
        guard shortfall > 0 else { return [] }
        return unmarked
    }

    private var scanLabel: String {
        let typed = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if !typed.isEmpty { return "Scan" }
        if let bird = waiting.first { return "Scan \(bird.name)" }
        return "Scan"
    }

    private var scanReady: Bool {
        if sealed || snapping || shortfall == 0 { return false }
        if !manualCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        return waiting.first != nil
    }

    private var strip: some View {
        VStack(alignment: .leading, spacing: WingSpace.x3) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: WingSpace.x2, alignment: .leading),
                    GridItem(.flexible(), spacing: WingSpace.x2, alignment: .leading)
                ],
                alignment: .leading,
                spacing: WingSpace.x2
            ) {
                ForEach(Array(active.enumerated()), id: \.element.id) { index, bird in
                    birdChip(bird, index: index)
                }
            }
            if shortfall > 0 && !sealed {
                TextField("Gap note", text: $note)
                    .font(WingFont.body)
                    .foregroundStyle(WingColor.ink)
                    .focused($focus, equals: .note)
                    .padding(WingSpace.x3)
                    .frame(minHeight: WingSpace.hit)
                    .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
            }
            TextField("Wing code", text: $manualCode)
                .font(WingFont.body)
                .textInputAutocapitalization(.characters)
                .foregroundStyle(WingColor.ink)
                .focused($focus, equals: .code)
                .padding(WingSpace.x3)
                .frame(minHeight: WingSpace.hit)
                .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
            Text(effectLine ?? " ")
                .font(WingFont.caption)
                .foregroundStyle(WingColor.muted)
                .frame(maxWidth: .infinity, minHeight: WingSpace.x6, alignment: .leading)
                .opacity(effectLine == nil ? 0 : 1)
                .accessibilityHidden(effectLine == nil)
            actions
            if lens.gate != .live && !sealed {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: WingSpace.x2) {
                        ForEach(waiting) { bird in
                            Button(bird.name) { acceptScan(bird.band.code) }
                                .buttonStyle(WingPress(kind: .quiet, expands: false))
                                .accessibilityLabel("Scan \(bird.name)")
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .padding(WingSpace.x4)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: WingRadius.card, style: .continuous))
    }

    @ViewBuilder
    private var actions: some View {
        if sealed {
            Button(reopenTitle) {
                store.peel()
                pulse(store.lastEffect)
            }
            .buttonStyle(WingPress(kind: .quiet))
        } else if waiting.isEmpty {
            Button {
                store.seal()
                pulse(store.lastEffect)
            } label: {
                verbLabel("Seal")
            }
            .buttonStyle(WingPress(kind: .primary))
            .disabled(snapping)
        } else {
            Button {
                runScan()
            } label: {
                verbLabel(scanLabel)
            }
            .buttonStyle(WingPress(kind: .primary))
            .disabled(!scanReady)
            HStack(spacing: WingSpace.x2) {
                Button(photographTitle) { Task { await snap() } }
                    .buttonStyle(WingPress(kind: .quiet, loading: showSpinner))
                    .disabled(shortfall == 0 || sealed || snapping)
                Button("Seal") {
                    store.seal()
                    pulse(store.lastEffect)
                }
                .buttonStyle(WingPress(kind: .quiet))
                .disabled(snapping)
            }
        }
    }

    private func verbLabel(_ title: String) -> some View {
        HStack(spacing: WingSpace.x2) {
            Image("psl_ControlFace")
                .resizable()
                .scaledToFit()
                .frame(width: WingSpace.x8, height: WingSpace.x8)
                .clipped()
                .accessibilityHidden(true)
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func birdChip(_ bird: Bird, index: Int) -> some View {
        let present = store.chart.presents(on: day).contains { $0.birdID == bird.id }
        let covered = !present && shortfall == 0
        return PerchChip(
            name: bird.name,
            detail: present ? countedWord : (covered ? "Photo" : "Still out"),
            present: present || covered,
            index: index,
            reduceMotion: reduceMotion
        ) {
            store.tapPresent(birdID: bird.id)
            pulse(store.lastEffect)
        }
    }

    private var effectLine: String? {
        switch store.lastEffect {
        case .early:
            return "Too early. Finish the shortfall, then seal."
        case .hollow:
            return "The gap needs a photo. Photograph the empty perch."
        case .sealed:
            return "Tonight is sealed."
        case .stray:
            return "That code is not on the roster."
        case .refused(let message):
            return message
        case .peeled:
            return "Last mark dropped. The night is open again."
        case .gap:
            return "Gap filed with a photo."
        default:
            return nil
        }
    }

    private func runScan() {
        let typed = manualCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if !typed.isEmpty {
            acceptScan(typed)
            return
        }
        if let bird = waiting.first {
            acceptScan(bird.band.code)
        }
    }

    private func acceptScan(_ payload: String) {
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        if trimmed == lastScan && now.timeIntervalSince(lastScanAt) < 1.5 { return }
        lastScan = trimmed
        lastScanAt = now
        store.scan(payload: trimmed)
        if case .stray = store.lastEffect {
            strayPayload = trimmed
        }
        pulse(store.lastEffect)
        manualCode = ""
        focus = nil
    }

    private func snap() async {
        guard !snapping else { return }
        snapping = true
        let spin = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            showSpinner = true
        }
        let jpeg = await lens.snapJPEG() ?? Data()
        await store.snapGap(note: note, jpeg: jpeg)
        spin.cancel()
        showSpinner = false
        snapping = false
        pulse(store.lastEffect)
    }

    private func pulse(_ effect: RollEffect?) {
        switch effect {
        case .present, .manualThenPresent, .gap, .sealed, .peeled:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        default:
            break
        }
        guard case .sealed = effect else { return }
        sealFlash = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            withAnimation(WingMotion.ease) {
                sealFlash = false
            }
        }
    }

    private func iconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(WingFont.headline)
                .foregroundStyle(WingColor.ink)
                .frame(width: WingSpace.hit, height: WingSpace.hit)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
        }
        .buttonStyle(WingTap())
        .accessibilityLabel(label)
    }

    private func statusPage(title: String, line: String, action: String, retry: Bool) -> some View {
        VStack(alignment: .leading, spacing: WingSpace.x4) {
            HStack {
                Spacer(minLength: 0)
                iconButton("gearshape", label: "Settings") { cover = .settings }
            }
            Spacer(minLength: 0)
            Image("psl_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: WingSpace.x12 * 6)
                .clipped()
                .accessibilityHidden(true)
            Text(title)
                .font(WingFont.title)
                .foregroundStyle(WingColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .font(WingFont.body)
                .foregroundStyle(WingColor.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(action) {
                if retry {
                    Task { await retryLoad() }
                } else {
                    cover = .roster
                }
            }
            .buttonStyle(WingPress(kind: .primary, loading: reloadSpinner))
            .disabled(reloading)
            if retry {
                Button(bandPrompt) { cover = .roster }
                    .buttonStyle(WingPress(kind: .quiet))
            }
        }
        .padding(WingSpace.x6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func retryLoad() async {
        reloading = true
        let spin = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            reloadSpinner = true
        }
        await store.reload()
        spin.cancel()
        reloadSpinner = false
        reloading = false
    }
}

private struct PerchChip: View {
    let name: String
    let detail: String
    let present: Bool
    let index: Int
    let reduceMotion: Bool
    let tap: () -> Void
    @State private var shown = false

    var body: some View {
        Button(action: tap) {
            VStack(alignment: .leading, spacing: WingSpace.x1) {
                Text(name)
                    .font(WingFont.headline)
                    .foregroundStyle(WingColor.ink)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(WingFont.caption)
                    .foregroundStyle(present ? WingColor.accent : WingColor.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(WingSpace.x3)
            .frame(maxWidth: .infinity, minHeight: WingSpace.hit, alignment: .leading)
            .background(WingColor.bg, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
            .opacity(shown ? 1 : 0)
        }
        .buttonStyle(WingTap())
        .accessibilityLabel(present ? "\(name), counted" : "Count \(name)")
        .onAppear {
            guard !reduceMotion else {
                withAnimation(WingMotion.ease) { shown = true }
                return
            }
            let delay = min(WingMotion.cap, Double(index) * WingMotion.step)
            withAnimation(WingMotion.ease.delay(delay)) {
                shown = true
            }
        }
    }
}

enum FlockCover: String, Identifiable {
    case roster
    case analytics
    case settings
    var id: String { rawValue }
}
