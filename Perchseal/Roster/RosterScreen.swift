import SwiftUI
import UIKit

/// Bands a new bird or retires a cull. Covers Flock as a sheet.
struct RosterScreen: View {
    @EnvironmentObject private var store: PerchStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var code = ""
    @State private var retireTarget: Bird?
    @State private var confirmLeave = false
    @FocusState private var focused: Bool

    private var rosterTitle: String { "Birds" }
    private var bandTitle: String { "Band a bird" }
    private var keepTitle: String { "Keep on the roster" }
    private var retireDetail: String {
        "A retired bird leaves the active headcount. Tonight's earlier marks stay in the roll."
    }
    private var dirty: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty || !code.trimmingCharacters(in: .whitespaces).isEmpty
    }
    private var canBand: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !code.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if let note = store.recoveryNote, store.chart.birds.isEmpty {
                    empty(title: "Birds could not be read", line: note)
                } else if store.chart.birds.isEmpty {
                    empty(title: "No birds yet", line: "Add a name and a wing code.")
                } else {
                    list
                }
            }
            .background(WingColor.bg)
            .navigationTitle(rosterTitle)
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(dirty)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { requestClose() } label: {
                        Image(systemName: "xmark")
                            .font(WingFont.headline)
                            .foregroundStyle(WingColor.ink)
                            .frame(width: WingSpace.hit, height: WingSpace.hit)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(WingTap())
                    .accessibilityLabel("Close")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focused = false }
                }
            }
            .confirmationDialog(
                retireAsk,
                isPresented: retireShown,
                titleVisibility: .visible
            ) {
                Button(retireConfirmTitle, role: .destructive) {
                    if let retireTarget {
                        store.retire(birdID: retireTarget.id)
                    }
                    retireTarget = nil
                }
                Button(keepTitle, role: .cancel) { retireTarget = nil }
            } message: {
                Text(retireDetail)
            }
            .alert("Leave without saving?", isPresented: $confirmLeave) {
                Button("Leave", role: .destructive) { dismiss() }
                Button("Keep editing", role: .cancel) {}
            } message: {
                Text("The name and wing code you typed will be dropped.")
            }
        }
    }

    private var retireShown: Binding<Bool> {
        Binding(get: { retireTarget != nil }, set: { if !$0 { retireTarget = nil } })
    }

    private var retireAsk: String { "Retire this bird?" }

    private func retireRow(_ name: String) -> String {
        "Retire \(name)"
    }

    private var retireConfirmTitle: String {
        if let name = retireTarget?.name, !name.isEmpty {
            return "Retire \(name)"
        }
        return "Retire"
    }

    private var list: some View {
        List {
            Section {
                ForEach(store.chart.birds) { bird in
                    VStack(alignment: .leading, spacing: WingSpace.x1) {
                        Text(bird.name)
                            .font(WingFont.headline)
                            .foregroundStyle(WingColor.ink)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Text(bird.retiredOn == nil ? bird.band.code : "Retired")
                            .font(WingFont.caption)
                            .foregroundStyle(WingColor.muted)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: WingSpace.hit, alignment: .leading)
                    .listRowBackground(WingColor.surface)
                    if bird.retiredOn == nil {
                        Button { retireTarget = bird } label: {
                            Label(retireRow(bird.name), systemImage: "trash")
                        }
                        .buttonStyle(WingPress(kind: .destructive))
                        .listRowBackground(WingColor.bg)
                    }
                }
            }
            bandSection
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .listStyle(.plain)
        .listRowSeparatorTint(WingColor.muted)
    }

    private var bandSection: some View {
        Section {
            TextField("Name", text: $name)
                .font(WingFont.body)
                .focused($focused)
            TextField("Wing code", text: $code)
                .font(WingFont.body)
                .textInputAutocapitalization(.characters)
                .focused($focused)
            Button { band() } label: {
                Label(bandTitle, systemImage: "plus")
            }
            .buttonStyle(WingPress(kind: .primary))
            .disabled(!canBand)
        }
        .listRowBackground(WingColor.surface)
    }

    private func empty(title: String, line: String) -> some View {
        ScrollView {
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
            TextField("Name", text: $name)
                .font(WingFont.body)
                .focused($focused)
                .padding(WingSpace.x3)
                .frame(minHeight: WingSpace.hit)
                .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
            TextField("Wing code", text: $code)
                .font(WingFont.body)
                .textInputAutocapitalization(.characters)
                .focused($focused)
                .padding(WingSpace.x3)
                .frame(minHeight: WingSpace.hit)
                .background(WingColor.surface, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
        }
        .padding(WingSpace.x6)
        .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.immediately)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .safeAreaInset(edge: .bottom) {
            Button { band() } label: {
                Label(bandTitle, systemImage: "plus")
            }
            .buttonStyle(WingPress(kind: .primary))
            .disabled(!canBand)
            .padding(WingSpace.x6)
            .background(.regularMaterial)
        }
    }

    private func band() {
        store.bandBird(name: name.trimmingCharacters(in: .whitespaces), code: code)
        name = ""
        code = ""
        focused = false
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func requestClose() {
        if dirty {
            confirmLeave = true
        } else {
            dismiss()
        }
    }
}
