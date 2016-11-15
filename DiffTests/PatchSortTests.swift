import XCTest
import Diff

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
                _test(expectation.0, to: expectation.1),
                expectation.2)
        }
    }
    
    func testInsertionsFirst() {
        
        let insertionsFirst = [
            ("kitten", "sitting", "I(0,s)I(5,i)I(8,g)D(1)D(5)"),
            ("🐩itt🍨ng", "kitten", "I(0,k)I(5,e)D(1)D(5)D(6)"),
            ("1234", "ABCD", "I(0,A)I(1,B)I(2,C)I(3,D)D(4)D(4)D(4)D(4)"),
            ("1234", "", "D(0)D(0)D(0)D(0)"),
            ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
            ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
            ("Hi", "Hi O", "I(2, )I(3,O)"),
            ("Hi O", "Hi", "D(2)D(2)"),
            ("Wojtek", "Wojciech", "I(3,c)I(4,i)I(7,c)I(8,h)D(5)D(8)"),
            ("1234", "1234", ""),
            ("", "", ""),
            ("Oh Hi", "Hi Oh", "I(5, )I(6,O)I(7,h)D(0)D(0)D(0)"),
            ("1362", "31526", "I(2,1)I(3,5)I(6,6)D(0)D(3)")
        ]
        
        let insertionsFirstSort = { (element1: DiffElement, element2: DiffElement) -> Bool in
            switch (element1, element2) {
            case (.insert(let at1), .insert(let at2)):
                return at1 < at2
            case (.insert, .delete):
                return true
            case (.delete, .insert):
                return false
            case (.delete(let at1), .delete(let at2)):
                return at1 < at2
            default: fatalError()
            }
        }
        
        for expectation in insertionsFirst {
            XCTAssertEqual(
                _test(
                    expectation.0,
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
        
        let deletionsFirstSort = { (element1: DiffElement, element2: DiffElement) -> Bool in
            switch (element1, element2) {
            case (.insert(let at1), .insert(let at2)):
                return at1 < at2
            case (.insert, .delete):
                return false
            case (.delete, .insert):
                return true
            case (.delete(let at1), .delete(let at2)):
                return at1 < at2
            default: fatalError()
            }
        }
        
        for expectation in deletionsFirst {
            XCTAssertEqual(
                _test(
                    expectation.0,
                    to: expectation.1,
                    sortingFunction: deletionsFirstSort),
                expectation.2)
        }
    }
}

typealias SortingFunction = (DiffElement, DiffElement) -> Bool

func _test(
    _ from: String,
    to: String,
    sortingFunction: SortingFunction? = nil) -> String {
    if let sort = sortingFunction {
        return from
            .diff(to)
            .patch(
                from.characters,
                b: to.characters,
                sort: sort)
            .reduce("") { $0 + $1.debugDescription }
    }
    return from
        .diff(to)
        .patch(
            from.characters,
            b: to.characters)
        .reduce("") { $0 + $1.debugDescription }
}



