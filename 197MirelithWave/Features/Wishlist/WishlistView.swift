import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = WishlistViewModel()

    private var filteredDestinations: [Destination] {
        viewModel.filteredDestinations(from: store.destinations)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                if store.destinations.isEmpty {
                    emptyState
                } else {
                    destinationList
                }

                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
            }
            .navigationTitle("Travel Wishlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Add Destination", iconName: "plus.circle.fill") {
                    viewModel.openAdd()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color("AppBackground"), Color("AppBackground").opacity(0.92)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                DestinationFormView(
                    destination: viewModel.editingDestination,
                    onSave: { destination, isNew in
                        if isNew {
                            store.addDestination(destination)
                            FeedbackManager.mediumTap()
                            FeedbackManager.addDestinationSound()
                            SuccessFeedback.show(checkmark: $viewModel.showSuccessCheckmark)
                        } else {
                            store.updateDestination(destination)
                            FeedbackManager.mediumTap()
                            FeedbackManager.success()
                        }
                    }
                )
                .environmentObject(store)
            }
            .navigationDestination(for: Destination.self) { destination in
                TripDetailView(destination: destination)
                    .environmentObject(store)
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            AppEmptyStateView(
                iconName: "globe.americas.fill",
                title: "Your Travel Bucket Awaits!",
                message: "No destinations added yet. Start planning your dream trips.",
                buttonTitle: "Add Destination"
            ) {
                viewModel.openAdd()
            }
            .padding(.top, 60)
        }
    }

    private var destinationList: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppSearchField(text: $viewModel.searchText, placeholder: "Search destinations")
                    .padding(.horizontal, 16)

                filterBar

                if filteredDestinations.isEmpty {
                    AppEmptyStateView(
                        iconName: "magnifyingglass",
                        title: "No Results",
                        message: "No destinations match your search or filter."
                    )
                    .padding(.top, 20)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredDestinations) { destination in
                            let bundle = store.tripBundle(for: destination.id)
                            let total = bundle.packingItems.count
                            let checked = bundle.packingItems.filter(\.checked).count
                            let progress = total > 0 ? Double(checked) / Double(total) : 0

                            NavigationLink(value: destination) {
                                DestinationCell(
                                    destination: destination,
                                    itemCount: total,
                                    itineraryDays: bundle.itineraryDays.count,
                                    packingProgress: progress,
                                    isPulsing: viewModel.pulsingDestinationID == destination.id
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    FeedbackManager.mediumTap()
                                    store.toggleDestinationVisited(destination)
                                    if !destination.visited {
                                        viewModel.pulsingDestinationID = destination.id
                                        SuccessFeedback.show(checkmark: $viewModel.showSuccessCheckmark)
                                    }
                                } label: {
                                    Label(destination.visited ? "Mark Unvisited" : "Mark Visited", systemImage: "checkmark.circle")
                                }
                                Button {
                                    FeedbackManager.lightTap()
                                    viewModel.openEdit(destination)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    FeedbackManager.lightTap()
                                    store.deleteDestination(destination)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WishlistFilter.allCases) { filter in
                    AppFilterChip(
                        title: filter.title,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        FeedbackManager.lightTap()
                        viewModel.selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct DestinationFormView: View {
    @Environment(\.dismiss) private var dismiss

    let destination: Destination?
    let onSave: (Destination, Bool) -> Void

    @State private var name = ""
    @State private var country = ""
    @State private var notes = ""
    @State private var plannedDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var visited = false
    @State private var nameError = ""
    @State private var countryError = ""
    @State private var shakeName = false
    @State private var shakeCountry = false

    private var isNew: Bool { destination == nil }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    VStack(spacing: 14) {
                        formField(title: "Destination Name", error: nameError) {
                            TextField("e.g. Tokyo", text: $name)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .shake(trigger: $shakeName)
                        }
                        formField(title: "Country", error: countryError) {
                            TextField("e.g. Japan", text: $country)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .shake(trigger: $shakeCountry)
                        }
                        formCard {
                            DatePicker("Planned Date", selection: $plannedDate, displayedComponents: .date)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        formCard {
                            Toggle("Set return date", isOn: $hasEndDate)
                                .foregroundStyle(Color("AppTextPrimary"))
                            if hasEndDate {
                                DatePicker("Return Date", selection: $endDate, in: plannedDate..., displayedComponents: .date)
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                        formCard {
                            TextField("Notes", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        formCard {
                            Toggle("Visited", isOn: $visited)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(isNew ? "Add Destination" : "Edit Destination")
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                        .fontWeight(.bold)
                }
            }
            .onAppear {
                if let destination {
                    name = destination.name
                    country = destination.country
                    notes = destination.notes
                    plannedDate = destination.plannedDate
                    if let end = destination.endDate {
                        hasEndDate = true
                        endDate = end
                    }
                    visited = destination.visited
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func formField<Content: View>(title: String, error: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary"))
            formCard {
                content()
                if !error.isEmpty {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appInsetSurface(cornerRadius: 16)
    }

    private func save() {
        nameError = ""
        countryError = ""
        var hasError = false

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCountry = country.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.isEmpty {
            nameError = "Destination name is required."
            shakeName = true
            hasError = true
        }
        if trimmedCountry.isEmpty {
            countryError = "Country is required."
            shakeCountry = true
            hasError = true
        }

        if hasError {
            FeedbackManager.warning()
            return
        }

        let saved = Destination(
            id: destination?.id ?? UUID(),
            name: trimmedName,
            country: trimmedCountry,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            plannedDate: plannedDate,
            endDate: hasEndDate ? endDate : nil,
            visited: visited
        )

        onSave(saved, isNew)
        dismiss()
    }
}

extension Destination: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
