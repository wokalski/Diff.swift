//
//  PerformanceTest.swift
//  Benchmark
//
//  Created by Wojciech Czekalski on 27.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Foundation
import Diff

func performDiff(f: ([Character], [Character]) -> Void) -> (created: String, deleted: String, same: String, changed: String) {
    let old = file(name: "Diff-old")
    let new = file(name: "Diff")
    let compare: ([Character], [Character]) -> String = { a, b in
        let repeatCount: CFTimeInterval = 10
        var time: CFTimeInterval = 0
        for _ in 0..<Int(repeatCount) {
            time += measure({ f(a, b) })
        }
        time = time / repeatCount
        return (NSString(format: "%.4f", time) as String)
    }
    
    return (compare([], old),
            compare(old, []),
            compare(old, old),
            compare(old, new))
}

func measure(f: () -> Void) -> CFTimeInterval {
    let time = CFAbsoluteTimeGetCurrent()
    f()
    return CFAbsoluteTimeGetCurrent() - time
}

func file(name name: String) -> [Character] {
    let url = NSBundle.mainBundle().URLForResource(name, withExtension: "swift")!
    return try! Array(String(contentsOfURL: url).characters)
    
}

func diffSwift(a: [Character], b: [Character]) {
    _ = _diffSwift(a, b: b)
}

private func _diffSwift(a: [Character], b: [Character]) -> Diff {
    return a.diff(b)
}