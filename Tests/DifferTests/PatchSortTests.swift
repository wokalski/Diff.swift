import XCTest
@testable import Differ

class PatchTests: XCTestCase {

    func testDefaultOrder() {

        let defaultOrder = [
            ("kitten", "sitting", "D(0)I(0,s)D(4)I(4,i)I(6,g)"),
            ("🐩itt🍨ng", "kitten", "D(0)I(0,k)D(4)I(4,e)D(6)"),
            ("1234", "ABCD", "D(0)D(0)D(0)D(0)I(0,A)I(1,B)I(2,C)I(3,D)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "D(3)I(3,c)I(4,i)D(6)I(6,c)I(7,h)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "D(0)D(0)D(0)I(2, )I(3,O)I(4,h)"),
            ("1362", "31526", "D(0)D(1)I(1,1)I(2,5)I(4,6)"),
            ("1234b2", "ab", "D(0)D(0)D(0)D(0)I(0,a)D(2)")
        ]

        for expectation in defaultOrder {
            XCTAssertEqual(
                _test(from: expectation.0, to: expectation.1),
                expectation.2)
        }
    }

    func testInsertionsFirst() {

        let insertionsFirst = [
            ("kitten", "sitting", "I(1,s)I(6,i)I(8,g)D(0)D(4)"),
            ("🐩itt🍨ng", "kitten", "I(1,k)I(6,e)D(0)D(4)D(6)"),
            ("1234", "ABCD", "I(4,A)I(5,B)I(6,C)I(7,D)D(0)D(0)D(0)D(0)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "I(4,c)I(5,i)I(8,c)I(9,h)D(3)D(6)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "I(5, )I(6,O)I(7,h)D(0)D(0)D(0)"),
            ("1362", "31526", "I(3,1)I(4,5)I(6,6)D(0)D(1)")
        ]

        let insertionsFirstSort = { (element1: Diff.Element, element2: Diff.Element) -> Bool in
            switch (element1, element2) {
            case let (.insert(at1), .insert(at2)):
                return at1 < at2
            case (.insert(_), .delete(_)):
                return true
            case (.delete(_), .insert(_)):
                return false
            case let (.delete(at1), .delete(at2)):
                return at1 < at2
            }
        }

        for expectation in insertionsFirst {
            XCTAssertEqual(
                _test(
                    from: expectation.0,
                    to: expectation.1,
                    sortingFunction: insertionsFirstSort),
                expectation.2)
        }
    }

    func testDeletionsFirst() {

        let deletionsFirst = [
            ("kitten", "sitting", "D(0)D(3)I(0,s)I(4,i)I(6,g)"),
            ("🐩itt🍨ng", "kitten", "D(0)D(3)D(4)I(0,k)I(4,e)"),
            ("1234", "ABCD", "D(0)D(0)D(0)D(0)I(0,A)I(1,B)I(2,C)I(3,D)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "D(3)D(4)I(3,c)I(4,i)I(6,c)I(7,h)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "D(0)D(0)D(0)I(2, )I(3,O)I(4,h)"),
            ("1362", "31526", "D(0)D(1)I(1,1)I(2,5)I(4,6)")
        ]

        let deletionsFirstSort = { (element1: Diff.Element, element2: Diff.Element) -> Bool in
            switch (element1, element2) {
            case let (.insert(at1), .insert(at2)):
                return at1 < at2
            case (.insert(_), .delete(_)):
                return false
            case (.delete(_), .insert(_)):
                return true
            case let (.delete(at1), .delete(at2)):
                return at1 < at2
            }
        }

        for expectation in deletionsFirst {
            XCTAssertEqual(
                _test(
                    from: expectation.0,
                    to: expectation.1,
                    sortingFunction: deletionsFirstSort),
                expectation.2)
        }
    }

    func testRandomStringPermutationRandomPatchSort() {

        let sort = { (_: Diff.Element, _: Diff.Element) -> Bool in
            arc4random_uniform(2) == 0
        }
        for _ in 0 ..< 200 {
            let randomString = randomAlphaNumericString(length: 30)
            let permutation = randomAlphaNumericString(length: 30)
            let patch = randomString.diff(permutation).patch(from: randomString, to: permutation, sort: sort)
            let result = randomString.apply(patch)
            XCTAssertEqual(result, permutation)
        }
    }
}

func randomAlphaNumericString(length: Int) -> String {

    let allowedChars = "abcdefghijklmnopqrstu"
    let allowedCharsCount = UInt32(allowedChars.count)
    var randomString = ""

    for _ in 0 ..< length {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }

    return randomString
}

typealias SortingFunction = (Diff.Element, Diff.Element) -> Bool

func _test(
    from: String,
    to: String,
    sortingFunction: SortingFunction? = nil) -> String {
    if let sort = sortingFunction {
        return patch(
            from: from,
            to: to,
            sort: sort)
            .reduce("") { $0 + $1.debugDescription }
    }
    return patch(
        from: from,
        to: to)
        .reduce("") { $0 + $1.debugDescription }
}
