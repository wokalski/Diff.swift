
import XCTest
@testable import Diff

class NestedExtendedDiffTests: XCTestCase {
    
    func testDiffOutputs() {
        let expectations = [
            (
                [
                    KeyedIntArray(elements: [], key: 1),
                    KeyedIntArray(elements: [], key: 0)
                ],
                [
                    KeyedIntArray(elements: [], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                "MS(0,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [1], key: 1),
                    KeyedIntArray(elements: [1, 2], key: 0)
                ],
                [
                    KeyedIntArray(elements: [1, 2], key: 0),
                    KeyedIntArray(elements: [1, 2], key: 1)
                ],
                "MS(0,1)IE(1,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [1, 2], key: 1),
                    KeyedIntArray(elements: [1, 2], key: 0)
                ],
                [
                    KeyedIntArray(elements: [1, 2], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                "MS(0,1)DE(1,0)"
            ),
            (
                [
                    KeyedIntArray(elements: [1], key: 1),
                    KeyedIntArray(elements: [2, 1], key: 0)
                ],
                [
                    KeyedIntArray(elements: [1, 2], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                "MS(0,1)ME((0, 1),(1, 0))"
            ),
            (
                [
                    KeyedIntArray(elements: [1], key: 1),
                    KeyedIntArray(elements: [2, 1], key: 0)
                ],
                [
                    KeyedIntArray(elements: [2, 1], key: 0),
                ],
                "DS(0)"
            ),
            (
                [
                    KeyedIntArray(elements: [1], key: 1),
                ],
                [
                    KeyedIntArray(elements: [1], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                "IS(0)"
            ),
        ]
        
        for expectation in expectations {
            XCTAssertEqual(_test(from: expectation.0, to: expectation.1), expectation.2)
        }
    }
    
    func _test<T: Collection>(from: T,to: T) -> String
        where T.Iterator.Element: Collection,
        T.Iterator.Element: Equatable,
        T.Iterator.Element.Iterator.Element: Equatable {
            return from
                .nestedExtendedDiff(to: to)
                .reduce("") { $0 + $1.debugDescription }
    }
}
