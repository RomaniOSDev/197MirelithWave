import Foundation

struct Destination: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var country: String
    var notes: String
    var plannedDate: Date
    var endDate: Date?
    var visited: Bool

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        notes: String = "",
        plannedDate: Date = Date(),
        endDate: Date? = nil,
        visited: Bool = false
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.notes = notes
        self.plannedDate = plannedDate
        self.endDate = endDate
        self.visited = visited
    }
}
