import XCTest
import SwiftUI
@testable import MomentumUI
@testable import MomentumCore

final class MomentumUITests: XCTestCase {
    func testStatCardCreation() throws {
        let statCard = StatCard(title: "Test", value: "10", icon: "star", color: .blue)
        XCTAssertNotNil(statCard)
    }
    
    func testTaskRowCreation() throws {
        let item = Item(task: "Test Task")
        let taskRow = TaskRow(item: item)
        XCTAssertNotNil(taskRow)
    }
}