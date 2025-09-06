import SwiftUI
import MomentumCore

/// A reusable row component for displaying task items in lists.
///
/// `TaskRow` provides a consistent interface for displaying tasks with completion
/// status, navigation to detail view, and visual indicators for attachments.
///
/// ## Features
///
/// - Completion toggle button
/// - Navigation to task detail view
/// - Visual indicators for attached images
/// - Strike-through text for completed tasks
/// - Support for task descriptions
///
/// ## Usage
///
/// ```swift
/// List(tasks) { task in
///     TaskRow(item: task)
/// }
/// ```
public struct TaskRow: View {
    /// The task item to display.
    public let item: Item
    
    @State private var showingEditTaskView = false
    
    /// Creates a new task row.
    ///
    /// - Parameter item: The task item to display in this row.
    public init(item: Item) {
        self.item = item
    }
    
    public var body: some View {
        HStack {
            Button(action: {
                item.isCompleted.toggle()
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .primary)
            }
            .buttonStyle(PlainButtonStyle())
            
            NavigationLink(destination: TaskDetailView(item: item)) {
                VStack(alignment: .leading) {
                    Text(item.task)
                        .strikethrough(item.isCompleted, color: .primary)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)
                    
                    if let detailsText = item.detailsText, !detailsText.isEmpty {
                        Text(detailsText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    if item.imageData != nil {
                        HStack {
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("Image attached")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if let dueDate = item.dueDate {
                        Text("Due: \(dueDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let priority = item.priority {
                        Text("Priority: \(priority)")
                            .font(.caption)
                            .foregroundColor(priorityColor(for: priority))
                    }
                    
                    // 添加提醒信息
                    if item.reminderEnabled, let reminderDate = item.reminderDate {
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Reminder: \(reminderDate, style: .date) \(reminderDate, style: .time)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // 添加重复信息
                    if item.isRepeating, let repeatInterval = item.repeatInterval {
                        HStack {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("Repeats: \(repeatInterval.rawValue)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // 添加快速提醒操作按钮
            if item.reminderEnabled {
                Button(action: {
                    // 快速修改提醒时间 - 这里可以扩展为弹出时间选择器
                    Task {
                        await NotificationManager.shared.cancelTaskReminder(for: item)
                        item.reminderEnabled = false
                    }
                }) {
                    Image(systemName: "bell.slash")
                        .foregroundColor(.orange)
                }
            } else {
                Button(action: {
                    // 快速设置提醒 - 这里可以扩展为弹出时间选择器
                    let reminderId = NotificationManager.shared.generateReminderId()
                    item.reminderId = reminderId
                    item.reminderDate = Date().addingTimeInterval(3600) // 1小时后
                    item.reminderEnabled = true
                    
                    Task {
                        await NotificationManager.shared.scheduleTaskReminder(for: item)
                    }
                }) {
                    Image(systemName: "bell")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .swipeActions(edge: .leading) {
            Button("Edit") {
                showingEditTaskView = true
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showingEditTaskView) {
            EditTaskView(item: item)
        }
    }
    
    private func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High":
            return .red
        case "Normal":
            return .blue
        case "Low":
            return .green
        default:
            return .gray
        }
    }
}