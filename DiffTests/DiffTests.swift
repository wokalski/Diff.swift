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
    ("kitten", "sitting", "D(0)I(0)D(4)I(4)I(6)"),
    ("sitting", "kitten", "D(0)I(0)D(4)I(4)D(6)"),
    ("1234", "ABCD", "D(0)D(1)D(2)D(3)I(0)I(1)I(2)I(3)"),
    ("1234", "", "D(0)D(1)D(2)D(3)"),
    ("", "1234", "I(0)I(1)I(2)I(3)"),
    ("Hi", "Oh Hi", "I(0)I(1)I(2)"),
    ("Hi", "Hi O", "I(2)I(3)"),
    ("Oh Hi", "Hi", "D(0)D(1)D(2)"),
    ("Hi O", "Hi", "D(2)D(3)"),
    ("Wojtek", "Wojciech", "D(3)I(3)I(4)D(5)I(6)I(7)"),
    ("1234", "1234", ""),
    ("", "", "")
]

let extendedExpectations = [
    ("sitting", "kitten", "D(0)I(0)D(4)I(4)D(6)"),
    ("1234", "ABCD", "D(0)D(1)D(2)D(3)I(0)I(1)I(2)I(3)"),
    ("1234", "", "D(0)D(1)D(2)D(3)"),
    ("", "1234", "I(0)I(1)I(2)I(3)"),
    ("Hi", "Oh Hi", "I(0)I(1)I(2)"),
    ("Hi", "Hi O", "I(2)I(3)"),
    ("Oh Hi", "Hi", "D(0)D(1)D(2)"),
    ("Hi O", "Hi", "D(2)D(3)"),
    ("Wojtek", "Wojciech", "D(3)I(3)I(4)D(5)I(6)I(7)"),
    ("1234", "1234", ""),
    ("", "", ""),
    ("gitten", "sitting", "I(0)D(4)I(4)M(06)"),
    ("Oh Hi", "Hi Oh", "M(03)M(14)M(22)"),
    ("Hi Oh", "Oh Hi", "M(03)M(14)M(22)"),
    ("12345", "12435", "M(23)"),
    ("1362", "31526", "M(10)M(01)I(2)M(34)M(43")
]


class DiffTests: XCTestCase {
    
    func testDiffOutputs() {
        for expectation in expectations {
            XCTAssertEqual(
                _test(expectation.0, to: expectation.1),
                expectation.2)
        }
    }
    
    func testExtendedDiffOutputs() {
        for expectation in extendedExpectations {
            XCTAssertEqual(
                _testExtended(expectation.0, to: expectation.1),
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
    
    func _testExtended(
        from: String,
        to: String) -> String {
        return from
            .extendedDiff(to)
            .reduce("") { $0 + $1.debugDescription }
    }
}

extension ExtendedDiffElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let Delete(at):
            return "D(\(at))"
        case let Insert(at):
            return "I(\(at))"
        case let Move(from, to):
            return "M(\(from)\(to))"
        }
    }
}

extension DiffElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let Delete(at):
            return "D(\(at))"
        case let Insert(at):
            return "I(\(at))"
        }
    }
}
