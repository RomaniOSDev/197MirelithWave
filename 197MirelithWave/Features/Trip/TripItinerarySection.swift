import SwiftUI

struct TripItinerarySection: View {
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    @State private var showAddDaySheet = false
    @State private var expandedDayIDs: Set<UUID> = []
    @State private var showAddActivityForDay: ItineraryDay?

    private var days: [ItineraryDay] {
        store.tripBundle(for: destinationID).itineraryDays.sorted { $0.dayNumber < $1.dayNumber }
    }

    var body: some View {
        VStack(spacing: 14) {
            if days.isEmpty {
                AppEmptyStateView(
                    iconName: "calendar",
                    title: "No Itinerary Yet",
                    message: "Plan your trip day by day with activities and schedules.",
                    buttonTitle: "Add First Day"
                ) {
                    showAddDaySheet = true
                }
                .padding(.top, 20)
            } else {
                ForEach(days) { day in
                    ItineraryDayCell(
                        day: day,
                        isExpanded: expandedDayIDs.contains(day.id),
                        onToggle: {
                            FeedbackManager.lightTap()
                            if expandedDayIDs.contains(day.id) {
                                expandedDayIDs.remove(day.id)
                            } else {
                                expandedDayIDs.insert(day.id)
                            }
                        },
                        onAddActivity: {
                            showAddActivityForDay = day
                        }
                    )
                    .padding(.horizontal, 16)
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteItineraryDay(destinationID: destinationID, day: day)
                        } label: {
                            Label("Delete Day", systemImage: "trash")
                        }
                    }
                }
            }

            PrimaryButton(title: "Add Day", iconName: "plus.circle.fill") {
                showAddDaySheet = true
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showAddDaySheet) {
            AddItineraryDaySheet(destinationID: destinationID)
                .environmentObject(store)
        }
        .sheet(item: $showAddActivityForDay) { day in
            AddItineraryActivitySheet(destinationID: destinationID, day: day)
                .environmentObject(store)
        }
    }
}

struct AddItineraryDaySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    @State private var title = ""
    @State private var titleError = ""
    @State private var shakeTitle = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 16) {
                    TextField("Day title (e.g. Airport, Hotel)", text: $title)
                        .padding(14)
                        .appInsetSurface(cornerRadius: 14)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .shake(trigger: $shakeTitle)
                    if !titleError.isEmpty {
                        Text(titleError).font(.caption).foregroundStyle(.red)
                    }
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Add Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { FeedbackManager.lightTap(); dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.foregroundStyle(Color("AppPrimary")).fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.fraction(0.35)])
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleError = "Title is required."
            shakeTitle = true
            FeedbackManager.warning()
            return
        }
        store.addItineraryDay(destinationID: destinationID, title: trimmed)
        FeedbackManager.success()
        dismiss()
    }
}

struct AddItineraryActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    let day: ItineraryDay

    @State private var title = ""
    @State private var timeLabel = ""
    @State private var notes = ""
    @State private var titleError = ""
    @State private var shakeTitle = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 12) {
                        fieldBlock("Activity") {
                            TextField("Museum visit", text: $title)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .shake(trigger: $shakeTitle)
                            if !titleError.isEmpty {
                                Text(titleError).font(.caption).foregroundStyle(.red)
                            }
                        }
                        fieldBlock("Time (optional)") {
                            TextField("09:00", text: $timeLabel)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        fieldBlock("Notes") {
                            TextField("Details...", text: $notes, axis: .vertical)
                                .lineLimit(2...4)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { FeedbackManager.lightTap(); dismiss() }
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.foregroundStyle(Color("AppPrimary")).fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func fieldBlock<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption.weight(.bold)).foregroundStyle(Color("AppTextSecondary"))
            VStack(alignment: .leading) { content() }
                .padding(14)
                .appInsetSurface(cornerRadius: 14)
        }
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleError = "Activity title is required."
            shakeTitle = true
            FeedbackManager.warning()
            return
        }
        let activity = ItineraryActivity(
            title: trimmed,
            timeLabel: timeLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.addItineraryActivity(destinationID: destinationID, dayID: day.id, activity: activity)
        FeedbackManager.success()
        dismiss()
    }
}
