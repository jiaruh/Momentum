import SwiftUI
import MomentumAuthentication

/// The main content view that handles authentication and app navigation.
///
/// `ContentView` serves as the root view of the Momentum app, managing the
/// authentication state and presenting either the main app interface or
/// the authentication prompt based on the user's authentication status.
///
/// ## Features
///
/// - Biometric authentication integration
/// - Tab-based navigation for authenticated users
/// - Authentication prompt for unauthenticated users
/// - Automatic authentication attempt on app launch
///
/// ## Usage
///
/// ```swift
/// @main
/// struct MomentumApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```
///
/// ## Authentication Flow
///
/// 1. App launches and displays ContentView
/// 2. Authentication is automatically attempted
/// 3. If successful, main tab interface is shown
/// 4. If unsuccessful, authentication prompt is displayed
public struct ContentView: View {
    @StateObject private var authService = AuthenticationService()

    /// Creates the main content view.
    ///
    /// Initializes the authentication service and sets up the main app interface.
    public init() {}

    public var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    
                    CalendarView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                    
                    StatsView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Stats")
                        }
                }
            } else {
                VStack {
                    Text("Locked")
                        .font(.largeTitle)
                    Button("Unlock with Face ID") {
                        authService.authenticate()
                    }
                }
            }
        }
        .onAppear {
            authService.authenticate()
        }
    }
}