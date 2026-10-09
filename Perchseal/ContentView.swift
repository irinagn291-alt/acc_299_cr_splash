import SwiftUI

/// Run-locked chrome. Flock stays up. Roster, Analytics, and Settings arrive as sheets.
struct ContentView: View {
    @EnvironmentObject private var store: PerchStore
    @State private var cover: FlockCover?
    @State private var ready = false
    @State private var reviewRead = false
    @State private var forceOnboarding = false

    var body: some View {
        Group {
            if !ready {
                WingColor.bg
            } else if !store.chart.onboardingComplete || forceOnboarding {
                OnboardingScreen()
            } else {
                FlockScreen(cover: $cover)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WingColor.bg.ignoresSafeArea())
        .sheet(item: $cover) { item in
            Group {
                switch item {
                case .roster:
                    RosterScreen()
                case .analytics:
                    AnalyticsScreen()
                case .settings:
                    SettingsScreen {
                        forceOnboarding = true
                        cover = nil
                    }
                }
            }
            .presentationCornerRadius(WingRadius.card)
            .presentationBackground(WingColor.bg)
            .presentationDragIndicator(.visible)
        }
        .task {
            await store.waitUntilReady()
            ready = true
            openReviewIfNeeded()
        }
        .onChange(of: store.chart.onboardingComplete) { _, done in
            if done {
                forceOnboarding = false
                openReviewIfNeeded()
            }
        }
    }

    private func openReviewIfNeeded() {
        guard store.chart.onboardingComplete, !forceOnboarding, !reviewRead else { return }
        reviewRead = true
        switch ReviewLaunch.screen {
        case "log", "roster":
            cover = .roster
        case "goals", "analytics":
            cover = .analytics
        case "settings":
            cover = .settings
        default:
            cover = nil
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PerchStore(allowsDemoSeed: false))
}
