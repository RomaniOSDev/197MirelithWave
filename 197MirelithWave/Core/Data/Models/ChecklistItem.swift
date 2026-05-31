import Foundation

struct ChecklistItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var checked: Bool
    var order: Int

    init(id: UUID = UUID(), title: String, checked: Bool = false, order: Int = 0) {
        self.id = id
        self.title = title
        self.checked = checked
        self.order = order
    }
}
