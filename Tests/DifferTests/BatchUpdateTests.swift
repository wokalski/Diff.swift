#if !os(macOS) && !os(watchOS)

    import XCTest
    @testable import Differ

    func IP(_ row: Int, _ section: Int) -> IndexPath {
        return IndexPath(row: row, section: section)
    }

    class BatchUpdateTests: XCTestCase {

        let cellExpectations: [([Int], [Int], ([IndexPath], [IndexPath], [(from: IndexPath, to: IndexPath)]))] = [
            ([1, 2, 3, 4], [1, 2, 3, 4], ([], [], [])),
            ([1, 2, 3, 4], [4, 2, 3, 1], ([], [], [(IP(0, 0), IP(3, 0)), (IP(3, 0), IP(0, 0))])),
            ([1, 2, 3, 4], [2, 3, 1], ([IP(3, 0)], [], [(IP(0, 0), IP(2, 0))])),
            ([1, 2, 3, 4], [5, 2, 3, 4], ([IP(0, 0)], [IP(0, 0)], [])),
            ([1, 2, 3, 4], [4, 1, 3, 5], ([IP(1, 0)], [IP(3, 0)], [(IP(2, 0), IP(0, 0))])),
            ([1, 2, 3, 4], [4, 2, 3, 4], ([IP(0, 0)], [IP(0, 0)], [])),
            ([1, 2, 3, 4], [1, 2, 4, 4], ([IP(2, 0)], [IP(3, 0)], [])),
            ([1, 2, 3, 4], [5, 6, 7, 8], ([IP(0, 0), IP(1, 0), IP(2, 0), IP(3, 0)], [IP(0, 0), IP(1, 0), IP(2, 0), IP(3, 0)], [])),
            ([1, 2, 3, 4], [5, 6, 7, 1], ([IP(1, 0), IP(2, 0), IP(3, 0)], [IP(0, 0), IP(1, 0), IP(2, 0)], []))
        ]

        func testCells() {
            _testCells()
        }

        func testCellsWithTransform() {
            _testCellsWithTransform()
        }

        func _testCells() {
            for expectation in cellExpectations {
                let batch = BatchUpdate(diff: expectation.0.extendedDiff(expectation.1))
                XCTAssertEqual(batch.deletions, expectation.2.0)
                XCTAssertEqual(batch.insertions, expectation.2.1)
                XCTAssertEqual(batch.moves, expectation.2.2)
            }
        }

        func _testCellsWithTransform() {
            let transform: (IndexPath) -> IndexPath = { IP($0.row + 1, $0.section + 2) }

            for expectation in cellExpectations {
                let batch = BatchUpdate(diff: expectation.0.extendedDiff(expectation.1), indexPathTransform: transform)
                XCTAssertEqual(batch.deletions, expectation.2.0.map(transform))
                XCTAssertEqual(batch.insertions, expectation.2.1.map(transform))
                XCTAssertEqual(batch.moves, expectation.2.2.map { (transform($0.0), transform($0.1)) })
            }
        }

        //
        //    // MARK: Performance Tests
        //    func testCellsPerformance() {
        //        self.measure {
        //            self._testCells()
        //        }
        //    }
        //
        //    func testCellsWithTransformPerformance() {
        //        self.measure {
        //            self._testCellsWithTransform()
        //        }
        //    }
    }

#endif
