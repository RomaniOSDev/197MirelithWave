import Foundation

struct TripBundle: Codable, Equatable {
    var destinationID: UUID
    var packingItems: [ChecklistItem]
    var itineraryDays: [ItineraryDay]
    var documents: [TravelDocument]
    var expenses: [TripExpense]
    var endDate: Date?

    init(
        destinationID: UUID,
        packingItems: [ChecklistItem] = [],
        itineraryDays: [ItineraryDay] = [],
        documents: [TravelDocument] = [],
        expenses: [TripExpense] = [],
        endDate: Date? = nil
    ) {
        self.destinationID = destinationID
        self.packingItems = packingItems
        self.itineraryDays = itineraryDays
        self.documents = documents
        self.expenses = expenses
        self.endDate = endDate
    }
}

struct ItineraryDay: Identifiable, Codable, Equatable {
    var id: UUID
    var dayNumber: Int
    var title: String
    var activities: [ItineraryActivity]

    init(
        id: UUID = UUID(),
        dayNumber: Int,
        title: String,
        activities: [ItineraryActivity] = []
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.activities = activities
    }
}

struct ItineraryActivity: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var timeLabel: String
    var notes: String

    init(
        id: UUID = UUID(),
        title: String,
        timeLabel: String = "",
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.timeLabel = timeLabel
        self.notes = notes
    }
}

struct TravelDocument: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var checked: Bool
    var expiryDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        checked: Bool = false,
        expiryDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.checked = checked
        self.expiryDate = expiryDate
    }
}

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case transport
    case food
    case hotel
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .transport: return "Transport"
        case .food: return "Food"
        case .hotel: return "Hotel"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .transport: return "car.fill"
        case .food: return "fork.knife"
        case .hotel: return "bed.double.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct TripExpense: Identifiable, Codable, Equatable {
    var id: UUID
    var category: ExpenseCategory
    var amount: Double
    var currencyCode: String
    var note: String
    var date: Date

    init(
        id: UUID = UUID(),
        category: ExpenseCategory,
        amount: Double,
        currencyCode: String,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.currencyCode = currencyCode
        self.note = note
        self.date = date
    }
}
