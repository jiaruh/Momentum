import XCTest
import SwiftUI
@testable import MomentumFeatures

final class MomentumFeaturesTests: XCTestCase {
    func testContentViewCreation() throws {
        let contentView = ContentView()
        XCTAssertNotNil(contentView)
    }
    
    func testHomeViewCreation() throws {
        let homeView = HomeView()
        XCTAssertNotNil(homeView)
    }
    
    func testCalendarViewCreation() throws {
        let calendarView = CalendarView()
        XCTAssertNotNil(calendarView)
    }
    
    func testStatsViewCreation() throws {
        let statsView = StatsView()
        XCTAssertNotNil(statsView)
    }
}