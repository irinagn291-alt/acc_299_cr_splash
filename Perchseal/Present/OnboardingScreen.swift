import SwiftUI

/// Full-page gate. Continue sits full width at the bottom. Skip writes the completion flag.
struct OnboardingScreen: View {
    @EnvironmentObject private var store: PerchStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [(title: String, line: String, art: String)] = [
        ("Lock up the flock", "Each evening the perch should match the birds you still keep.", "psl_Onboarding1"),
        ("Scan the band", "A known wing band marks that bird home. One manual mark is allowed each week.", "psl_Onboarding2"),
        ("Photograph the gap", "If someone is missing, photograph the empty perch before you seal.", "psl_Onboarding3"),
        ("Seal the night", "Seal when every bird is counted, or the empty perch has a photo.", "psl_TwistHero")
    ]

    private var pageCount: String {
        let current = WingCount.integer(page + 1)
        let total = WingCount.integer(pages.count)
        return "\(current) of \(total)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WingSpace.x4) {
            HStack {
                Text(pageCount)
                    .font(WingFont.caption)
                    .foregroundStyle(WingColor.muted)
                    .monospacedDigit()
                Spacer(minLength: 0)
                Button { store.completeOnboarding() } label: {
                    Text("Skip")
                        .font(WingFont.headline)
                        .foregroundStyle(WingColor.ink)
                        .frame(minWidth: WingSpace.hit, minHeight: WingSpace.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(WingTap())
            }
            Image(pages[page].art)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)
                .id(page)
            Text(pages[page].title)
                .font(WingFont.title)
                .foregroundStyle(WingColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .id("title-\(page)")
            Text(pages[page].line)
                .font(WingFont.body)
                .foregroundStyle(WingColor.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            Button(page == pages.count - 1 ? "Continue" : "Next") {
                if page == pages.count - 1 {
                    store.completeOnboarding()
                } else {
                    page += 1
                }
            }
            .buttonStyle(WingPress(kind: .primary))
        }
        .padding(WingSpace.x6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(WingColor.bg)
        .animation(reduceMotion ? WingMotion.ease : WingMotion.ease, value: page)
    }
}
