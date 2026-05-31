import SwiftUI

struct TripPackingSection: View {
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    @Binding var showSuccess: Bool

    @State private var showAddSheet = false
    @State private var editingItem: ChecklistItem?
    @State private var showTemplateSheet = false
    @State private var editMode: EditMode = .inactive
    @State private var pulsingItemID: UUID?

    private var items: [ChecklistItem] {
        store.sortedPackingItems(for: destinationID)
    }

    private var packingProgress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(items.filter(\.checked).count) / Double(items.count)
    }

    var body: some View {
        VStack(spacing: 16) {
            if !items.isEmpty {
                progressHeader
            }

            if items.isEmpty {
                AppEmptyStateView(
                    iconName: "suitcase.fill",
                    title: "No Items Yet. Start Packing!",
                    message: "Add items manually or apply a ready-made template.",
                    buttonTitle: "Browse Templates"
                ) {
                    showTemplateSheet = true
                }
                .padding(.top, 20)
            } else {
                List {
                    ForEach(items) { item in
                        ChecklistItemCell(
                            title: item.title,
                            isChecked: item.checked,
                            showDragHandle: editMode == .active,
                            isPulsing: pulsingItemID == item.id
                        ) {
                            let wasChecked = item.checked
                            store.togglePackingItem(destinationID: destinationID, item: item)
                            if !wasChecked {
                                FeedbackManager.checklistComplete()
                                pulsingItemID = item.id
                                SuccessFeedback.show(checkmark: $showSuccess)
                            } else {
                                FeedbackManager.lightTap()
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                FeedbackManager.lightTap()
                                store.deletePackingItem(destinationID: destinationID, item: item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                FeedbackManager.lightTap()
                                editingItem = item
                                showAddSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(Color("AppAccent"))
                        }
                    }
                    .onMove { source, destination in
                        store.movePackingItems(destinationID: destinationID, from: source, to: destination)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
            }

            actionButtons
        }
        .padding(.bottom, 16)
        .sheet(isPresented: $showAddSheet) {
            ChecklistItemFormView(item: editingItem) { item, isNew in
                if isNew {
                    store.addPackingItem(destinationID: destinationID, title: item.title)
                } else {
                    store.updatePackingItem(destinationID: destinationID, item: item)
                }
                FeedbackManager.success()
                SuccessFeedback.show(checkmark: $showSuccess)
            }
            .onDisappear { editingItem = nil }
        }
        .sheet(isPresented: $showTemplateSheet) {
            PackingTemplateSheet(destinationID: destinationID, showSuccess: $showSuccess)
                .environmentObject(store)
        }
    }

    private var progressHeader: some View {
        AppCard(accentBorder: true) {
            HStack(spacing: 16) {
                ZStack {
                    AppProgressRing(progress: packingProgress, lineWidth: 5)
                        .frame(width: 56, height: 56)
                    Text("\(Int(packingProgress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Packing Progress")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(items.filter(\.checked).count) of \(items.count) items packed")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
            }
            .padding(14)
        }
        .padding(.horizontal, 16)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                PrimaryButton(title: "Add Item", iconName: "plus", style: .primary) {
                    editingItem = nil
                    showAddSheet = true
                }
                PrimaryButton(title: "Templates", iconName: "square.grid.2x2", style: .secondary) {
                    showTemplateSheet = true
                }
            }
            if items.contains(where: \.checked) {
                PrimaryButton(title: "Clear Completed", iconName: "trash", style: .ghost) {
                    FeedbackManager.mediumTap()
                    store.clearCompletedPackingItems(destinationID: destinationID)
                    SuccessFeedback.show(checkmark: $showSuccess)
                }
            }
            Button {
                FeedbackManager.lightTap()
                withAnimation { editMode = editMode == .active ? .inactive : .active }
            } label: {
                Text(editMode == .active ? "Done Reordering" : "Reorder Items")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
}

struct PackingTemplateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    @Binding var showSuccess: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(PackingTemplate.allCases) { template in
                            Button {
                                FeedbackManager.mediumTap()
                                store.applyPackingTemplate(destinationID: destinationID, template: template)
                                FeedbackManager.success()
                                SuccessFeedback.show(checkmark: $showSuccess)
                                dismiss()
                            } label: {
                                TemplateCell(template: template)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Packing Templates")
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
