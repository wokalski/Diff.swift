@testable import Differ
import XCTest

private func IP(_ row: Int, _ section: Int) -> IndexPath {
    return [section, row]
}

class BatchUpdateTests: XCTestCase {
    private struct Expectation {
        let orderBefore: [Int]
        let orderAfter: [Int]
        let insertions: [IndexPath]
        let deletions: [IndexPath]
        let moves: [BatchUpdate.MoveStep]
    }

    private let cellExpectations: [Expectation] = [
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [1, 2, 3, 4], insertions: [], deletions: [], moves: []),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [4, 2, 3, 1], insertions: [], deletions: [], moves: [BatchUpdate.MoveStep(from: IP(0, 0), to: IP(3, 0)), BatchUpdate.MoveStep(from: IP(3, 0), to: IP(0, 0))]),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [2, 3, 1], insertions: [], deletions: [IP(3, 0)], moves: [BatchUpdate.MoveStep(from: IP(0, 0), to: IP(2, 0))]),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [5, 2, 3, 4], insertions: [IP(0, 0)], deletions: [IP(0, 0)], moves: []),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [4, 1, 3, 5], insertions: [IP(3, 0)], deletions: [IP(1, 0)], moves: [BatchUpdate.MoveStep(from: IP(3, 0), to: IP(0, 0))]),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [4, 2, 3, 4], insertions: [IP(0, 0)], deletions: [IP(0, 0)], moves: []),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [1, 2, 4, 4], insertions: [IP(3, 0)], deletions: [IP(2, 0)], moves: []),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [5, 6, 7, 8], insertions: [IP(0, 0), IP(1, 0), IP(2, 0), IP(3, 0)], deletions: [IP(0, 0), IP(1, 0), IP(2, 0), IP(3, 0)], moves: []),
        Expectation(orderBefore: [1, 2, 3, 4], orderAfter: [5, 6, 7, 1], insertions: [IP(0, 0), IP(1, 0), IP(2, 0)], deletions: [IP(1, 0), IP(2, 0), IP(3, 0)], moves: [])
    ]

    func testCells() {
        self._testCells()
    }

    func testCellsWithTransform() {
        self._testCellsWithTransform()
    }

    func _testCells() {
        for expectation in self.cellExpectations {
            let batch = BatchUpdate(diff: expectation.orderBefore.extendedDiff(expectation.orderAfter))
            XCTAssertEqual(batch.deletions, expectation.deletions)
            XCTAssertEqual(batch.insertions, expectation.insertions)
            XCTAssertEqual(batch.moves, expectation.moves)
        }
    }

    func _testCellsWithTransform() {
        let transform: (IndexPath) -> IndexPath = { IP($0.item + 1, $0.section + 2) }

        for expectation in self.cellExpectations {
            let batch = BatchUpdate(diff: expectation.orderBefore.extendedDiff(expectation.orderAfter), indexPathTransform: transform)
            XCTAssertEqual(batch.deletions, expectation.deletions.map(transform))
            XCTAssertEqual(batch.insertions, expectation.insertions.map(transform))
            XCTAssertEqual(batch.moves, expectation.moves.map { BatchUpdate.MoveStep(from: transform($0.from), to: transform($0.to)) })
        }
    }
}
