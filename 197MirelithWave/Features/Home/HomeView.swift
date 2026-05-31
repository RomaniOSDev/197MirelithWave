import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: MainTab
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAddDestination = false
    @State private var navigationPath = NavigationPath()

    private var nextTrip: Destination? {
        viewModel.nextTrip(from: store.destinations)
    }

    private var packingStats: (checked: Int, total: Int, progress: Double) {
        viewModel.aggregatePackingProgress(store: store)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        heroHeader
                        widgetGrid
                        quickActionsSection
                        upcomingTripsSection
                        travelTipWidget
                        documentsAlertWidget
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.bottom, 100)
                }
            }
            .frame(maxWidth: .infinity)
            .navigationBarHidden(true)
            .navigationDestination(for: Destination.self) { destination in
                TripDetailView(destination: destination)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showAddDestination) {
                DestinationFormView(destination: nil) { destination, _ in
                    store.addDestination(destination)
                    FeedbackManager.mediumTap()
                    FeedbackManager.addDestinationSound()
                }
                .environmentObject(store)
            }
        }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color("AppBackground").opacity(0.1), Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.greeting)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                        Text("Ready for your next journey?")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    streakBadge
                }

                VStack(alignment: .leading, spacing: 6) {
                    AppTagPill(
                        text: Date().formatted(date: .abbreviated, time: .omitted),
                        style: .muted
                    )
                    AppTagPill(
                        text: "\(store.destinations.count) trips planned",
                        style: .primary
                    )
                }
            }
            .padding(20)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 220)
        .background {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
        }
        .clipped()
    }

    private var streakBadge: some View {
        VStack(spacing: 2) {
            AppIconBadge(iconName: "flame.fill", size: 44, iconSize: 20, style: .warning)
            Text("\(store.streakDays)d")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
        }
    }

    // MARK: - Widget Grid

    private var widgetGrid: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                nextTripWidget
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .layoutPriority(1)

                packingWidget
                    .layoutPriority(0)
            }
            .padding(.horizontal, 16)
            .frame(minWidth: 0, maxWidth: .infinity)

            statsWidgetRow
        }
    }

    private var nextTripWidget: some View {
        Button {
            FeedbackManager.lightTap()
            if let trip = nextTrip {
                navigationPath.append(trip)
            } else {
                showAddDestination = true
            }
        } label: {
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, Color("AppBackground").opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 8) {
                    AppTagPill(text: "Next Trip", style: .countdown)

                    if let trip = nextTrip {
                        Text(trip.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(trip.country)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                        if let countdown = TripCountdownHelper.message(for: trip) {
                            Text(countdown)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color("AppAccent"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    } else {
                        Text("Add a destination")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("Start planning today")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .padding(14)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 180)
            .background {
                Image("WidgetDestination")
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppGradients.borderStroke(accent: true), lineWidth: 1.5)
            )
            .compositingGroup()
            .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var packingWidget: some View {
        Button {
            FeedbackManager.lightTap()
            if let trip = nextTrip {
                navigationPath.append(trip)
            } else {
                selectedTab = .wishlist
            }
        } label: {
            ZStack {
                LinearGradient(
                    colors: [.clear, Color("AppBackground").opacity(0.88)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(spacing: 8) {
                    Spacer(minLength: 0)
                    ZStack {
                        AppProgressRing(progress: packingStats.progress, lineWidth: 4)
                            .frame(width: 46, height: 46)
                        Text("\(Int(packingStats.progress * 100))%")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    Text("Packing")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Text("\(packingStats.checked)/\(packingStats.total)")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
            .frame(width: 118, height: 180)
            .background {
                Image("WidgetPacking")
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppGradients.borderStroke(accent: true), lineWidth: 1.5)
            )
            .compositingGroup()
            .shadow(color: Color("AppAccent").opacity(0.2), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private var statsWidgetRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                HomeMiniWidget(
                    icon: "airplane.departure",
                    value: "\(store.tripsThisYear)",
                    label: "Trips",
                    style: .primary
                ) { selectedTab = .wishlist }

                HomeMiniWidget(
                    icon: "star.fill",
                    value: "\(store.unlockedAchievementCount())",
                    label: "Badges",
                    style: .accent
                ) { selectedTab = .achievements }

                HomeMiniWidget(
                    icon: "dollarsign.circle.fill",
                    value: store.baseCurrencyCode.isEmpty ? "—" : store.baseCurrencyCode,
                    label: "Currency",
                    style: .primary
                ) { selectedTab = .tools }

                HomeMiniWidget(
                    icon: "calendar.badge.clock",
                    value: "\(store.totalItineraryDays)",
                    label: "Itinerary",
                    style: .accent
                ) {
                    if let trip = nextTrip { navigationPath.append(trip) }
                    else { selectedTab = .wishlist }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions", subtitle: "Jump to key features")
                .padding(.horizontal, 16)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                HomeQuickAction(icon: "plus.circle.fill", title: "Add Trip", color: Color("AppPrimary")) {
                    showAddDestination = true
                }
                HomeQuickAction(icon: "suitcase.fill", title: "Packing", color: Color("AppAccent")) {
                    if let trip = nextTrip { navigationPath.append(trip) }
                    else { selectedTab = .wishlist }
                }
                HomeQuickAction(icon: "globe.americas.fill", title: "Currency", color: Color("AppPrimary")) {
                    selectedTab = .tools
                }
                HomeQuickAction(icon: "phone.fill", title: "Emergency", color: Color("AppAccent")) {
                    selectedTab = .tools
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Upcoming

    private var upcomingTripsSection: some View {
        let trips = viewModel.upcomingTrips(from: store.destinations)

        return Group {
            if !trips.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(
                        title: "Upcoming Trips",
                        subtitle: "\(trips.count) on your calendar",
                        actionTitle: "See All"
                    ) {
                        selectedTab = .wishlist
                    }
                    .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(trips) { trip in
                                Button {
                                    FeedbackManager.lightTap()
                                    navigationPath.append(trip)
                                } label: {
                                    HomeUpcomingTripCard(
                                        destination: trip,
                                        progress: viewModel.packingProgress(for: trip, store: store)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Tip

    private var travelTipWidget: some View {
        let tip = viewModel.tipOfTheDay()

        return AppCard(accentBorder: true) {
            HStack(alignment: .top, spacing: 14) {
                AppIconBadge(iconName: tip.iconName, size: 48, iconSize: 22, style: .primary)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Travel Tip")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                    Text(tip.text)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.horizontal, 16)
    }

    // MARK: - Documents Alert

    private var documentsAlertWidget: some View {
        let alerts = viewModel.documentsNeedingAttention(store: store)

        return Group {
            if !alerts.isEmpty {
                AppCard(accentBorder: true) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Document Alerts", systemImage: "exclamationmark.triangle.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color("AppPrimary"))

                        ForEach(alerts, id: \.destination.id) { alert in
                            Button {
                                FeedbackManager.lightTap()
                                navigationPath.append(alert.destination)
                            } label: {
                                HStack(spacing: 8) {
                                    Text(alert.destination.name)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    Spacer(minLength: 4)
                                    AppTagPill(text: "\(alert.count) expiring", style: .countdown)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Subviews

private struct HomeMiniWidget: View {
    let icon: String
    let value: String
    let label: String
    let style: AppIconBadge.BadgeStyle
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            VStack(spacing: 8) {
                AppIconBadge(iconName: icon, size: 36, iconSize: 16, style: style)
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(width: 88)
            .padding(.vertical, 14)
            .appCellSurface(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeQuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color("AppBackground"))
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.75)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.5))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCellSurface(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeUpcomingTripCard: View {
    let destination: Destination
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AppIconBadge(iconName: "mappin.circle.fill", size: 32, iconSize: 14, style: .primary)
                Spacer()
                ZStack {
                    AppProgressRing(progress: progress, lineWidth: 3)
                        .frame(width: 28, height: 28)
                }
            }

            Text(destination.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(destination.country)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)

            if let countdown = TripCountdownHelper.message(for: destination) {
                AppTagPill(text: countdown, style: .countdown)
            }
        }
        .padding(14)
        .frame(width: 150)
        .appCellSurface(cornerRadius: 18, accentBorder: true)
    }
}
