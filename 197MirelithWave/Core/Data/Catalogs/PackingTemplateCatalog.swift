import Foundation

enum PackingTemplate: String, CaseIterable, Identifiable {
    case beach
    case business
    case winter
    case weekend

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beach: return "Beach"
        case .business: return "Business"
        case .winter: return "Winter"
        case .weekend: return "Weekend"
        }
    }

    var iconName: String {
        switch self {
        case .beach: return "sun.max.fill"
        case .business: return "briefcase.fill"
        case .winter: return "snowflake"
        case .weekend: return "calendar"
        }
    }

    var items: [String] {
        switch self {
        case .beach:
            return ["Swimsuit", "Sunscreen SPF 50", "Beach towel", "Sandals", "Sunglasses", "Hat", "Flip flops", "After-sun lotion"]
        case .business:
            return ["Suit / Blazer", "Dress shirts", "Business shoes", "Laptop & charger", "Notebook & pen", "ID badge", "Tie / Scarf", "Presentation materials"]
        case .winter:
            return ["Warm coat", "Thermal layers", "Gloves", "Scarf", "Winter boots", "Wool socks", "Beanie", "Hand warmers"]
        case .weekend:
            return ["Casual outfits", "Comfortable shoes", "Toiletries bag", "Phone charger", "Snacks", "Water bottle", "Light jacket", "Day bag"]
        }
    }
}
