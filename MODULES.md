# Momentum App - Modular Architecture

This document describes the modular architecture of the Momentum app using Swift Package Manager.

## Module Structure

The app has been refactored into the following modules:

### 1. MomentumCore
**Purpose**: Core data models and shared utilities
**Dependencies**: None
**Contents**:
- `Item.swift` - Core data model for tasks
- `TaskPriority` enum - Priority levels for tasks

### 2. MomentumAuthentication
**Purpose**: Authentication services and biometric authentication
**Dependencies**: MomentumCore
**Contents**:
- `AuthenticationService.swift` - Handles Face ID/Touch ID authentication

### 3. MomentumUI
**Purpose**: Reusable UI components
**Dependencies**: MomentumCore
**Contents**:
- `TaskRow.swift` - Reusable task row component
- `StatCard.swift` - Statistics card component

### 4. MomentumFeatures
**Purpose**: Main app features and screens
**Dependencies**: MomentumCore, MomentumAuthentication, MomentumUI
**Contents**:
- `ContentView.swift` - Main app content view
- `HomeView.swift` - Home screen with task list
- `CalendarView.swift` - Calendar view for tasks
- `StatsView.swift` - Statistics and analytics view

## Benefits of This Architecture

1. **Separation of Concerns**: Each module has a specific responsibility
2. **Reusability**: UI components can be reused across features
3. **Testability**: Each module can be tested independently
4. **Maintainability**: Changes to one module don't affect others
5. **Scalability**: New features can be added as separate modules

## How to Use

### In Xcode
1. Open the project in Xcode
2. Add the local package by going to File → Add Package Dependencies
3. Choose "Add Local" and select the project root directory
4. Select the modules you want to use in your target

### In Code
```swift
import MomentumCore
import MomentumAuthentication
import MomentumUI
import MomentumFeatures

// Use the modules in your app
let authService = AuthenticationService()
let item = Item(task: "My Task")
```

## Testing

Each module has its own test target:
- `MomentumCoreTests`
- `MomentumAuthenticationTests`
- `MomentumUITests`
- `MomentumFeaturesTests`

Run tests with:
```bash
swift test
```

## Building

Build the package with:
```bash
swift build
```

## Platform Support

The modules are designed specifically for iOS 17.0 and later. All SwiftUI and UIKit dependencies are optimized for iOS development.

## Future Enhancements

- Add networking module for cloud sync
- Create notification module for reminders
- Add analytics module for usage tracking
- Create widget module for iOS widgets