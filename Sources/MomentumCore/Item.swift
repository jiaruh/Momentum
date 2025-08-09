import Foundation
import SwiftData

@Model
public final class Item {
    public var createdAt: Date
    public var task: String
    public var isCompleted: Bool
    public var dueDate: Date?
    public var priority: String?
    public var editedAt: Date?
    public var detailsText: String?
    public var imageData: Data?
    
    public init(
        createdAt: Date = .now,
        task: String,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        priority: String? = nil,
        editedAt: Date? = nil,
        detailsText: String? = nil,
        imageData: Data? = nil
    ) {
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

// MARK: - Priority Enum
public enum TaskPriority: String, CaseIterable, Identifiable {
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    
    public var id: String { self.rawValue }
}