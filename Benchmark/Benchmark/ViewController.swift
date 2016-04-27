//
//  ViewController.swift
//  Benchmark
//
//  Created by Wojciech Czekalski on 26.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
}

