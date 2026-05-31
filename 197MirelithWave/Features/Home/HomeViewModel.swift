import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    struct TravelTip: Identifiable {
        let id: Int
        let text: String
        let iconName: String
    }

    static let tips: [TravelTip] = [
        TravelTip(id: 0, text: "Roll clothes instead of folding to save suitcase space.", iconName: "tshirt.fill"),
        TravelTip(id: 1, text: "Keep digital copies of passport and insurance offline.", iconName: "doc.fill"),
        TravelTip(id: 2, text: "Pack a power adapter for your destination region.", iconName: "bolt.fill"),
        TravelTip(id: 3, text: "Check document expiry dates 90 days before departure.", iconName: "calendar.badge.clock"),
        TravelTip(id: 4, text: "Save emergency numbers before you leave home.", iconName: "phone.fill"),
        TravelTip(id: 5, text: "Set your base currency in Tools before traveling.", iconName: "dollarsign.circle.fill"),
        TravelTip(id: 6, text: "Build your itinerary day-by-day inside each trip.", iconName: "map.fill")
    ]

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    func nextTrip(from destinations: [Destination]) -> Destination? {
        let upcoming = destinations
            .filter { !$0.visited }
            .sorted { $0.plannedDate < $1.plannedDate }
        return upcoming.first
    }

    func upcomingTrips(from destinations: [Destination], limit: Int = 6) -> [Destination] {
        destinations
            .filter { !$0.visited }
            .sorted { $0.plannedDate < $1.plannedDate }
            .prefix(limit)
            .map { $0 }
    }

    func packingProgress(for destination: Destination, store: AppDataStore) -> Double {
        let items = store.tripBundle(for: destination.id).packingItems
        guard !items.isEmpty else { return 0 }
        return Double(items.filter(\.checked).count) / Double(items.count)
    }

    func aggregatePackingProgress(store: AppDataStore) -> (checked: Int, total: Int, progress: Double) {
        var checked = 0
        var total = 0
        for destination in store.destinations where !destination.visited {
            let items = store.tripBundle(for: destination.id).packingItems
            checked += items.filter(\.checked).count
            total += items.count
        }
        let progress = total > 0 ? Double(checked) / Double(total) : 0
        return (checked, total, progress)
    }

    func documentsNeedingAttention(store: AppDataStore) -> [(destination: Destination, count: Int)] {
        store.destinations.compactMap { destination in
            let warnings = store.documentsWithExpiryWarning(for: destination)
            return warnings.isEmpty ? nil : (destination, warnings.count)
        }
    }

    func tipOfTheDay() -> TravelTip {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return Self.tips[day % Self.tips.count]
    }
}
