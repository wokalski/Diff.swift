
import XCTest
@testable import Diff

/*
 * empty to something
 * something to empty
 * empty to empty
 * same
 * different number of sections
 */
class NestedDiffTests: XCTestCase {

    func testDiffOutputs() {

        let expectations: [([[Int]], [[Int]], String)] = [
            ([], [[1, 2], [1]], "I(0,0)I(1,0)I(0,1)"),
            ([[1, 2], []], [], "D(0, 0)D(1, 0)"),
            ([], [], ""),
            ([[1, 2], [], [1]], [[1, 2], [], [1]], ""),
            ([[1, 2], [1, 4]], [[5, 2], [10, 4, 8]], "D(0, 0)I(0,0)D(0, 1)I(0,1)I(2,1)"),
            ([[1]], [[], [1, 2]], "D(0, 0)I(0, 1)I(1, 1)"),
        ]

        for expectation in expectations {
            XCTAssertEqual(
                _test(from: expectation.0, to: expectation.1),
                expectation.2)
        }
    }

    func _test(
        from: [[Int]],
        to: [[Int]]) -> String {
        return from
            .nestedDiff(to: to)
            .reduce("") { $0 + $1.debugDescription }
    }
}
