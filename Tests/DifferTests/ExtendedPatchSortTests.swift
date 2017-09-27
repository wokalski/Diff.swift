import XCTest
@testable import Differ

class ExtendedPatchSortTests: XCTestCase {

    func testDefaultOrder() {
        let expectations = [
            ("gitten", "sitting", "M(0,5)I(0,s)D(4)I(4,i)"),
            ("Oh Hi", "Hi Oh", "M(0,4)M(0,4)M(0,2)"),
            ("12345", "12435", "M(2,3)"),
            ("1362", "31526", "M(0,2)M(1,3)I(2,5)"),
            ("221", "122", "M(2,0)")
        ]

        for expectation in expectations {
            XCTAssertEqual(
                _extendedTest(from: expectation.0, to: expectation.1),
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
                    from: expectation.0,
                    to: expectation.1,
                    sortingFunction: sort),
                expectation.2)
        }
    }

    func testDeletionMoveInsertion() {
        let expectations = [
            ("gitten", "sitting", "D(4)M(0,4)I(0,s)I(4,i)"),
            ("1362", "31526", "M(0,2)M(1,3)I(2,5)"),
            ("a1b2c3pq", "3sa1cz2rb", "D(7)D(6)M(5,0)M(3,5)M(3,4)I(1,s)I(5,z)I(7,r)")
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
                    from: expectation.0,
                    to: expectation.1,
                    sortingFunction: sort),
                expectation.2)
        }
    }

    func testRandomStringPermutationRandomPatchSort() {

        let sort: ExtendedSortingFunction = { _, _ in arc4random_uniform(2) == 0
        }
        for _ in 0 ..< 20 {
            let string1 = "eakjnrsignambmcbdcdhdkmhkolpdgfedcpgabtldjkaqkoobomuhpepirdcrdrgmrmaefesoiildmtnbronpmmbuuplnfnjgdhadkbmprensshiekknhskognpbknpbepmlakducnfktjeookncjpcnpklfedrebstisalskigsuojkookhbmkdafiaftrkrccupgjapqrigbanfbboapmicabeclhentlabourhtqmlboqctgorajirchesaorsgnigattkdrenquffcutffopbjrebegbfmkeikstqsut"
            let string2 = "mdjqtbchphncsjdkjtutagahmdtfcnjliipmqgrhgajsgotcdgidlghithdgrcmfuausmjnbtjghqblaiuldirulhllidbpcpglfbnfbkbddhdskdplsgjjsusractdplajrctgrcebhesbeneidsititlalsqkhliontgpesglkoorjqeniqaetatamneonhbhunqlfkbmfsjallnejhkcfaeapdnacqdtukcuiheiabqpudmgosssabisrrlmhcmpkgerhesqihdnfjmqgfnmulnfkmpqrsghutfsckurr"
            let patch = string1.extendedDiff(string2).patch(
                from: string1,
                to: string2,
                sort: sort)
            let result = string1.apply(patch)
            XCTAssertEqual(result, string2)
        }
    }
}

typealias ExtendedSortingFunction = (ExtendedDiff.Element, ExtendedDiff.Element) -> Bool

func _extendedTest(
    from: String,
    to: String,
    sortingFunction: ExtendedSortingFunction? = nil) -> String {
    guard let sort = sortingFunction else {
        return extendedPatch(
            from: from,
            to: to)
            .reduce("") { $0 + $1.debugDescription }
    }
    return extendedPatch(
        from: from,
        to: to,
        sort: sort)
        .reduce("") { $0 + $1.debugDescription }
}
