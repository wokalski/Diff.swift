//
//  DiffTests.swift
//  DiffTests
//
//  Created by Wojciech Czekalski on 03.07.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import XCTest
import Diff

extension Trace: Hashable {
    public var hashValue: Int {
        return (((51 + from.x.hashValue) * 51 + from.y.hashValue) * 51 + to.x.hashValue) * 51 + to.y.hashValue
    }
}

let expectations = [
    ("kitten", "sitting", "D(0)I(00)D(4)I(44)I(66)"),
    ("sitting", "kitten", "D(0)I(00)D(4)I(44)D(6)"),
    ("1234", "ABCD", "D(0)D(1)D(2)D(3)I(00)I(11)I(22)I(33)"),
    ("1234", "", "D(0)D(1)D(2)D(3)"),
    ("", "1234", "I(00)I(11)I(22)I(33)"),
    ("Hi", "Oh Hi", "I(00)I(11)I(22)"),
    ("Hi", "Hi O", "I(22)I(33)"),
    ("Oh Hi", "Hi", "D(0)D(1)D(2)"),
    ("Hi O", "Hi", "D(2)D(3)"),
    ("Wojtek", "Wojciech", "D(3)I(33)I(44)D(5)I(66)I(77)"),
    ("1234", "1234", ""),
    ("", "", "")
]

class DiffTests: XCTestCase {
    
    func testDiffOutputs() {
        for expectation in expectations {
            XCTAssertEqual(
                _test(expectation.0, to: expectation.1),
                expectation.2)
        }
    }
    
    // The tests below check efficiency of the algorithm
    
    func testDuplicateTraces() {
        for expectation in expectations {
            XCTAssertFalse(duplicateTraces(expectation.0, b: expectation.1))
        }
    }
    
    func testTracesOutOfBounds() {
        for expectation in expectations {
            if tracesOutOfBounds(expectation.0, b: expectation.1) != [] {
                XCTFail("traces out of bounds for \(expectation.0) -> \(expectation.1)")
            }
        }
    }
    
    func duplicateTraces(a: String, b: String) -> Bool {
        let traces = a.characters.diffTraces(b.characters)
        let tracesSet = Set(traces)
        return !(traces.count == tracesSet.count)
    }
    
    func tracesOutOfBounds(a: String, b: String) -> [Trace] {
        let ac = a.characters
        let bc = b.characters
        return ac.diffTraces(bc)
            .filter { $0.to.y > bc.count || $0.to.x > ac.count }
    }
    
    func _test(
        from: String,
        to: String) -> String {
        return from
            .diff(to)
            .reduce("") { $0 + $1.debugDescription }
    }
}

extension DiffElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let Delete(at):
            return "D(\(at))"
        case let Insert(from, at):
            return "I(\(from)\(at))"
        }
    }
}
