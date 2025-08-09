
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
    var detailsText: String?
    var imageData: Data?
    
    init(createdAt: Date = .now, task: String, isCompleted: Bool = false, dueDate: Date? = nil, priority: String? = nil, editedAt: Date? = nil, detailsText: String? = nil, imageData: Data? = nil) {
        self.createdAt = createdAt
        self.task = task
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.priority = priority
        self.editedAt = editedAt
        self.detailsText = detailsText
        self.imageData = imageData
    }
}
