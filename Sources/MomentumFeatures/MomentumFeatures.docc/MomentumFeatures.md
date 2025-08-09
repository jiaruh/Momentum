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
The main task management interface where users can:
- View all tasks in a list
- Add new tasks
- Mark tasks as complete
- Navigate to task details
- Delete tasks

#### Calendar View
A calendar-based view for:
- Viewing tasks by date
- Understanding task distribution over time
- Managing due dates

#### Stats View
Analytics and statistics including:
- Task completion rates
- Priority distribution
- Progress tracking
- Visual charts and metrics

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

- ``MomentumCore``: Data models and utilities
- ``MomentumAuthentication``: Biometric authentication
- ``MomentumUI``: Reusable UI components
- SwiftUI: User interface framework
- SwiftData: Data persistence