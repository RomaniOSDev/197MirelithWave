import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabContainerView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.startSessionTracking()
            case .background, .inactive:
                store.pauseSessionTracking()
            @unknown default:
                break
            }
        }
        .onAppear {
            if scenePhase == .active {
                store.startSessionTracking()
            }
        }
    }
}

#Preview {
    ContentView()
}
