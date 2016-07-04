//
//  DiffTests.swift
//  DiffTests
//
//  Created by Wojciech Czekalski on 03.07.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import XCTest
import Diff

class DiffTests: XCTestCase {
    
    func testDiffOutputs() {
        XCTAssertEqual(
            _test("kitten", to: "sitting"),
            "D(0)I(00)D(4)I(44)I(66)")
        XCTAssertEqual(
            _test("sitting", to: "kitten"),
            "D(0)I(00)D(4)I(44)D(6)")
        XCTAssertEqual(
            _test("1234", to: "ABCD"),
            "D(0)D(1)D(2)D(3)I(00)I(11)I(22)I(33)")
        XCTAssertEqual(
            _test("1234", to: ""),
            "D(0)D(1)D(2)D(3)")
        XCTAssertEqual(
            _test("", to: "1234"),
            "I(00)I(11)I(22)I(33)")
        XCTAssertEqual(
            _test("Hi", to: "Oh Hi"),
            "I(00)I(11)I(22)")
        XCTAssertEqual(
            _test("Hi", to: "Hi O"),
            "I(22)I(33)")
        XCTAssertEqual(
            _test("Oh Hi", to: "Hi"),
            "D(0)D(1)D(2)")
        XCTAssertEqual(
            _test("Hi O", to: "Hi"),
            "D(2)D(3)")
        XCTAssertEqual(
            _test("Wojtek", to: "Wojciech"),
            "D(3)I(33)I(44)D(5)I(66)I(77)")
        XCTAssertEqual(
            _test("", to: ""),
            "")
        XCTAssertEqual(
            _test("1234", to: "1234"),
            "")
    }
    
    func _test(
        from: String,
        to: String) -> String {
        return from
            .diff(to)
            .elements
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
