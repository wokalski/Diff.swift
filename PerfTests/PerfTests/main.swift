//
//  main.swift
//  PerfTests
//
//  Created by Wojciech Czekalski on 27.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

/**
 This is a test file
 */

let resourcesPath = proccessPath().appending("/Resources/")
let from = resourcesPath.appending("Diff-old.swift")
let to = resourcesPath.appending("Diff-new.swift")
let diff = performDiff(fromFilePath: from, toFilePath: to, repeatCount: 5, diffFunc: diffSwift)

print("         | Diff.swift |")
print("-----------------------")
print(" same    |   \(diff.same)   |")
print(" created |   \(diff.created)   |")
print(" deleted |   \(diff.deleted)   |")
print(" diff    |   \(diff.changed)   |")
