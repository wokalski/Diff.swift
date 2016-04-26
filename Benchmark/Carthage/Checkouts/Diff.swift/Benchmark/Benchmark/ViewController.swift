//
//  ViewController.swift
//  Benchmark
//
//  Created by Wojciech Czekalski on 26.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dwifft = performDiff(performDwifft)
        let diff = performDiff(diffSwift)
        
        print("Both libraries are compiled with -O -whole-module-optimization\n")
        print("         | Diff.swift | Dwifft ")
        print("-------------------------------")
        print(" same    |   \(diff.same)   | \(dwifft.same)")
        print(" created |   \(diff.created)   | \(dwifft.created)")
        print(" deleted |   \(diff.deleted)   | \(dwifft.deleted)")
        print(" diff    |   \(diff.changed)   | \(dwifft.changed)")
    }
    
    func performDiff(f: ([Character], [Character]) -> Void) -> (created: String, deleted: String, same: String, changed: String) {
        let old = file(name: "Diff-old")
        let new = file(name: "Diff")
        let compare: ([Character], [Character]) -> String = { a, b in
            let repeatCount: CFTimeInterval = 50
            var time: CFTimeInterval = 0
            for _ in 0..<Int(repeatCount) {
                time += self.measure({ f(a, b) })
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
}

