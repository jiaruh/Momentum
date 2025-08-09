import Foundation
import SwiftData

/// A task item in the Momentum app.
///
/// `Item` represents a single task or todo item with support for completion status,
/// due dates, priorities, detailed descriptions, and image attachments.
///
/// ## Usage
///
/// Create a simple task:
/// ```swift
/// let task = Item(task: "Buy groceries")
/// ```
///
/// Create a task with additional details:
/// ```swift
/// let detailedTask = Item(
///     task: "Prepare presentation",
///     dueDate: Date().addingTimeInterval(86400),
///     priority: TaskPriority.high.rawValue,
///     detailsText: "Include charts and statistics"
/// )
/// ```
@available(iOS 17.0, macOS 14.0, *)
@Model
public final class Item {
    /// The date and time when the task was created.
    public var createdAt: Date
    
    /// The main text description of the task.
    public var task: String
    
    /// Whether the task has been completed.
    public var isCompleted: Bool
    
    /// The optional due date for the task.
    public var dueDate: Date?
    
    /// The priority level of the task as a string.
    ///
    /// Use ``TaskPriority`` enum values for consistency:
    /// - `TaskPriority.low.rawValue`
    /// - `TaskPriority.normal.rawValue`
    /// - `TaskPriority.high.rawValue`
    public var priority: String?
    
    /// The date and time when the task was last edited.
    public var editedAt: Date?
    
    /// Additional details or notes for the task.
    public var detailsText: String?
    
    /// Image data attached to the task.
    public var imageData: Data?
    
    /// Creates a new task item.
    ///
    /// - Parameters:
    ///   - createdAt: The creation date. Defaults to the current date and time.
    ///   - task: The main text description of the task.
    ///   - isCompleted: Whether the task is completed. Defaults to `false`.
    ///   - dueDate: The optional due date for the task.
    ///   - priority: The priority level. Use ``TaskPriority`` enum values.
    ///   - editedAt: The last edit date. Defaults to `nil`.
    ///   - detailsText: Additional details or notes.
    ///   - imageData: Image data to attach to the task.
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

/// Priority levels for tasks.
///
/// Use this enumeration to set consistent priority levels across the app.
///
/// ## Usage
///
/// ```swift
/// let task = Item(
///     task: "Important meeting",
///     priority: TaskPriority.high.rawValue
/// )
/// ```
public enum TaskPriority: String, CaseIterable, Identifiable {
    /// Low priority task.
    case low = "Low"
    
    /// Normal priority task (default).
    case normal = "Normal"
    
    /// High priority task.
    case high = "High"
    
    /// Unique identifier for the priority level.
    public var id: String { self.rawValue }
}