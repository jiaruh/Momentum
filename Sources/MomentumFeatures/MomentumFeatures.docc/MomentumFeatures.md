# ``MomentumFeatures``

Main app features and screens for the Momentum task management app.

## Overview

MomentumFeatures contains the primary user interface screens and features of the Momentum app. This module brings together components from other modules to create complete user experiences.

## Topics

### Main Views

- ``ContentView``
- ``HomeView``
- ``CalendarView``
- ``StatsView``

### App Architecture

The features module follows a tab-based navigation structure:

```swift
import SwiftUI
import MomentumFeatures

@main
struct MomentumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Feature Overview

#### Home View
The main task management interface where users can view all tasks in a list, add new tasks, mark tasks as complete, navigate to task details, and delete tasks.

#### Calendar View
A calendar-based view for viewing tasks by date, understanding task distribution over time, and managing due dates.

#### Stats View
Analytics and statistics including task completion rates, priority distribution, progress tracking, and visual charts and metrics.

### Authentication Integration

The app integrates biometric authentication:

```swift
import MomentumAuthentication

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    
    var body: some View {
        if authService.isAuthenticated {
            // Main app content
            TabView { /* ... */ }
        } else {
            // Authentication prompt
            AuthenticationView()
        }
    }
}
```

## Dependencies

This module integrates with MomentumCore for data models and utilities, MomentumAuthentication for biometric authentication, MomentumUI for reusable UI components, SwiftUI for the user interface framework, and SwiftData for data persistence.