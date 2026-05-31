import SwiftUI

struct TripDocumentsSection: View {
    @EnvironmentObject private var store: AppDataStore

    let destination: Destination
    @State private var showAddSheet = false
    @State private var newTitle = ""
    @State private var newExpiry: Date = Date()
    @State private var hasExpiry = false

    private var documents: [TravelDocument] {
        store.tripBundle(for: destination.id).documents
    }

    private var warnings: [TravelDocument] {
        store.documentsWithExpiryWarning(for: destination)
    }

    private var completionProgress: Double {
        guard !documents.isEmpty else { return 0 }
        return Double(documents.filter(\.checked).count) / Double(documents.count)
    }

    var body: some View {
        VStack(spacing: 14) {
            if !warnings.isEmpty {
                warningBanner
            }

            if !documents.isEmpty {
                AppCard(accentBorder: true) {
                    HStack(spacing: 14) {
                        ZStack {
                            AppProgressRing(progress: completionProgress, lineWidth: 4)
                                .frame(width: 48, height: 48)
                            Text("\(Int(completionProgress * 100))%")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color("AppPrimary"))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Documents Ready")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("\(documents.filter(\.checked).count)/\(documents.count) verified")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                    }
                    .padding(14)
                }
                .padding(.horizontal, 16)
            }

            if documents.isEmpty {
                AppEmptyStateView(
                    iconName: "doc.text.fill",
                    title: "No Documents",
                    message: "Add travel documents and track their expiry dates."
                )
                .padding(.top, 20)
            } else {
                ForEach(documents) { doc in
                    DocumentCell(
                        document: doc,
                        showWarning: warnings.contains(where: { $0.id == doc.id }),
                        onToggle: {
                            FeedbackManager.lightTap()
                            store.toggleDocument(destinationID: destination.id, document: doc)
                            if !doc.checked {
                                FeedbackManager.checklistComplete()
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }

            PrimaryButton(title: "Add Document", iconName: "plus.circle.fill") {
                showAddSheet = true
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showAddSheet) {
            addDocumentSheet
        }
    }

    private var warningBanner: some View {
        AppCard(accentBorder: true) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Expiry Warning", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                ForEach(warnings) { doc in
                    Text("• \(doc.title) — check expiry date")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }

    private var addDocumentSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 12) {
                    TextField("Document name", text: $newTitle)
                        .padding(14)
                        .appInsetSurface(cornerRadius: 14)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Toggle("Has expiry date", isOn: $hasExpiry)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 4)
                    if hasExpiry {
                        DatePicker("Expiry", selection: $newExpiry, displayedComponents: .date)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(14)
                            .appInsetSurface(cornerRadius: 14)
                    }
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        showAddSheet = false
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else {
                            FeedbackManager.warning()
                            return
                        }
                        store.addDocument(
                            destinationID: destination.id,
                            title: trimmed,
                            expiryDate: hasExpiry ? newExpiry : nil
                        )
                        FeedbackManager.success()
                        newTitle = ""
                        hasExpiry = false
                        showAddSheet = false
                    }
                    .foregroundStyle(Color("AppPrimary"))
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
