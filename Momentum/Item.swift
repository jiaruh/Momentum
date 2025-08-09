
import Foundation
import SwiftData

@Model
final class Item {
    var createdAt: Date
    var task: String
    var isCompleted: Bool
    var dueDate: Date?
    var priority: String?
    var editedAt: Date?
    
    init(createdAt: Date = .now, task: String, isCompleted: Bool = false, dueDate: Date? = nil, priority: String? = nil, editedAt: Date? = nil) {
        self.createdAt = createdAt
        self.task = task
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.editedAt = editedAt
    }
}
