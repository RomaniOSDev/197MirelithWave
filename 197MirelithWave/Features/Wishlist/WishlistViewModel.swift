import Combine
import Foundation

enum WishlistFilter: String, CaseIterable, Identifiable {
    case all
    case upcoming
    case visited
    case unvisited

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .upcoming: return "Upcoming"
        case .visited: return "Visited"
        case .unvisited: return "Unvisited"
        }
    }
}

final class WishlistViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var editingDestination: Destination?
    @Published var showSuccessCheckmark = false
    @Published var pulsingDestinationID: UUID?
    @Published var searchText = ""
    @Published var selectedFilter: WishlistFilter = .all

    func openAdd() {
        editingDestination = nil
        showAddSheet = true
    }

    func openEdit(_ destination: Destination) {
        editingDestination = destination
        showAddSheet = true
    }

    func filteredDestinations(from all: [Destination]) -> [Destination] {
        var result = all

        switch selectedFilter {
        case .all:
            break
        case .upcoming:
            result = result.filter { !$0.visited && TripCountdownHelper.daysUntil($0.plannedDate) >= 0 }
        case .visited:
            result = result.filter(\.visited)
        case .unvisited:
            result = result.filter { !$0.visited }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(query)
                    || $0.country.lowercased().contains(query)
                    || $0.notes.lowercased().contains(query)
            }
        }

        return result.sorted { $0.plannedDate < $1.plannedDate }
    }
}
