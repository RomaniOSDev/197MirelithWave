import SwiftUI

struct AchievementBannerView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -120

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(iconName: achievement.iconName, size: 44, iconSize: 20, style: .primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Text(achievement.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppGradients.banner)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(AppGradients.borderStroke(accent: true), lineWidth: 1.5)
                }
        )
        .compositingGroup()
        .shadow(color: Color("AppPrimary").opacity(0.25), radius: 10, y: 5)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            FeedbackManager.achievementUnlocked()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 60
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -120
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}

struct AchievementBannerContainer: View {
    @ObservedObject var store: AppDataStore

    var body: some View {
        VStack {
            if let next = store.pendingAchievementUnlocks.first {
                AchievementBannerView(achievement: next) {
                    if !store.pendingAchievementUnlocks.isEmpty {
                        store.pendingAchievementUnlocks.removeFirst()
                    }
                }
            }
            Spacer()
        }
        .zIndex(100)
    }
}
