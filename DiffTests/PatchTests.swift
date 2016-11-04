import XCTest
import Diff

let defaultOrder = [
//    ("kitten", "sitting", "D(0)I(0,s)D(4)I(4,i)I(6,g)"),
//    ("🐩itt🍨ng", "kitten", "D(0)I(0,k)D(4)I(4,e)D(6)"),
    ("1234", "A", "D(0)D(0)D(0)D(0)I(0,A)"),
    
    // "D(0)D(1)D(2)D(3)I(0,A)I(1,B)I(2,C)I(3,D)"
    // " 0    -1  -2  -3   0     0     0     0"
    // "length(4) - originalLength(4)
    // "length(3) - originalLength(4)
    // "length(2) - originalLength(4)
    // "length(1) - originalLength(4)
    // "length(0) - originalLength(4)
    
//    ("1234", "", "D(0)D(1)D(2)D(3)"),
//    ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
//    ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
//    ("Hi", "Hi O", "I(2, )I(3,O)"),
//    ("Hi O", "Hi", "D(2)D(3)"),
//    ("Wojtek", "Wojciech", "D(3)I(3,c)I(4,i)D(5)I(6,c)I(7,h)"),
//    ("1234", "1234", ""),
//    ("", "", ""),
//    ("Oh Hi", "Hi Oh", "D(0)D(1)D(2)I(2, )I(3,O)I(4,h)"),
//    ("1362", "31526", "D(0)D(2)I(1,1)I(2,5)I(4,6)")
]

// I(0)I(4)I(6)D(0)D(4)
// [(I(0,s),0), (D(0),3), (I(4,i), 1), (D(4), 4), (I(6,g), 2)]
//0     0          +1          0           +1          0
// I(0,s)I(4,i)I(6,g)D(1)D(5)

// Map {0: [I(s), D], }

/*
 * Since swift sorted is not stable we have to work around this.
 * Initially I wanted to implement a stable sort algorithm. Simple enough, but not efficient.
 * The go to stable sorting algorithm is merge sort but it is not efficient.
 * Especially considering Swift's value semantics which results in many copies
 * ----
 * If we look at our data though, it become apparent that we have data which can be arbitraly sorted. We don't have to compare it, we just need to insert it in correct spots
 * Every `DiffElement` has its key which can be used to sort them.
 * There are many algorithms for such sorting including counting sort or radix sort
 * They could be however extremely inefficient under some circumstances
 * Therefore we will resort to the simplest possible algorithm
 * We will create a Dictionary and insert particular DiffElements according to their key
 * Then we need to sort Dictionary's keys and map the dictionary back into an array.
 */


let insertionsFirst = [
    ("kitten", "sitting", "I(0,s)I(4,i)I(6,g)D(1)D(5)"),
    // D(0)I(0)D(4)I(4)I(6)
    // I(0)I(4)I(6)D(0)D(4)
    //0 [0][0,4] +6  1   1
    // I(0)I(4)I(6)D(1)D(5)
    // I(0,s)I(4,i)I(6,g)D(1)D(5)
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

//let deletionsFirst = [
//    ("kitten", "sitting", "I(0,s)I(4,i)I(6,g)D(1)D(5)"),
//    ("🐩itt🍨ng", "kitten", "I(0,k)I(5,e)D(1)D(6)D(8)"),
//    ("1234", "ABCD", "I(0,A)I(1,B)I(2,C)I(3,D)D(4)D(5)D(6)D(7)"),
//    ("1234", "", "D(0)D(1)D(2)D(3)"),
//    ("", "1234", "I(0,1)I(1,2)I(2,3)I(3,4)"),
//    ("Hi", "Oh Hi", "I(0,O)I(1,h)I(2, )"),
//    ("Hi", "Hi O", "I(2, )I(3,O)"),
//    ("Hi O", "Hi", "D(2)D(3)"),
//    ("Wojciech", "Wojciech", "I(3,c)I(4,i)I(6,c)I(7,h)D(5)D(8)"),
//    ("1234", "1234", ""),
//    ("", "", ""),
//    ("Oh Hi", "Hi Oh", "I(5, )I(6,O)I(7,h)D(0)D(1)D(2)"),
//    ("1362", "31526", "I(2,1)I(3,5)I(4,6)D(0)D(4)")
//]

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



