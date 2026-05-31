import SwiftUI

struct EssentialsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = EssentialsViewModel()

    var body: some View {
        ZStack {
            if store.baseCurrencyCode.isEmpty {
                emptyState
            } else {
                essentialsContent
            }

            SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheckmark)
        }
        .sheet(isPresented: $viewModel.showCurrencySheet) {
            BaseCurrencyPickerView { code in
                store.setBaseCurrency(code)
                FeedbackManager.mediumTap()
                FeedbackManager.setCurrencySound()
                SuccessFeedback.show(checkmark: $viewModel.showSuccessCheckmark)
            }
        }
        .onAppear {
            if !store.baseCurrencyCode.isEmpty {
                store.refreshCurrencyRates()
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            AppEmptyStateView(
                iconName: "dollarsign.circle.fill",
                title: "Select your base currency",
                message: "Set up currency conversions and explore essential travel phrases.",
                buttonTitle: "Set Base Currency"
            ) {
                viewModel.showCurrencySheet = true
            }
            .padding(.top, 40)
        }
    }

    private var essentialsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                currencySection
                phrasesSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
    }

    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            AppSectionHeader(
                title: "Currency Rates",
                subtitle: "Swipe to browse conversions",
                actionTitle: store.baseCurrencyCode
            ) {
                viewModel.showCurrencySheet = true
            }

            HStack(spacing: 10) {
                AppIconBadge(iconName: "number", size: 36, iconSize: 14, style: .muted)
                TextField("Amount to convert", text: $viewModel.conversionAmount)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .appInsetSurface(cornerRadius: 14)

            TabView(selection: $viewModel.selectedRateIndex) {
                ForEach(Array(store.currencyRatesTable.enumerated()), id: \.offset) { index, rate in
                    CurrencyRateCell(
                        rate: rate,
                        baseCode: store.baseCurrencyCode,
                        amount: Double(viewModel.conversionAmount) ?? 0
                    )
                    .tag(index)
                    .onTapGesture {
                        FeedbackManager.lightTap()
                        store.recordConversion()
                    }
                }
            }
            .frame(height: 190)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }

    private var phrasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Travel Phrases", subtitle: "Tap to expand translations")

            ForEach(PhraseCatalog.phrases) { phrase in
                PhraseCell(
                    phrase: phrase,
                    isExpanded: viewModel.expandedPhraseIDs.contains(phrase.id),
                    onTap: {
                        FeedbackManager.lightTap()
                        viewModel.togglePhrase(phrase.id)
                        store.recordPhraseViewed(phrase.id)
                    }
                )
            }
        }
    }
}

struct BaseCurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(CurrencyCatalog.defaultRates) { currency in
                            Button {
                                FeedbackManager.lightTap()
                                onSelect(currency.code)
                                dismiss()
                            } label: {
                                AppCard {
                                    CurrencyPickerCell(currency: currency)
                                        .padding(12)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Base Currency")
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
