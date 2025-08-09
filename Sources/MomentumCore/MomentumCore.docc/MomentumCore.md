# ``MomentumCore``

Core data models and shared utilities for the Momentum task management app.

## Overview

MomentumCore provides the fundamental data structures and utilities used throughout the Momentum app. This module contains the core `Item` model for tasks and the `TaskPriority` enumeration.

## Topics

### Data Models

- ``Item``
- ``TaskPriority``

### Creating Tasks

```swift
import MomentumCore

// Create a simple task
let task = Item(task: "Complete project documentation")

// Create a task with priority and due date
let urgentTask = Item(
    task: "Review pull request",
    dueDate: Date().addingTimeInterval(86400), // Tomorrow
    priority: TaskPriority.high.rawValue
)
```

### Managing Task State

```swift
// Mark task as completed
task.isCompleted = true

// Add details to a task
task.detailsText = "Remember to include unit tests"

// Set priority
task.priority = TaskPriority.high.rawValue
```