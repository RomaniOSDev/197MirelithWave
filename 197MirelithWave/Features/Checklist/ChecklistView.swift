import SwiftUI

struct ChecklistItemFormView: View {
    @Environment(\.dismiss) private var dismiss

    let item: ChecklistItem?
    let onSave: (ChecklistItem, Bool) -> Void

    @State private var title = ""
    @State private var titleError = ""
    @State private var shakeTitle = false

    private var isNew: Bool { item == nil }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Item name")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        TextField("Passport, Charger, Shoes...", text: $title)
                            .padding(14)
                            .appInsetSurface(cornerRadius: 14)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: $shakeTitle)
                        if !titleError.isEmpty {
                            Text(titleError).font(.caption).foregroundStyle(.red)
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle(isNew ? "Add Item" : "Edit Item")
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
                if let item { title = item.title }
            }
        }
        .presentationDetents([.fraction(0.35)])
    }

    private func save() {
        titleError = ""
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            titleError = "Item name is required."
            shakeTitle = true
            FeedbackManager.warning()
            return
        }

        let saved = ChecklistItem(
            id: item?.id ?? UUID(),
            title: trimmed,
            checked: item?.checked ?? false,
            order: item?.order ?? 0
        )
        onSave(saved, isNew)
        dismiss()
    }
}
