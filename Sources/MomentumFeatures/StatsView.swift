import SwiftUI
import SwiftData
import MomentumCore
import MomentumUI

public struct StatsView: View {
    @Query(sort: \Item.createdAt, order: .reverse) private var allTasks: [Item]
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overview Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            StatCard(title: "Total Tasks", value: "\(allTasks.count)", icon: "list.bullet", color: .blue)
                            StatCard(title: "Completed", value: "\(completedTasks.count)", icon: "checkmark.circle.fill", color: .green)
                            StatCard(title: "Pending", value: "\(pendingTasks.count)", icon: "clock", color: .orange)
                            StatCard(title: "Overdue", value: "\(overdueTasks.count)", icon: "exclamationmark.triangle.fill", color: .red)
                        }
                        .padding(.horizontal)
                        
                        // Completion Rate
                        CompletionRateView(completedCount: completedTasks.count, totalCount: allTasks.count)
                            .padding(.horizontal)
                        
                        // Priority Distribution
                        PriorityDistributionView(tasks: Array(allTasks))
                            .padding(.horizontal)
                        
                        // Weekly Progress
                        WeeklyProgressView(tasks: Array(allTasks))
                            .padding(.horizontal)
                        
                        // Recent Activity
                        RecentActivityView(tasks: Array(allTasks.prefix(5)))
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var completedTasks: [Item] {
        allTasks.filter { $0.isCompleted }
    }
    
    private var pendingTasks: [Item] {
        allTasks.filter { !$0.isCompleted && !isOverdue($0) }
    }
    
    private var overdueTasks: [Item] {
        allTasks.filter { !$0.isCompleted && isOverdue($0) }
    }
    
    private func isOverdue(_ task: Item) -> Bool {
        guard let dueDate = task.dueDate else { return false }
        return dueDate < Date() && !task.isCompleted
    }
}

struct CompletionRateView: View {
    let completedCount: Int
    let totalCount: Int
    
    private var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Rate")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 8)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .cornerRadius(4)
                    
                    Rectangle()
                        .frame(width: CGFloat(completionRate) * 300, height: 8)
                        .foregroundColor(.green)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 1.0), value: completionRate)
                }
                .frame(maxWidth: 300)
                
                Text("\(Int(completionRate * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct PriorityDistributionView: View {
    let tasks: [Item]
    
    private var priorityCounts: [String: Int] {
        var counts = ["High": 0, "Normal": 0, "Low": 0]
        for task in tasks {
            let priority = task.priority ?? "Normal"
            counts[priority, default: 0] += 1
        }
        return counts
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Distribution")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(["High", "Normal", "Low"], id: \.self) { priority in
                    HStack {
                        Circle()
                            .fill(priorityColor(for: priority))
                            .frame(width: 12, height: 12)
                        
                        Text(priority)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(priorityCounts[priority] ?? 0)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
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

struct WeeklyProgressView: View {
    let tasks: [Item]
    
    private var weeklyData: [DayData] {
        let calendar = Calendar.current
        let today = Date()
        let weekdays = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }.reversed()
        
        return weekdays.map { date in
            let dayTasks = tasks.filter { task in
                return calendar.isDate(task.createdAt, inSameDayAs: date)
            }
            let completed = dayTasks.filter { $0.isCompleted }.count
            
            return DayData(
                date: date,
                dayName: calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1],
                completedTasks: completed,
                totalTasks: dayTasks.count
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 8) {
                ForEach(weeklyData, id: \.date) { data in
                    VStack(spacing: 6) {
                        Text(data.dayName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                                .frame(width: 30, height: 30)
                            
                            if data.totalTasks > 0 {
                                Circle()
                                    .trim(from: 0, to: CGFloat(data.completedTasks) / CGFloat(data.totalTasks))
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .frame(width: 30, height: 30)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1.0), value: data.completedTasks)
                            }
                            
                            Text("\(data.completedTasks)")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}

struct DayData {
    let date: Date
    let dayName: String
    let completedTasks: Int
    let totalTasks: Int
}

struct RecentActivityView: View {
    let tasks: [Item]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            if tasks.isEmpty {
                Text("No recent tasks")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(tasks.enumerated()), id: \.element.hashValue) { index, task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.task)
                                    .font(.subheadline)
                                    .strikethrough(task.isCompleted, color: .primary)
                                
                                Text(task.createdAt, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let priority = task.priority {
                                Text(priority)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(priorityColor(for: priority).opacity(0.2))
                                    .foregroundColor(priorityColor(for: priority))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if index < tasks.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
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