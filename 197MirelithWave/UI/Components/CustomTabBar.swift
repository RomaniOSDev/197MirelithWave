import SwiftUI

enum MainTab: Int, CaseIterable, Identifiable {
    case home
    case wishlist
    case tools
    case achievements
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .wishlist: return "Trips"
        case .tools: return "Tools"
        case .achievements: return "Awards"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .wishlist: return "globe.americas.fill"
        case .tools: return "suitcase.fill"
        case .achievements: return "star.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    @State private var pressedTab: MainTab?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(MainTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppGradients.surfaceDeep)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppGradients.topSheen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(AppGradients.borderStroke(), lineWidth: 1)
                }
        )
        .compositingGroup()
        .shadow(color: .black.opacity(0.22), radius: 14, y: -3)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    private func tabButton(for tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            FeedbackManager.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(AppGradients.primary)
                            .frame(width: 40, height: 40)
                    }
                    Image(systemName: tab.iconName)
                        .font(.system(size: isSelected ? 18 : 20, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                }
                .frame(height: 40)

                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(isSelected ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(pressedTab == tab ? 0.92 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressedTab = tab }
                .onEnded { _ in pressedTab = nil }
        )
    }
}

struct MainTabContainerView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab)
                    case .wishlist:
                        WishlistView()
                    case .tools:
                        TravelToolsContainerView()
                    case .achievements:
                        AchievementsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                CustomTabBar(selectedTab: $selectedTab)
            }

            AchievementBannerContainer(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
