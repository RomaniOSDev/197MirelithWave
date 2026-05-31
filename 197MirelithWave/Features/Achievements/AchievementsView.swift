import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockProgress: Double {
        guard !Achievement.all.isEmpty else { return 0 }
        return Double(store.unlockedAchievementCount()) / Double(Achievement.all.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard

                        AppSectionHeader(
                            title: "All Badges",
                            subtitle: "\(store.unlockedAchievementCount()) of \(Achievement.all.count) unlocked"
                        )

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Achievement.all) { achievement in
                                AchievementCell(
                                    achievement: achievement,
                                    isUnlocked: store.isAchievementUnlocked(achievement.id),
                                    unlockedDate: store.achievementsUnlocked[achievement.id]
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var summaryCard: some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    ZStack {
                        AppProgressRing(progress: unlockProgress, lineWidth: 5)
                            .frame(width: 64, height: 64)
                        Text("\(Int(unlockProgress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Progress")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("\(store.unlockedAchievementCount()) badges earned")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                HStack(spacing: 10) {
                    AppStatTile(value: "\(store.destinationsAdded)", label: "Places", iconName: "globe")
                    AppStatTile(value: "\(store.tripsCompleted)", label: "Trips", iconName: "airplane")
                    AppStatTile(value: store.mostPlannedCountry, label: "Top", iconName: "star.fill")
                }

                HStack(spacing: 10) {
                    AppStatTile(value: "\(store.tripsThisYear)", label: "This Year", iconName: "calendar")
                    AppStatTile(value: "\(store.longestChecklistCount)", label: "Max Pack", iconName: "bag.fill")
                    AppStatTile(value: "\(store.budgetEntriesAdded)", label: "Expenses", iconName: "creditcard")
                }
            }
            .padding(16)
        }
    }
}
