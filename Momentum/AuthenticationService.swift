
import Combine
import LocalAuthentication

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    
    @MainActor
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock your moments."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                if success {
                    self.isAuthenticated = true
                } else {
                    // Handle error
                }
            }
        } else {
            // No biometrics
        }
    }
}
