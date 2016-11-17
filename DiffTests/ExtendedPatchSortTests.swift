
import XCTest
import Diff

class ExtendedPatchSortTests: XCTestCase {
    
    func testDefaultOrder() {
        let expectations = [
//            ("gitten", "sitting", "M(0,5)I(0,s)D(4)I(4,i)"),
            ("Oh Hi", "Hi Oh", "M(0,4)M(0,4)M(0,2)"),
//            ("12345", "12435", "M(2,3)"),
//            ("1362", "31526", "M(0,1)M(2,3)I(2,5)")
        ]
        
        for expectation in expectations {
            XCTAssertEqual(
                _extendedTest(expectation.0, to: expectation.1),
                expectation.2)
        }
    }
    
}

typealias ExtendedSortingFunction = (ExtendedDiffElement, ExtendedDiff) -> Bool

func _extendedTest(
    _ from: String,
    to: String,
    sortingFunction: SortingFunction? = nil) -> String {
    return from
        .extendedDiff(to)
        .patch(
            from.characters,
            b: to.characters)
        .reduce("") { $0 + $1.debugDescription }
}


