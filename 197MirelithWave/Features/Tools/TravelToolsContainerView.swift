import SwiftUI

enum TravelToolSection: String, CaseIterable, Identifiable {
    case essentials
    case units
    case emergency

    var id: String { rawValue }

    var title: String {
        switch self {
        case .essentials: return "Essentials"
        case .units: return "Units"
        case .emergency: return "Emergency"
        }
    }

    var iconName: String {
        switch self {
        case .essentials: return "globe.americas.fill"
        case .units: return "arrow.left.arrow.right"
        case .emergency: return "phone.fill"
        }
    }
}

struct TravelToolsContainerView: View {
    @State private var selectedSection: TravelToolSection = .essentials

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    toolSegmentBar

                    Group {
                        switch selectedSection {
                        case .essentials:
                            EssentialsView()
                        case .units:
                            UnitConverterView()
                        case .emergency:
                            EmergencyInfoView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(selectedSection.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var toolSegmentBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TravelToolSection.allCases) { section in
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
        .background(Color("AppBackground").opacity(0.5))
    }
}
