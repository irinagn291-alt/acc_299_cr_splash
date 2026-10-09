import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #000000
    static let bg = Color(red: 0.000000, green: 0.000000, blue: 0.000000)
    static let bgHex = "#000000"
    /// #1E1E1E
    static let surface = Color(red: 0.117647, green: 0.117647, blue: 0.117647)
    static let surfaceHex = "#1E1E1E"
    /// #FFFFFF
    static let ink = Color(red: 1.000000, green: 1.000000, blue: 1.000000)
    static let inkHex = "#FFFFFF"
    /// #FFA42B
    static let accent = Color(red: 1.000000, green: 0.643137, blue: 0.168627)
    static let accentHex = "#FFA42B"
    /// #A5A5A5
    static let muted = Color(red: 0.647059, green: 0.647059, blue: 0.647059)
    static let mutedHex = "#A5A5A5"
    static let fontFamily = "Bodoni 72"
}
