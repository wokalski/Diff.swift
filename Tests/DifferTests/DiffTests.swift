import XCTest
@testable import Differ

extension Trace: Hashable {
    public var hashValue: Int {
        return (((51 + from.x.hashValue) * 51 + from.y.hashValue) * 51 + to.x.hashValue) * 51 + to.y.hashValue
    }
}

class DiffTests: XCTestCase {

    let expectations = [
        ("kitten", "sitting", "D(0)I(0)D(4)I(4)I(6)"),
        ("🐩itt🍨ng", "kitten", "D(0)I(0)D(4)I(4)D(6)"),
        ("1234", "ABCD", "D(0)D(1)D(2)D(3)I(0)I(1)I(2)I(3)"),
        ("1234", "", "D(0)D(1)D(2)D(3)"),
        ("", "1234", "I(0)I(1)I(2)I(3)"),
        ("Hi", "Oh Hi", "I(0)I(1)I(2)"),
        ("Hi", "Hi O", "I(2)I(3)"),
        ("Oh Hi", "Hi", "D(0)D(1)D(2)"),
        ("Hi O", "Hi", "D(2)D(3)"),
        ("Wojtek", "Wojciech", "D(3)I(3)I(4)D(5)I(6)I(7)"),
        ("1234", "1234", ""),
        ("", "", ""),
        ("Oh Hi", "Hi Oh", "D(0)D(1)D(2)I(2)I(3)I(4)"),
        ("1362", "31526", "D(0)D(2)I(1)I(2)I(4)")
    ]

    let extendedExpectations = [
        ("sitting", "kitten", "D(0)I(0)D(4)I(4)D(6)"),
        ("🐩itt🍨ng", "kitten", "D(0)I(0)D(4)I(4)D(6)"),
        ("1234", "ABCD", "D(0)D(1)D(2)D(3)I(0)I(1)I(2)I(3)"),
        ("1234", "", "D(0)D(1)D(2)D(3)"),
        ("", "1234", "I(0)I(1)I(2)I(3)"),
        ("Hi", "Oh Hi", "I(0)I(1)I(2)"),
        ("Hi", "Hi O", "I(2)I(3)"),
        ("Oh Hi", "Hi", "D(0)D(1)D(2)"),
        ("Hi O", "Hi", "D(2)D(3)"),
        ("Wojtek", "Wojciech", "D(3)I(3)I(4)D(5)I(6)I(7)"),
        ("1234", "1234", ""),
        ("", "", ""),
        ("gitten", "sitting", "M(0,6)I(0)D(4)I(4)"),
        ("Oh Hi", "Hi Oh", "M(0,3)M(1,4)M(2,2)"),
        ("Hi Oh", "Oh Hi", "M(0,3)M(1,4)M(2,2)"),
        ("12345", "12435", "M(2,3)"),
        ("1362", "31526", "M(0,1)M(2,4)I(2)")
    ]

    func testDiffOutputs() {
        for expectation in expectations {
            XCTAssertEqual(
                _test(from: expectation.0, to: expectation.1),
                expectation.2)
        }
    }

    func testExtendedDiffOutputs() {
        for expectation in extendedExpectations {
            XCTAssertEqual(
                _testExtended(from: expectation.0, to: expectation.1),
                expectation.2)
        }
    }

    // The tests below check efficiency of the algorithm

    func testDuplicateTraces() {
        for expectation in expectations {
            XCTAssertFalse(duplicateTraces(from: expectation.0, to: expectation.1))
        }
    }

    func testTracesOutOfBounds() {
        for expectation in expectations {
            XCTAssertEqual(tracesOutOfBounds(from: expectation.0, to: expectation.1), [], "traces out of bounds for \(expectation.0) -> \(expectation.1)")
        }
    }

    func testSingleElementArray() {
        let changes = "a".diff("a")
        XCTAssertEqual(changes.elements.count, 0)
    }

    func duplicateTraces(from: String, to: String) -> Bool {
        let traces = from.diffTraces(to: to)
        let tracesSet = Set(traces)
        return !(traces.count == tracesSet.count)
    }

    func tracesOutOfBounds(from: String, to: String) -> [Trace] {
        let ac = from
        let bc = to
        return ac.diffTraces(to: bc)
            .filter { $0.to.y > bc.count || $0.to.x > ac.count }
    }

    func _test(
        from: String,
        to: String) -> String {
        return from
            .diff(to)
            .reduce("") { $0 + $1.debugDescription }
    }

    func _testExtended(
        from: String,
        to: String) -> String {
        return from
            .extendedDiff(to)
            .reduce("") { $0 + $1.debugDescription }
    }
}
