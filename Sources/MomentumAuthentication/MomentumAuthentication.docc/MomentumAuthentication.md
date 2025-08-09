# ``MomentumAuthentication``

Biometric authentication services for the Momentum app.

## Overview

MomentumAuthentication provides secure biometric authentication using Face ID and Touch ID. This module handles user authentication state and provides a simple interface for protecting app content.

## Topics

### Authentication Service

- ``AuthenticationService``

### Getting Started

```swift
import MomentumAuthentication

// Create an authentication service
let authService = AuthenticationService()

// Trigger authentication
authService.authenticate()

// Check authentication status
if authService.isAuthenticated {
    // Show protected content
}
```

### Integration with SwiftUI

```swift
import SwiftUI
import MomentumAuthentication

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // Your app content
                MainAppView()
            } else {
                // Authentication prompt
                AuthenticationView(authService: authService)
            }
        }
    }
}
```

## Requirements

This module requires iOS 17.0 or later, a device with Face ID or Touch ID capability, and proper Info.plist configuration for `NSFaceIDUsageDescription`.