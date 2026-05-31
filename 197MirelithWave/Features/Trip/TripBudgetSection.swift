import SwiftUI

struct TripBudgetSection: View {
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    let country: String

    @State private var showAddSheet = false

    private var expenses: [TripExpense] {
        store.tripBundle(for: destinationID).expenses.sorted { $0.date > $1.date }
    }

    private var totalText: String {
        let base = store.baseCurrencyCode.isEmpty ? "USD" : store.baseCurrencyCode
        let total = store.totalExpenses(for: destinationID, convertedTo: base)
        return "\(base) \(String(format: "%.2f", total))"
    }

    var body: some View {
        VStack(spacing: 14) {
            AppCard(accentBorder: true) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total Spent")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text(totalText)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    Spacer()
                    AppIconBadge(iconName: "dollarsign.circle.fill", size: 52, iconSize: 24, style: .primary)
                }
                .padding(16)
            }
            .padding(.horizontal, 16)

            if expenses.isEmpty {
                AppEmptyStateView(
                    iconName: "creditcard.fill",
                    title: "No Expenses Yet",
                    message: "Track transport, food, hotel and other trip costs.",
                    buttonTitle: "Add Expense"
                ) {
                    showAddSheet = true
                }
                .padding(.top, 12)
            } else {
                categoryBreakdown
                ForEach(expenses) { expense in
                    ExpenseCell(expense: expense)
                        .padding(.horizontal, 16)
                        .contextMenu {
                            Button(role: .destructive) {
                                store.deleteExpense(destinationID: destinationID, expense: expense)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }

            PrimaryButton(title: "Add Expense", iconName: "plus.circle.fill") {
                showAddSheet = true
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showAddSheet) {
            AddExpenseSheet(destinationID: destinationID, defaultCurrency: defaultCurrency)
                .environmentObject(store)
        }
    }

    private var defaultCurrency: String {
        if !store.baseCurrencyCode.isEmpty { return store.baseCurrencyCode }
        return "USD"
    }

    private var categoryBreakdown: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ExpenseCategory.allCases) { category in
                    let count = expenses.filter { $0.category == category }.count
                    if count > 0 {
                        AppTagPill(text: "\(category.title) · \(count)", style: .accent)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let destinationID: UUID
    let defaultCurrency: String

    @State private var category: ExpenseCategory = .food
    @State private var amount = ""
    @State private var currencyCode = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var amountError = ""
    @State private var shakeAmount = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 12) {
                        field("Category") {
                            Picker("Category", selection: $category) {
                                ForEach(ExpenseCategory.allCases) { cat in
                                    Label(cat.title, systemImage: cat.iconName).tag(cat)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        field("Amount") {
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .shake(trigger: $shakeAmount)
                            if !amountError.isEmpty {
                                Text(amountError).font(.caption).foregroundStyle(.red)
                            }
                        }
                        field("Currency") {
                            Picker("Currency", selection: $currencyCode) {
                                ForEach(CurrencyCatalog.defaultRates) { rate in
                                    Text(rate.code).tag(rate.code)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AppPrimary"))
                        }
                        field("Note") {
                            TextField("Optional note", text: $note)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        field("Date") {
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Expense")
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
            .onAppear { currencyCode = defaultCurrency }
        }
        .presentationDetents([.medium, .large])
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.bold)).foregroundStyle(Color("AppTextSecondary"))
            VStack { content() }
                .padding(14)
                .appInsetSurface(cornerRadius: 14)
        }
    }

    private func save() {
        guard let value = Double(amount.trimmingCharacters(in: .whitespacesAndNewlines)), value > 0 else {
            amountError = "Enter a valid amount."
            shakeAmount = true
            FeedbackManager.warning()
            return
        }
        let expense = TripExpense(
            category: category,
            amount: value,
            currencyCode: currencyCode,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date
        )
        store.addExpense(destinationID: destinationID, expense: expense)
        FeedbackManager.success()
        dismiss()
    }
}
