import SwiftUI

/// Colour, type, space, and the 28/14 radius pair. Views read these accessors only.
enum WingColor {
    static let bg = DesignTokens.bg
    static let surface = DesignTokens.surface
    static let ink = DesignTokens.ink
    static let accent = DesignTokens.accent
    static let muted = DesignTokens.muted
}

enum WingSpace {
    static let unit: CGFloat = 4
    static var x1: CGFloat { unit }
    static var x2: CGFloat { unit * 2 }
    static var x3: CGFloat { unit * 3 }
    static var x4: CGFloat { unit * 4 }
    static var x5: CGFloat { unit * 5 }
    static var x6: CGFloat { unit * 6 }
    static var x8: CGFloat { unit * 8 }
    static var x10: CGFloat { unit * 10 }
    static var x12: CGFloat { unit * 12 }
    static var hit: CGFloat { unit * 11 }
}

enum WingRadius {
    static let card: CGFloat = 28
    static let chip: CGFloat = 14
}

/// Six steps. Bodoni is the display step. Body stays the system face at the body step.
enum WingFont {
    static func display(points: CGFloat, size: DynamicTypeSize) -> Font {
        let capped = min(points, 34)
        if size >= .accessibility3 {
            return .custom("New York", size: capped, relativeTo: .largeTitle)
        }
        return .custom(DesignTokens.fontFamily, size: capped, relativeTo: .largeTitle)
    }

    static let title = Font.system(.title2)
    static let headline = Font.system(.headline)
    static let body = Font.system(.body)
    static let caption = Font.system(.caption)
    static let micro = Font.system(.caption2)
}

enum WingMotion {
    static let ease = Animation.easeOut(duration: 0.28)
    static let press = Animation.easeOut(duration: 0.2)
    static let step = 0.05
    static let cap = 0.36
}

enum WingCount {
    private static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func integer(_ value: Int) -> String {
        decimal.string(from: NSNumber(value: value)) ?? "0"
    }

    static func rate(_ value: Double) -> String {
        percent.string(from: NSNumber(value: value)) ?? "0%"
    }
}
