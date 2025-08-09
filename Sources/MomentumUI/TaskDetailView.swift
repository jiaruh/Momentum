import SwiftUI
import UIKit
import MomentumCore

/// A detailed view for displaying and managing individual tasks.
///
/// `TaskDetailView` provides a comprehensive interface for viewing all aspects
/// of a task including its description, priority, due date, additional details,
/// and attached images.
///
/// ## Features
///
/// - Complete task information display
/// - Completion status toggle
/// - Priority level with color coding
/// - Due date display
/// - Image attachment viewing
/// - Edit functionality via sheet presentation
///
/// ## Usage
///
/// ```swift
/// NavigationLink(destination: TaskDetailView(item: task)) {
///     TaskRow(item: task)
/// }
/// ```
///
/// ## Navigation Integration
///
/// ```swift
/// NavigationView {
///     TaskDetailView(item: selectedTask)
/// }
/// ```
public struct TaskDetailView: View {
    /// The task item to display in detail.
    public let item: Item
    
    @State private var showingEditTaskView = false
    
    /// Creates a new task detail view.
    ///
    /// - Parameter item: The task item to display in detail.
    public init(item: Item) {
        self.item = item
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Task Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.task)
                            .font(.title2)
                            .fontWeight(.bold)
                            .strikethrough(item.isCompleted, color: .primary)
                            .foregroundColor(item.isCompleted ? .secondary : .primary)
                        
                        Spacer()
                        
                        Button(action: {
                            item.isCompleted.toggle()
                        }) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .foregroundColor(item.isCompleted ? .green : .primary)
                        }
                    }
                    
                    if let priority = item.priority {
                        Text("Priority: \(priority)")
                            .font(.subheadline)
                            .foregroundColor(priorityColor(for: priority))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(priorityColor(for: priority).opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Due Date
                if let dueDate = item.dueDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.headline)
                        Text(dueDate, style: .date)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Details
                if let detailsText = item.detailsText, !detailsText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(detailsText)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Image
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attached Image")
                            .font(.headline)
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Created Date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Created")
                        .font(.headline)
                    Text(item.createdAt, style: .date)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditTaskView = true
                }
            }
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