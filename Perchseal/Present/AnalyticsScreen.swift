import SwiftUI

/// Seven-day gap rate and headcount drift against the roster.
struct AnalyticsScreen: View {
    @EnvironmentObject private var store: PerchStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var reloading = false
    @State private var reloadSpinner = false
    @ScaledMetric(relativeTo: .largeTitle) private var displayPoints: CGFloat = 28

    private var readout: WeekReadout {
        WeekReadout.make(chart: store.chart, daykey: store.daykey)
    }

    private var missingNames: [String] {
        let marked = Set(store.chart.presents(on: store.daykey).map(\.birdID))
        let unmarked = store.flock().activeBirds.filter { !marked.contains($0.id) }
        guard readout.drift > 0 else { return [] }
        return Array(unmarked.prefix(readout.drift)).map(\.name)
    }

    private var driftTitle: String {
        if let name = missingNames.first, missingNames.count == 1 {
            return "\(name) is still out"
        }
        if missingNames.count > 1 {
            return "\(missingNames.joined(separator: ", ")) are still out"
        }
        return "Tonight matches the birds you keep"
    }

    private var driftFigure: String {
        let count = WingCount.integer(readout.drift)
        return "\(count) still out"
    }

    private var driftLine: String {
        if let name = missingNames.first, missingNames.count == 1 {
            return "Scan \(name), or photograph the empty perch."
        }
        if missingNames.count > 1 {
            return "Scan each bird still out, or photograph the empty perch."
        }
        return "Close this week. Seal tonight on the perch if the count is still open."
    }

    private var nextTap: String {
        if let name = missingNames.first, missingNames.count == 1 {
            return "Scan \(name)"
        }
        if !missingNames.isEmpty {
            return "Back to tonight"
        }
        return "Back to tonight"
    }

    var body: some View {
        NavigationStack {
            Group {
                if let note = store.recoveryNote, store.chart.sessions.isEmpty {
                    page(title: "This week did not load", line: note, retry: true)
                } else if store.chart.sessions.isEmpty {
                    page(title: "No nights yet", line: "Seal a night on the perch and the week will show up here.", retry: false)
                } else {
                    filled
                }
            }
            .background(WingColor.bg)
            .navigationTitle("This week")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    closeButton
                }
            }
        }
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(WingFont.headline)
                .foregroundStyle(WingColor.ink)
                .frame(width: WingSpace.hit, height: WingSpace.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(WingTap())
        .accessibilityLabel("Close")
    }

    private var filled: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WingSpace.x4) {
                if let note = store.recoveryNote {
                    Text(note)
                        .font(WingFont.body)
                        .foregroundStyle(WingColor.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(WingSpace.x4)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: WingRadius.card, style: .continuous))
                }
                VStack(alignment: .leading, spacing: WingSpace.x3) {
                    Text(driftTitle)
                        .font(WingFont.title)
                        .foregroundStyle(WingColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(driftFigure)
                        .font(WingFont.display(points: displayPoints, size: typeSize))
                        .foregroundStyle(WingColor.accent)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(driftLine)
                        .font(WingFont.body)
                        .foregroundStyle(WingColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(nextTap) { dismiss() }
                        .buttonStyle(WingPress(kind: .primary))
                }
                .padding(WingSpace.x5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.card, style: .continuous))

                HStack(alignment: .top, spacing: WingSpace.x4) {
                    metric("Gap rate", value: readout.gapRate.map(WingCount.rate) ?? "None yet")
                    Rectangle()
                        .fill(WingColor.muted)
                        .frame(width: WingSpace.x1)
                        .accessibilityHidden(true)
                    metric("Health", value: WingCount.integer(readout.health))
                }
                .padding(WingSpace.x4)
                .frame(maxWidth: .infinity, minHeight: WingSpace.x12 * 2, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: WingRadius.card, style: .continuous))

                VStack(alignment: .leading, spacing: WingSpace.x2) {
                    Text(readout.costLine)
                        .font(WingFont.body)
                        .foregroundStyle(WingColor.ink)
                    Text(readout.fcrLine)
                        .font(WingFont.body)
                        .foregroundStyle(WingColor.muted)
                }
                .padding(WingSpace.x4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
            }
            .padding(WingSpace.x4)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: WingSpace.x2) {
            Text(title)
                .font(WingFont.caption)
                .foregroundStyle(WingColor.muted)
                .lineLimit(1)
            Text(value)
                .font(WingFont.headline)
                .foregroundStyle(WingColor.ink)
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func page(title: String, line: String, retry: Bool) -> some View {
        VStack(alignment: .leading, spacing: WingSpace.x4) {
            Image("psl_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: WingSpace.x12 * 5)
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
            if retry {
                Button("Try again") { Task { await retryLoad() } }
                    .buttonStyle(WingPress(kind: .primary, loading: reloadSpinner))
                    .disabled(reloading)
            } else {
                Button("Back to tonight") { dismiss() }
                    .buttonStyle(WingPress(kind: .primary))
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
