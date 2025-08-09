import Combine
import LocalAuthentication
import Foundation

public class AuthenticationService: ObservableObject {
    @Published public var isAuthenticated = false
    
    public init() {}
    
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
                    // Handle error
                    print("Authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            // No biometrics available
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    public func logout() {
        isAuthenticated = false
    }
}