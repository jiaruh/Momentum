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
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
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