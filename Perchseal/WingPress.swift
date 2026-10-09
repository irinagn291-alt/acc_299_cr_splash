import SwiftUI

/// Live verb wears accent. Retire uses the destructive variant. Default, pressed, disabled, and loading.
struct WingPress: ButtonStyle {
    enum Kind {
        case primary
        case quiet
        case destructive
    }

    var kind: Kind = .primary
    var loading: Bool = false
    var expands: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        WingPressBody(configuration: configuration, kind: kind, loading: loading, expands: expands)
    }
}

private struct WingPressBody: View {
    let configuration: ButtonStyleConfiguration
    let kind: WingPress.Kind
    let loading: Bool
    var expands: Bool = true
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack(spacing: WingSpace.x2) {
            if loading {
                ProgressView()
                    .tint(foreground)
            }
            configuration.label
        }
        .font(WingFont.headline)
        .foregroundStyle(foreground)
        .frame(maxWidth: expands ? .infinity : nil, minHeight: WingSpace.hit)
        .padding(.horizontal, WingSpace.x4)
        .background(background, in: RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
        .scaleEffect(configuration.isPressed && isEnabled ? 0.96 : 1)
        .opacity(isEnabled ? (configuration.isPressed ? 0.72 : 1) : 1)
        .animation(WingMotion.press, value: configuration.isPressed)
    }

    private var foreground: Color {
        if !isEnabled { return WingColor.muted }
        switch kind {
        case .primary, .destructive:
            return WingColor.bg
        case .quiet:
            return WingColor.ink
        }
    }

    private var background: Color {
        if !isEnabled { return WingColor.surface }
        switch kind {
        case .primary:
            return WingColor.accent
        case .quiet:
            return WingColor.surface
        case .destructive:
            return WingColor.ink
        }
    }
}

/// Press feedback for a chip or icon whose label already owns its plate.
struct WingTap: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(RoundedRectangle(cornerRadius: WingRadius.chip, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(WingMotion.press, value: configuration.isPressed)
    }
}
