import SwiftUI
import MomentumCore

public struct TaskRow: View {
    public let item: Item
    @State private var showingEditTaskView = false
    
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
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
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