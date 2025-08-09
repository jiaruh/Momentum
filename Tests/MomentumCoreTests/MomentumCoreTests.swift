import XCTest
@testable import MomentumCore

final class MomentumCoreTests: XCTestCase {
    func testItemCreation() throws {
        let item = Item(task: "Test Task")
        XCTAssertEqual(item.task, "Test Task")
        XCTAssertFalse(item.isCompleted)
        XCTAssertEqual(item.priority, nil)
    }
    
    func testTaskPriorityEnum() throws {
        XCTAssertEqual(TaskPriority.low.rawValue, "Low")
        XCTAssertEqual(TaskPriority.normal.rawValue, "Normal")
        XCTAssertEqual(TaskPriority.high.rawValue, "High")
    }
}