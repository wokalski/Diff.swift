import XCTest
@testable import Differ

struct KeyedIntArray: Equatable {
    let elements: [Int]
    let key: Int

    public static func ==(fst: KeyedIntArray, snd: KeyedIntArray) -> Bool {
        return fst.key == snd.key
    }
}

extension Array: Equatable {
    public static func ==<T>(fst: Array<T>, snd: Array<T>) -> Bool {
        return fst.count == snd.count
    }
}

extension KeyedIntArray: Collection {
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public typealias IndexType = Array<Int>.Index

    public var startIndex: IndexType {
        return elements.startIndex
    }

    public var endIndex: IndexType {
        return elements.endIndex
    }

    public subscript(i: IndexType) -> Int {
        return elements[i]
    }
}

class NestedDiffTests: XCTestCase {

    func testDiffOutputs() {

        let keyedExpectations = [
            (
                [],
                [
                    KeyedIntArray(elements: [1, 2], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                "IS(0)IS(1)"
            ),
            (
                [
                    KeyedIntArray(elements: [2], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                [
                    KeyedIntArray(elements: [1], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                "DE(0,0)IE(0,0)DE(0,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [2], key: 0),
                    KeyedIntArray(elements: [0], key: 5),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                [
                    KeyedIntArray(elements: [1], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                "DS(1)DE(0,0)IE(0,0)DE(0,2)"
            ),
            (
                [
                    KeyedIntArray(elements: [2], key: 0),
                    KeyedIntArray(elements: [0], key: 5),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                [
                    KeyedIntArray(elements: [1], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                "DS(1)DE(0,0)IE(0,0)DE(0,2)"
            ),
            (
                [
                    KeyedIntArray(elements: [2], key: 0),
                    KeyedIntArray(elements: [1, 2, 3], key: -1),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                [
                    KeyedIntArray(elements: [2, 3], key: 0),
                    KeyedIntArray(elements: [1, 2], key: 1)
                ],
                "DS(1)IE(1,0)IE(1,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [2], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                [
                    KeyedIntArray(elements: [2, 1], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                "IE(1,0)DE(0,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [], key: 0),
                    KeyedIntArray(elements: [1, 2], key: 1)
                ],
                [
                    KeyedIntArray(elements: [2], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                "IE(0,0)DE(0,1)DE(1,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [1, 2], key: 0),
                    KeyedIntArray(elements: [], key: 1)
                ],
                [
                    KeyedIntArray(elements: [], key: 0),
                    KeyedIntArray(elements: [1], key: 1)
                ],
                "DE(0,0)DE(1,0)IE(0,1)"
            ),
            (
                [
                    KeyedIntArray(elements: [], key: 0),
                    KeyedIntArray(elements: [1], key: 1),
                    KeyedIntArray(elements: [2], key: 2)
                ],
                [
                    KeyedIntArray(elements: [1, 2], key: 0),
                    KeyedIntArray(elements: [], key: 1),
                    KeyedIntArray(elements: [], key: 2)
                ],
                "IE(0,0)IE(1,0)DE(0,1)DE(0,2)"
            )
        ]

        let expectations: [([[Int]], [[Int]], String)] = [
            (
                [],
                [
                    [1, 2],
                    [1]
                ],
                "IS(0)IS(1)"
            ),
            (
                [
                    [1, 2],
                    []
                ],
                [],
                "DS(0)DS(1)"
            ),
            (
                [[1, 2], [], [1]],
                [[1, 2], [], [1]],
                ""
            ),
            (
                [[1, 2], [1, 4]],
                [[5, 2], [10, 4, 8]],
                "DS(1)IS(1)DE(0,0)IE(0,0)"
            ),
            (
                [[1]],
                [[], [1, 2]],
                "DS(0)IS(0)IS(1)"
            ),
            (
                [[1]],
                [[], [2]],
                "IS(0)DE(0,0)IE(0,1)"
            )
        ]

        for expectation in expectations {
            XCTAssertEqual(
                _test(from: expectation.0, to: expectation.1),
                expectation.2)
        }

        for expectation in keyedExpectations {
            XCTAssertEqual(
                _test(from: expectation.0, to: expectation.1),
                expectation.2)
        }
    }

    func _test<T: Collection>(
        from: [T],
        to: [T]) -> String
        where
        T: Equatable,
        T.Iterator.Element: Equatable {
        return from
            .nestedDiff(to: to)
            .reduce("") { $0 + $1.debugDescription }
    }
}
