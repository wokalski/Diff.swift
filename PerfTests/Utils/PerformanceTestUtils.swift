//
//  PerformanceTest.swift
//  Benchmark
//
//  Created by Wojciech Czekalski on 27.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Foundation
import Diff

func performDiff(fromFilePath: String, toFilePath: String, repeatCount: Int = 10, diffFunc: ([Character], [Character]) -> Void) -> (created: String, deleted: String, same: String, changed: String) {
    let old = file(path: fromFilePath)
    let new = file(path: toFilePath)
    let compare: ([Character], [Character]) -> String = { a, b in
        var time: CFTimeInterval = 0
        for _ in 0..<repeatCount {
            time += measure({ diffFunc(a, b) })
        }
        time = time / CFTimeInterval(repeatCount)
        return (NSString(format: "%.4f", time) as String)
    }
    
    return (compare([], old),
            compare(old, []),
            compare(old, old),
            compare(old, new))
}

func currentDirectoryPath() -> String {
    let buffer: UnsafeMutablePointer<Int8> = UnsafeMutablePointer.alloc(Int(PATH_MAX))
    getcwd(buffer, Int(PATH_MAX))
    let string = String.fromCString(buffer)
    buffer.dealloc(Int(PATH_MAX))
    return string!
}

func measure(f: () -> Void) -> CFTimeInterval {
    let time = CFAbsoluteTimeGetCurrent()
    f()
    return CFAbsoluteTimeGetCurrent() - time
}

func file(path path: String) -> [Character] {
    return try! Array(String(contentsOfFile: path).characters)
    
}

func diffSwift(a: [Character], b: [Character]) {
    _ = _diffSwift(a, b: b)
}

private func _diffSwift(a: [Character], b: [Character]) -> Diff {
    return a.diff(b)
}

func launchPath() -> String {
    let path = Process.arguments.first!
    let dotIndex = path.startIndex.successor()
    var lastSlashIndex = path.endIndex.predecessor()
    let c: Character = "/"
    while path.characters[lastSlashIndex] != c {
        lastSlashIndex = lastSlashIndex.predecessor()
    }
    return path.substringToIndex(lastSlashIndex).substringFromIndex(dotIndex)
}

func proccessPath() -> String {
    return currentDirectoryPath().stringByAppendingString(launchPath())
}

