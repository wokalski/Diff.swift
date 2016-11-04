import XCTest
import Diff

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
    ("1362", "31526", "D(0)D(1)I(1,1)I(2,5)I(4,6)")
]

let insertionsFirst = [
    ("kitten", "sitting", "I(0,s)I(4,i)I(6,g)D(1)D(5)"),
    ("🐩itt🍨ng", "kitten", "I(0,k)I(5,e)D(1)D(6)D(8)"),
    ("1234", "ABCD", "I(0,A)I(1,B)I(2,C)I(3,D)D(4)D(5)D(6)D(7)"),
    ("1234", "", "D(0)D(1)D(2)D(3)"),
    ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
    ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
    ("Hi", "Hi O", "I(2, )I(3,O)"),
    ("Hi O", "Hi", "D(2)D(3)"),
    ("Wojciechk", "Wojciech", "I(3,c)I(4,i)I(6,c)I(7,h)D(5)D(8)"),
    ("1234", "1234", ""),
    ("", "", ""),
    ("Oh Hi", "Hi Oh", "I(5, )I(6,O)I(7,h)D(0)D(1)D(2)"),
    ("1362", "31526", "I(2,1)I(3,5)I(4,6)D(0)D(4)")
]

let deletionsFirst = [
    ("kitten", "sitting", "I(0,s)I(4,i)I(6,g)D(1)D(5)"),
    ("🐩itt🍨ng", "kitten", "I(0,k)I(5,e)D(1)D(6)D(8)"),
    ("1234", "ABCD", "I(0,A)I(1,B)I(2,C)I(3,D)D(4)D(5)D(6)D(7)"),
    ("1234", "", "D(0)D(1)D(2)D(3)"),
    ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
    ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
    ("Hi", "Hi O", "I(2, )I(3,O)"),
    ("Hi O", "Hi", "D(2)D(3)"),
    ("Wojciech", "Wojciech", "I(3,c)I(4,i)I(6,c)I(7,h)D(5)D(8)"),
    ("1234", "1234", ""),
    ("", "", ""),
    ("Oh Hi", "Hi Oh", "I(5, )I(6,O)I(7,h)D(0)D(1)D(2)"),
    ("1362", "31526", "I(2,1)I(3,5)I(4,6)D(0)D(4)")
]

class PatchTests: XCTestCase {

    func testDefaultOrder() {
        for expectation in defaultOrder {
            XCTAssertEqual(
                _test(expectation.0, to: expectation.1),
                expectation.2)
        }
    }
}

func _test(
    _ from: String,
    to: String) -> String {
    return from
        .diff(to)
        .patch(from.characters, b: to.characters)
        .reduce("") { $0 + $1.debugDescription }
    
}



