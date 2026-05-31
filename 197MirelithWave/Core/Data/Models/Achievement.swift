import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let condition: (AppDataStore) -> Bool

    static let all: [Achievement] = [
        Achievement(
            id: "first_step",
            title: "First Step",
            description: "You added your first destination.",
            iconName: "mappin.and.ellipse",
            condition: { $0.destinationsAdded >= 1 }
        ),
        Achievement(
            id: "seasoned_traveler",
            title: "Seasoned Traveler",
            description: "You planned ten different trips.",
            iconName: "airplane",
            condition: { $0.tripsCompleted >= 10 }
        ),
        Achievement(
            id: "packing_pro",
            title: "Packing Pro",
            description: "You completed five packing checklists.",
            iconName: "bag.fill",
            condition: { $0.checklistsCompleted >= 5 }
        ),
        Achievement(
            id: "currency_wizard",
            title: "Currency Wizard",
            description: "Performed five currency conversions.",
            iconName: "dollarsign.circle.fill",
            condition: { $0.conversionsRun >= 5 }
        ),
        Achievement(
            id: "phrase_master",
            title: "Phrase Master",
            description: "Viewed ten essential travel phrases.",
            iconName: "text.bubble.fill",
            condition: { $0.phrasesViewed >= 10 }
        ),
        Achievement(
            id: "globetrotting_planner",
            title: "Globetrotting Planner",
            description: "Added twenty destinations to wishlist.",
            iconName: "globe.americas.fill",
            condition: { $0.destinationsAdded >= 20 }
        ),
        Achievement(
            id: "checklist_champion",
            title: "Checklist Champion",
            description: "Completed twenty packing checklists.",
            iconName: "checkmark.seal.fill",
            condition: { $0.checklistsCompleted >= 20 }
        ),
        Achievement(
            id: "world_explorer",
            title: "World Explorer",
            description: "Completed fifty trips planned in the app.",
            iconName: "star.fill",
            condition: { $0.tripsCompleted >= 50 }
        ),
        Achievement(
            id: "itinerary_builder",
            title: "Itinerary Builder",
            description: "Planned five days across your trips.",
            iconName: "calendar.badge.plus",
            condition: { $0.itineraryDaysAdded >= 5 }
        ),
        Achievement(
            id: "budget_tracker",
            title: "Budget Tracker",
            description: "Logged ten expense entries.",
            iconName: "creditcard.fill",
            condition: { $0.budgetEntriesAdded >= 10 }
        ),
        Achievement(
            id: "document_ready",
            title: "Document Ready",
            description: "Completed all travel documents for a trip.",
            iconName: "doc.text.fill",
            condition: { $0.documentsCompletedCount >= 1 }
        ),
        Achievement(
            id: "emergency_prepared",
            title: "Safety First",
            description: "Viewed emergency info for five countries.",
            iconName: "phone.fill",
            condition: { $0.emergencyInfoViewed >= 5 }
        ),
        Achievement(
            id: "master_packer",
            title: "Master Packer",
            description: "Built a packing list with twenty items.",
            iconName: "bag.fill",
            condition: { $0.longestChecklistCount >= 20 }
        )
    ]
}
