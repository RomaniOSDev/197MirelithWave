import SwiftUI

struct EmergencyInfoView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var searchText = ""
    @State private var expandedCountry: String?

    private var filteredEntries: [EmergencyInfo] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty { return EmergencyInfoCatalog.entries }
        return EmergencyInfoCatalog.entries.filter {
            $0.country.lowercased().contains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                AppSectionHeader(
                    title: "Emergency Info",
                    subtitle: "Offline reference for 40+ countries"
                )
                .padding(.horizontal, 16)

                AppSearchField(text: $searchText, placeholder: "Search country")
                    .padding(.horizontal, 16)

                if filteredEntries.isEmpty {
                    AppEmptyStateView(
                        iconName: "phone.fill",
                        title: "No Results",
                        message: "Try a different country name."
                    )
                    .padding(.top, 20)
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredEntries) { info in
                            EmergencyInfoCell(
                                info: info,
                                isExpanded: expandedCountry == info.country,
                                onTap: {
                                    FeedbackManager.lightTap()
                                    if expandedCountry == info.country {
                                        expandedCountry = nil
                                    } else {
                                        expandedCountry = info.country
                                        store.recordEmergencyInfoViewed()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 12)
            .padding(.bottom, 24)
        }
    }
}
