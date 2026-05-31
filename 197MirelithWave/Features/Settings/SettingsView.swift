import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 20) {
                        statsCard
                        settingsList

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackManager.lightTap() }
                Button("Reset", role: .destructive) {
                    FeedbackManager.mediumTap()
                    store.resetAllData()
                }
            } message: {
                Text("This will permanently delete all destinations, checklists, settings, and progress. This action cannot be undone.")
            }
        }
    }

    private func openLink(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private var statsCard: some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 16) {
                AppSectionHeader(title: "Stats", subtitle: "Your travel activity")

                HStack(spacing: 10) {
                    AppStatTile(value: "\(store.totalSessionsCompleted)", label: "Actions", iconName: "hand.tap.fill")
                    AppStatTile(value: "\(store.totalMinutesUsed)", label: "Minutes", iconName: "clock.fill")
                    AppStatTile(value: "\(store.streakDays)", label: "Streak", iconName: "flame.fill")
                }

                HStack(spacing: 10) {
                    AppStatTile(value: "\(store.destinations.count)", label: "Entries", iconName: "globe")
                    AppStatTile(value: "\(store.unlockedAchievementCount())", label: "Badges", iconName: "star.fill")
                    AppStatTile(value: "\(store.tripsThisYear)", label: "This Year", iconName: "calendar")
                }

                Divider().background(Color("AppTextSecondary").opacity(0.15))

                AppSectionHeader(title: "Insights", subtitle: nil)

                insightRow("Most Planned Country", store.mostPlannedCountry, icon: "mappin.circle.fill")
                insightRow("Longest Checklist", "\(store.longestChecklistCount) items", icon: "suitcase.fill")
                insightRow("Itinerary Days", "\(store.totalItineraryDays)", icon: "calendar.badge.clock")
                insightRow("Budget Entries", "\(store.totalBudgetEntries)", icon: "dollarsign.circle.fill")

                homeTimeZoneSection
            }
            .padding(16)
        }
    }

    private var homeTimeZoneSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider().background(Color("AppTextSecondary").opacity(0.15))
            AppSectionHeader(title: "Home Time Zone", subtitle: "Used for time difference")

            Picker("Home Time Zone", selection: Binding(
                get: { store.homeTimeZoneIdentifier },
                set: { newValue in
                    FeedbackManager.lightTap()
                    store.homeTimeZoneIdentifier = newValue
                }
            )) {
                ForEach(TimeZoneCatalog.homeTimeZones, id: \.identifier) { tz in
                    Text(tz.name).tag(tz.identifier)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("AppPrimary"))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appInsetSurface(cornerRadius: 12)
        }
    }

    private func insightRow(_ label: String, _ value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            AppIconBadge(iconName: icon, size: 32, iconSize: 14, style: .muted)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var settingsList: some View {
        AppCard {
            VStack(spacing: 0) {
                SettingsRowCell(title: "Rate Us", iconName: "star.fill") {
                    FeedbackManager.lightTap()
                    rateApp()
                }
                Divider().background(Color("AppTextSecondary").opacity(0.12)).padding(.leading, 54)
                SettingsRowCell(title: "Privacy Policy", iconName: "hand.raised.fill") {
                    FeedbackManager.lightTap()
                    openLink(.privacyPolicy)
                }
                Divider().background(Color("AppTextSecondary").opacity(0.12)).padding(.leading, 54)
                SettingsRowCell(title: "Terms of Service", iconName: "doc.text.fill") {
                    FeedbackManager.lightTap()
                    openLink(.termsOfService)
                }
                Divider().background(Color("AppTextSecondary").opacity(0.12)).padding(.leading, 54)
                SettingsRowCell(title: "Reset All Data", iconName: "trash.fill", isDestructive: true) {
                    FeedbackManager.lightTap()
                    showResetAlert = true
                }
            }
        }
    }
}
