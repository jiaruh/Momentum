import XCTest
@testable import MomentumAuthentication

final class MomentumAuthenticationTests: XCTestCase {
    func testAuthenticationServiceInitialization() throws {
        let authService = AuthenticationService()
        XCTAssertFalse(authService.isAuthenticated)
    }
    
    func testLogout() throws {
        let authService = AuthenticationService()
        authService.logout()
        XCTAssertFalse(authService.isAuthenticated)
    }
}