# ``MomentumUI``

Reusable UI components for the Momentum task management app.

## Overview

MomentumUI provides a collection of reusable SwiftUI components designed specifically for the Momentum app. These components follow consistent design patterns and can be easily integrated throughout the app.

## Topics

### Task Components

- ``TaskRow``
- ``TaskDetailView``
- ``EditTaskView``

### Statistics Components

- ``StatCard``

### Usage Examples

#### Displaying Tasks

```swift
import SwiftUI
import MomentumUI
import MomentumCore

struct TaskListView: View {
    let tasks: [Item]
    
    var body: some View {
        List(tasks) { task in
            TaskRow(item: task)
        }
    }
}
```

#### Showing Statistics

```swift
import SwiftUI
import MomentumUI

struct StatsOverview: View {
    let completedCount: Int
    let totalCount: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
            StatCard(
                title: "Completed",
                value: "\(completedCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            StatCard(
                title: "Total",
                value: "\(totalCount)",
                icon: "list.bullet",
                color: .blue
            )
        }
    }
}
```

#### Task Detail and Editing

```swift
import SwiftUI
import MomentumUI
import MomentumCore

struct TaskManagementView: View {
    let task: Item
    @State private var showingEdit = false
    
    var body: some View {
        NavigationView {
            TaskDetailView(item: task)
                .toolbar {
                    Button("Edit") {
                        showingEdit = true
                    }
                }
                .sheet(isPresented: $showingEdit) {
                    EditTaskView(item: task)
                }
        }
    }
}
```

## Design Principles

- Consistency: All components follow the same visual design language
- Accessibility: Components support VoiceOver and other accessibility features
- Responsiveness: Components adapt to different screen sizes and orientations
- Modularity: Each component is self-contained and reusable