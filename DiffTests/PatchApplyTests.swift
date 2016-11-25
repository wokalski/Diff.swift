import XCTest
@testable import Diff

class PatchApplyTests: XCTestCase {
    func testString() {

        let testCases: [(String, String, String)] = [
            ("", "I(0,A)I(0,B)I(0,C)", "CBA"),
            ("", "I(0,A)I(1,B)I(1,C)", "ACB"),
            ("AB", "D(1)I(1,B)I(1,C)", "ACB"),
            ("AB", "I(1,B)D(0)I(1,C)", "BCB"),
            ("A", "I(0,B)D(0)", "A"),
        ]

        testCases.forEach { seed, patchString, result in
            XCTAssertEqual(seed.apply(stringPatch(from: patchString)), result)
        }
    }

    func testCollection() {

        let testCases: [([Int], String, [Int])] = [
            ([], "I(0,0)I(0,1)I(0,2)", [2, 1, 0]),
            ([], "I(0,0)I(1,1)I(1,2)", [0, 2, 1]),
            ([0, 1], "D(1)I(1,1)I(1,2)", [0, 2, 1]),
            ([0, 1], "I(1,1)D(0)I(1,2)", [1, 2, 1]),
            ([0], "I(0,1)D(0)", [0]),
        ]

        testCases.forEach { seed, patchString, result in
            XCTAssertEqual(seed.apply(intPatch(from: patchString)), result)
        }
    }
}

func stringPatch(from textualRepresentation: String) -> [Patch<String.CharacterView.Iterator.Element>] {
    return textualRepresentation.components(separatedBy: ")").flatMap { string in
        if string == "" {
            return nil
        }
        let type = string.substring(to: string.index(after: string.startIndex))
        if type == "D" {
            let index = Int(string.substring(from: string.index(string.startIndex, offsetBy: 2)))!
            return .deletion(index: index)
        } else if type == "I" {
            let indexAndElement = string.substring(from: string.index(string.startIndex, offsetBy: 2)).components(separatedBy: ",")
            return .insertion(index: Int(indexAndElement[0])!, element: indexAndElement[1].characters.first!)
        } else {
            return nil
        }
    }
}

func intPatch(from textualRepresentation: String) -> [Patch<Int>] {
    return textualRepresentation.components(separatedBy: ")").flatMap { string in
        if string == "" {
            return nil
        }
        let type = string.substring(to: string.index(after: string.startIndex))
        if type == "D" {
            let index = Int(string.substring(from: string.index(string.startIndex, offsetBy: 2)))!
            return .deletion(index: index)
        } else if type == "I" {
            let indexAndElement = string.substring(from: string.index(string.startIndex, offsetBy: 2)).components(separatedBy: ",")
            let index = Int(indexAndElement[0])!
            let element = Int(indexAndElement[1])!
            return .insertion(index: index, element: element)
        } else {
            return nil
        }
    }
}
