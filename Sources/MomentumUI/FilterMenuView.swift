import SwiftUI
import MomentumCore

/// A reusable filter menu component for task filtering.
///
/// `FilterMenuView` provides a beautiful, modern interface for filtering tasks
/// by status and priority with animated chips and clear functionality.
///
/// ## Features
///
/// - Status and priority filter chips with gradients and shadows
/// - Dynamic icons and colors based on selected filters
/// - Smooth animations and scale effects
/// - Clear filters button when filters are active
/// - Horizontal scrolling for responsive design
///
/// ## Usage
///
/// ```swift
/// FilterMenuView(
///     selectedStatusFilter: $statusFilter,
///     selectedPriorityFilter: $priorityFilter
/// )
/// ```
public struct FilterMenuView: View {
    /// Binding to the selected status filter
    @Binding public var selectedStatusFilter: TaskStatusFilter
    /// Binding to the selected priority filter
    @Binding public var selectedPriorityFilter: TaskPriorityFilter
    
    /// Creates a new filter menu view
    /// - Parameters:
    ///   - selectedStatusFilter: Binding to the status filter selection
    ///   - selectedPriorityFilter: Binding to the priority filter selection
    public init(
        selectedStatusFilter: Binding<TaskStatusFilter>,
        selectedPriorityFilter: Binding<TaskPriorityFilter>
    ) {
        self._selectedStatusFilter = selectedStatusFilter
        self._selectedPriorityFilter = selectedPriorityFilter
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Status Filter
                Menu {
                    Picker("Status", selection: $selectedStatusFilter) {
                        ForEach(TaskStatusFilter.allCases) { filter in
                            HStack {
                                Text(filter.rawValue)
                                Spacer()
                                if filter == selectedStatusFilter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .tag(filter)
                        }
                    }
                } label: {
                    FilterChipView(
                        title: "Status",
                        value: selectedStatusFilter.rawValue,
                        icon: statusFilterIcon(for: selectedStatusFilter),
                        color: statusFilterColor(for: selectedStatusFilter),
                        isActive: selectedStatusFilter != .all
                    )
                }
                .scaleEffect(selectedStatusFilter != .all ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedStatusFilter)
                
                // Priority Filter
                Menu {
                    Picker("Priority", selection: $selectedPriorityFilter) {
                        ForEach(TaskPriorityFilter.allCases) { filter in
                            HStack {
                                Text(filter.rawValue)
                                Spacer()
                                if filter == selectedPriorityFilter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .tag(filter)
                        }
                    }
                } label: {
                    FilterChipView(
                        title: "Priority",
                        value: selectedPriorityFilter.rawValue,
                        icon: priorityFilterIcon(for: selectedPriorityFilter),
                        color: priorityFilterColor(for: selectedPriorityFilter),
                        isActive: selectedPriorityFilter != .all
                    )
                }
                .scaleEffect(selectedPriorityFilter != .all ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedPriorityFilter)
                
                // Clear Filters Button (if any filter is active)
                if selectedStatusFilter != .all || selectedPriorityFilter != .all {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedStatusFilter = .all
                            selectedPriorityFilter = .all
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12, weight: .medium))
                            Text("Clear")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.7),
                                    Color.gray
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Functions
    
    private func statusFilterIcon(for filter: TaskStatusFilter) -> String {
        switch filter {
        case .all:
            return "line.3.horizontal.decrease.circle"
        case .active:
            return "clock"
        case .completed:
            return "checkmark.circle"
        }
    }
    
    private func statusFilterColor(for filter: TaskStatusFilter) -> Color {
        switch filter {
        case .all:
            return Color.blue
        case .active:
            return Color.orange
        case .completed:
            return Color.green
        }
    }
    
    private func priorityFilterIcon(for filter: TaskPriorityFilter) -> String {
        switch filter {
        case .all:
            return "slider.horizontal.3"
        case .low:
            return "arrow.down.circle"
        case .normal:
            return "equal.circle"
        case .high:
            return "arrow.up.circle"
        }
    }
    
    private func priorityFilterColor(for filter: TaskPriorityFilter) -> Color {
        switch filter {
        case .all:
            return Color.purple
        case .low:
            return Color.blue
        case .normal:
            return Color.teal
        case .high:
            return Color.red
        }
    }
}

/// A reusable chip component for filter buttons.
///
/// `FilterChipView` provides a consistent visual style for filter chips
/// with gradients, shadows, and proper typography hierarchy.
public struct FilterChipView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isActive: Bool
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            Image(systemName: "chevron.down")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.8),
                    color
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Filter Enums

/// Filter criteria for task completion status.
public enum TaskStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    
    public var id: String { self.rawValue }
}

/// Filter criteria for task priority.
public enum TaskPriorityFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case low = "Low"
    case normal = "Normal"
    case high = "High"
    
    public var id: String { self.rawValue }
}