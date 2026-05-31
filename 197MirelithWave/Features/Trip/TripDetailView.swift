import SwiftUI

enum TripDetailSection: String, CaseIterable, Identifiable {
    case overview
    case packing
    case itinerary
    case documents
    case budget

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .packing: return "Packing"
        case .itinerary: return "Itinerary"
        case .documents: return "Documents"
        case .budget: return "Budget"
        }
    }

    var iconName: String {
        switch self {
        case .overview: return "info.circle.fill"
        case .packing: return "suitcase.fill"
        case .itinerary: return "calendar"
        case .documents: return "doc.text.fill"
        case .budget: return "dollarsign.circle.fill"
        }
    }
}

struct TripDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    let destination: Destination
    @State private var selectedSection: TripDetailSection = .overview
    @State private var showEditSheet = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var showDuplicateSheet = false
    @State private var showSuccessCheckmark = false

    private var bundle: TripBundle {
        store.tripBundle(for: destination.id)
    }

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                sectionPicker

                ScrollView {
                    switch selectedSection {
                    case .overview:
                        TripOverviewSection(
                            destination: destination,
                            bundle: bundle,
                            onExportText: exportText,
                            onExportPDF: exportPDF,
                            onDuplicate: { showDuplicateSheet = true },
                            onEdit: { showEditSheet = true }
                        )
                    case .packing:
                        TripPackingSection(destinationID: destination.id, showSuccess: $showSuccessCheckmark)
                    case .itinerary:
                        TripItinerarySection(destinationID: destination.id)
                    case .documents:
                        TripDocumentsSection(destination: destination)
                    case .budget:
                        TripBudgetSection(destinationID: destination.id, country: destination.country)
                    }
                }
            }

            SuccessCheckmarkOverlay(isVisible: $showSuccessCheckmark)
        }
        .navigationTitle(destination.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        FeedbackManager.lightTap()
                        exportText()
                    } label: {
                        Label("Share as Text", systemImage: "doc.text")
                    }
                    Button {
                        FeedbackManager.lightTap()
                        exportPDF()
                    } label: {
                        Label("Share as PDF", systemImage: "doc.richtext")
                    }
                    Button {
                        FeedbackManager.lightTap()
                        showDuplicateSheet = true
                    } label: {
                        Label("Copy Packing List", systemImage: "doc.on.doc")
                    }
                    Button {
                        FeedbackManager.lightTap()
                        showEditSheet = true
                    } label: {
                        Label("Edit Destination", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            DestinationFormView(destination: destination) { updated, _ in
                store.updateDestination(updated)
                FeedbackManager.success()
            }
            .environmentObject(store)
        }
        .sheet(isPresented: $showDuplicateSheet) {
            DuplicatePackingSheet(targetDestination: destination)
                .environmentObject(store)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TripDetailSection.allCases) { section in
                    AppSegmentTab(
                        title: section.title,
                        iconName: section.iconName,
                        isSelected: selectedSection == section
                    ) {
                        FeedbackManager.lightTap()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedSection = section
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color("AppBackground").opacity(0.6))
    }

    private func exportText() {
        let text = TripExportService.generateText(destination: destination, bundle: bundle, store: store)
        shareItems = [text]
        showShareSheet = true
        FeedbackManager.success()
    }

    private func exportPDF() {
        if let url = TripExportService.generatePDF(destination: destination, bundle: bundle, store: store) {
            shareItems = [url]
            showShareSheet = true
            FeedbackManager.success()
        }
    }
}

struct TripOverviewSection: View {
    @EnvironmentObject private var store: AppDataStore

    let destination: Destination
    let bundle: TripBundle
    let onExportText: () -> Void
    let onExportPDF: () -> Void
    let onDuplicate: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            overviewCard
            timezoneCard
            quickActions
        }
        .padding(16)
    }

    private var overviewCard: some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    AppIconBadge(iconName: "mappin.and.ellipse", size: 48, iconSize: 22, style: .primary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(destination.country)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(destination.plannedDate.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(Color("AppAccent"))
                    }
                    Spacer()
                    if destination.visited {
                        AppTagPill(text: "Visited", style: .accent)
                    }
                }

                if let countdown = TripCountdownHelper.message(for: destination) {
                    HStack(spacing: 10) {
                        AppIconBadge(iconName: "clock.fill", size: 36, iconSize: 14, style: .warning)
                        Text(countdown)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color("AppBackground").opacity(0.4))
                    )
                }

                if let end = bundle.endDate ?? destination.endDate {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text("Return: \(end.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                if !destination.notes.isEmpty {
                    Text(destination.notes)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .padding(.top, 4)
                }

                HStack(spacing: 10) {
                    AppStatTile(value: "\(bundle.packingItems.count)", label: "Items", iconName: "suitcase.fill")
                    AppStatTile(value: "\(bundle.itineraryDays.count)", label: "Days", iconName: "calendar")
                    AppStatTile(value: "\(bundle.expenses.count)", label: "Expenses", iconName: "dollarsign.circle")
                }
            }
            .padding(16)
        }
    }

    private var timezoneCard: some View {
        Group {
            if let tz = TimeZoneCatalog.info(forCountry: destination.country) {
                AppCard {
                    VStack(alignment: .leading, spacing: 14) {
                        AppSectionHeader(title: "Time Zone", subtitle: "Local time at destination")

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Local time")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text(TimeZoneCatalog.currentTime(in: tz.timeZoneIdentifier))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color("AppPrimary"))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("From home")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                let diff = TimeZoneCatalog.hourDifference(
                                    from: store.homeTimeZoneIdentifier,
                                    to: tz.timeZoneIdentifier
                                )
                                Text(diff >= 0 ? "+\(diff)h" : "\(diff)h")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color("AppAccent"))
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 10) {
            PrimaryButton(title: "Share Trip Summary", iconName: "square.and.arrow.up") { onExportText() }
            PrimaryButton(title: "Export PDF", iconName: "doc.richtext", style: .secondary) { onExportPDF() }
            PrimaryButton(title: "Copy Packing List", iconName: "doc.on.doc", style: .ghost) { onDuplicate() }
        }
    }
}

struct DuplicatePackingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let targetDestination: Destination

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.destinations.filter { $0.id != targetDestination.id }) { source in
                            Button {
                                FeedbackManager.mediumTap()
                                store.duplicateDestination(from: source.id, to: targetDestination.id)
                                FeedbackManager.success()
                                dismiss()
                            } label: {
                                DuplicateTripCell(
                                    name: source.name,
                                    itemCount: store.tripBundle(for: source.id).packingItems.count
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Copy Packing List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
