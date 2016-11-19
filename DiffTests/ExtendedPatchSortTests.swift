
import XCTest
import Diff

class ExtendedPatchSortTests: XCTestCase {
    
    func testDefaultOrder() {
        let expectations = [
            ("gitten", "sitting", "M(0,5)I(0,s)D(4)I(4,i)"),
            ("Oh Hi", "Hi Oh", "M(0,4)M(0,4)M(0,2)"),
            ("12345", "12435", "M(2,3)"),
            ("1362", "31526", "M(0,2)M(1,3)I(2,5)")
        ]
        
        for expectation in expectations {
            XCTAssertEqual(
                _extendedTest(expectation.0, to: expectation.1),
                expectation.2)
        }
    }
    
    func testInsertionDeletionMove() {
        let expectations = [
            ("gitten", "sitting", "I(5,i)I(1,s)D(5)M(0,6)"),
            ("1362", "31526", "I(3,5)M(0,2)M(1,4)")
        ]
        
        let sort: ExtendedSortingFunction = { fst, snd in
            switch (fst, snd) {
            case (.insert, _):
                return true
            case (.delete, .insert):
                return false
            case (.delete, _):
                return true
            case (.move, _):
                return false
            }
        }
        
        for expectation in expectations {
            XCTAssertEqual(
                _extendedTest(
                    expectation.0,
                    to: expectation.1,
                    sortingFunction: sort),
                expectation.2)
        }
    }
    
    func testDeletionMoveInsertion() {
        let expectations = [
            ("gitten", "sitting", "D(4)M(0,4)I(0,s)I(4,i)"),
            ("1362", "31526", "M(0,2)M(1,3)I(2,5)")
        ]
        
        let sort: ExtendedSortingFunction = { fst, snd in
            switch (fst, snd) {
            case (.delete, _):
                return true
            case (.insert, _):
                return false
            case (.move, .insert):
                return true
            case (.move, _):
                return false
            }
        }
        
        for expectation in expectations {
            XCTAssertEqual(
                _extendedTest(
                    expectation.0,
                    to: expectation.1,
                    sortingFunction: sort),
                expectation.2)
        }
    }
    
    func testRandomStringPermutationRandomPatchSort() {
        
        let sort: ExtendedSortingFunction = { _, _ in arc4random_uniform(2) == 0
        }
        for _ in 0..<30 {
            let randomString = randomAlphaNumericString(length: 30)
            let permutation = randomAlphaNumericString(length: 30)
            let patch = randomString.extendedDiff(permutation).patch(
                randomString.characters,
                b: permutation.characters,
                sort:sort)
            let result = randomString.apply(patch)
            XCTAssertEqual(result, permutation)
        }
    }
}

typealias ExtendedSortingFunction = (ExtendedDiffElement, ExtendedDiffElement) -> Bool

func _extendedTest(
    _ from: String,
    to: String,
    sortingFunction: ExtendedSortingFunction? = nil) -> String {
    guard let sort = sortingFunction else {
        return from
            .extendedDiff(to)
            .patch(
                from.characters,
                b: to.characters)
            .reduce("") { $0 + $1.debugDescription }
    }
    return from
        .extendedDiff(to)
        .patch(
            from.characters,
            b: to.characters,
            sort: sort)
        .reduce("") { $0 + $1.debugDescription }
}
