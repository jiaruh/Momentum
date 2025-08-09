import Combine
import LocalAuthentication
import Foundation

/// A service that handles biometric authentication using Face ID or Touch ID.
///
/// `AuthenticationService` provides a simple interface for authenticating users
/// and managing authentication state throughout the app lifecycle.
///
/// ## Usage
///
/// ```swift
/// let authService = AuthenticationService()
/// authService.authenticate()
/// ```
///
/// ## Integration with SwiftUI
///
/// ```swift
/// @StateObject private var authService = AuthenticationService()
///
/// var body: some View {
///     if authService.isAuthenticated {
///         MainContentView()
///     } else {
///         AuthenticationPromptView()
///     }
/// }
/// ```
public class AuthenticationService: ObservableObject {
    /// The current authentication state.
    ///
    /// This property is published and will trigger UI updates when the authentication
    /// state changes. `true` indicates the user is authenticated, `false` indicates
    /// they need to authenticate.
    @Published public var isAuthenticated = false
    
    /// Creates a new authentication service.
    ///
    /// The service starts in an unauthenticated state by default.
    public init() {}
    
    /// Initiates biometric authentication.
    ///
    /// This method attempts to authenticate the user using the device's biometric
    /// authentication capabilities (Face ID or Touch ID). If successful, the
    /// `isAuthenticated` property will be set to `true`.
    ///
    /// ## Behavior
    ///
    /// - If biometric authentication is available, prompts the user
    /// - If successful, updates `isAuthenticated` to `true` on the main thread
    /// - If biometric authentication is not available, logs an error
    /// - If authentication fails, logs the error but doesn't change state
    ///
    /// ## Requirements
    ///
    /// - Device must support Face ID or Touch ID
    /// - App must have `NSFaceIDUsageDescription` in Info.plist
    public func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock your moments."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    Task { @MainActor in
                        self.isAuthenticated = true
                    }
                } else {
                    // Handle authentication failure
                    print("Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            // Biometric authentication not available on this device
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    /// Logs out the current user.
    ///
    /// Sets the authentication state to `false`, requiring the user to
    /// authenticate again to access protected content.
    public func logout() {
        isAuthenticated = false
    }
}