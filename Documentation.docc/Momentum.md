# Momentum

A modern, secure task management app built with SwiftUI and modular architecture.

## Overview

Momentum is a comprehensive task management application designed for iOS 17+ that combines intuitive user interface design with robust security features. The app uses biometric authentication to protect user data and provides a clean, efficient interface for managing tasks, deadlines, and productivity.

## Key Features

- Biometric Security: Face ID and Touch ID authentication
- Task Management: Create, edit, and organize tasks with priorities
- Rich Content: Add descriptions and image attachments to tasks
- Calendar Integration: View tasks by due date
- Analytics: Track completion rates and productivity statistics
- Modular Architecture: Clean, maintainable codebase

## Architecture

Momentum is built using a modular architecture with four main modules:

### Core Modules

- ``MomentumCore``: Data models and shared utilities
- ``MomentumAuthentication``: Biometric authentication services
- ``MomentumUI``: Reusable UI components
- ``MomentumFeatures``: Main app features and screens

### Module Dependencies

```
MomentumFeatures
├── MomentumCore
├── MomentumAuthentication
└── MomentumUI
    └── MomentumCore

MomentumAuthentication
└── MomentumCore
```

## Getting Started

### Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Device with Face ID or Touch ID (for authentication)

### Installation

1. Clone the repository
2. Open `Momentum.xcodeproj` in Xcode
3. Build and run the project

### Basic Usage

```swift
import SwiftUI
import MomentumCore
import MomentumFeatures

@main
struct MomentumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
```

## Core Concepts

### Tasks (Items)

Tasks are represented by the ``MomentumCore/Item`` class, which includes:
- Task description
- Completion status
- Priority levels
- Due dates
- Additional notes
- Image attachments

### Authentication

The app uses ``MomentumAuthentication/AuthenticationService`` to provide:
- Biometric authentication (Face ID/Touch ID)
- Session management
- Secure access control

### User Interface

The UI is built with reusable components from ``MomentumUI``:
- ``MomentumUI/TaskRow``: Individual task display
- ``MomentumUI/TaskDetailView``: Detailed task view
- ``MomentumUI/EditTaskView``: Task editing interface
- ``MomentumUI/StatCard``: Statistics display

## Development

### Code Style

- Follow Swift naming conventions
- Use SwiftUI for all user interfaces
- Implement comprehensive DocC documentation
- Write unit tests for all modules

### Testing

Run tests for all modules:

```bash
swift test
```

Or test individual modules:

```bash
swift test --filter MomentumCoreTests
swift test --filter MomentumAuthenticationTests
swift test --filter MomentumUITests
swift test --filter MomentumFeaturesTests
```

### Building

Build the entire project:

```bash
swift build
```

## Privacy and Security

- All data is stored locally using SwiftData
- Biometric authentication protects app access
- No data is transmitted to external servers
- Face ID usage requires explicit user permission

## Contributing

When contributing to Momentum:

1. Follow the modular architecture
2. Add comprehensive documentation
3. Include unit tests
4. Follow Swift coding conventions
5. Test on multiple device types

## License

See LICENSE file for details.