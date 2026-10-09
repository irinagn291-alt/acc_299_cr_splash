import SwiftUI

/// CSV export, reset, onboarding replay, and the contact link.
struct SettingsScreen: View {
    @EnvironmentObject private var store: PerchStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var reloading = false
    @State private var reloadSpinner = false
    var replay: () -> Void

    private var csv: String { RollCSV.document(chart: store.chart) }
    private var sealed: Int { RollCSV.sealedDays(chart: store.chart) }
    private var contactURL: URL? { URL(string: "https://perchseal-lockup.pro/contact-us") }
    private var sealedLine: String {
        let count = WingCount.integer(sealed)
        return "\(count) sealed"
    }
    private var keepFlockTitle: String { "Keep the flock" }
    private var resetDetail: String {
        "This removes every bird, tonight's roll, and gap photos from this device."
    }

    var body: some View {
        NavigationStack {
            Group {
                if let note = store.recoveryNote, store.chart.birds.isEmpty && sealed == 0 {
                    notice(title: "Settings hit a bad save", line: note, retry: true)
                } else if store.chart.birds.isEmpty && sealed == 0 {
                    notice(title: "Nothing stored yet", line: "Band the flock on the perch. Export appears after the first seal.", retry: false)
                } else {
                    form
                }
            }
            .background(WingColor.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
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
            }
            .confirmationDialog(
                "Reset the whole flock?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset birds and rolls", role: .destructive) {
                    Task { await store.resetAllData() }
                }
                Button(keepFlockTitle, role: .cancel) {}
            } message: {
                Text(resetDetail)
            }
        }
    }

    private var form: some View {
        Form {
            if let note = store.recoveryNote {
                Section {
                    Text(note)
                        .font(WingFont.body)
                        .foregroundStyle(WingColor.ink)
                    Button("Try again") { Task { await retryLoad() } }
                        .buttonStyle(WingPress(kind: .quiet, loading: reloadSpinner))
                        .disabled(reloading)
                }
                .listRowBackground(WingColor.surface)
            }
            Section("Sealed rolls") {
                Text(sealedLine)
                    .font(WingFont.body)
                    .foregroundStyle(WingColor.ink)
                    .monospacedDigit()
                if sealed > 0 {
                    ShareLink(item: csv) {
                        Label("Export roll CSV", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity, minHeight: WingSpace.hit, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(WingPress(kind: .quiet))
                } else {
                    Text("Seal a night before export.")
                        .font(WingFont.caption)
                        .foregroundStyle(WingColor.muted)
                }
            }
            .listRowBackground(WingColor.surface)
            Section {
                Button { replay(); dismiss() } label: {
                    Label("Replay onboarding", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity, minHeight: WingSpace.hit, alignment: .leading)
                }
                .buttonStyle(WingPress(kind: .quiet))
                Button { confirmReset = true } label: {
                    Label("Reset all data", systemImage: "trash")
                }
                .buttonStyle(WingPress(kind: .destructive))
                if let contactURL {
                    Link(destination: contactURL) {
                        Label("Contact Perchseal", systemImage: "link")
                            .frame(maxWidth: .infinity, minHeight: WingSpace.hit, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(WingPress(kind: .quiet))
                }
            }
            .listRowBackground(WingColor.surface)
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .listRowSeparatorTint(WingColor.muted)
    }

    private func notice(title: String, line: String, retry: Bool) -> some View {
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
            Text(line)
                .font(WingFont.body)
                .foregroundStyle(WingColor.muted)
            Spacer(minLength: 0)
            if retry {
                Button("Try again") { Task { await retryLoad() } }
                    .buttonStyle(WingPress(kind: .primary, loading: reloadSpinner))
                    .disabled(reloading)
            }
            Button { replay(); dismiss() } label: {
                Label("Replay onboarding", systemImage: "arrow.clockwise")
            }
            .buttonStyle(WingPress(kind: .quiet))
            Button { confirmReset = true } label: {
                Label("Reset all data", systemImage: "trash")
            }
            .buttonStyle(WingPress(kind: .destructive))
            if let contactURL {
                Link(destination: contactURL) {
                    Label("Contact Perchseal", systemImage: "link")
                        .frame(maxWidth: .infinity, minHeight: WingSpace.hit)
                        .contentShape(Rectangle())
                }
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
