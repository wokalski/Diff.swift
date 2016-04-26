//
//  DiffSwift.swift
//  Benchmark
//
//  Created by Wojciech Czekalski on 26.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Diff

func diffSwift(a: [Character], b: [Character]) {
    _ = _diffSwift(a, b: b)
}

private func _diffSwift(a: [Character], b: [Character]) -> Diff {
    return a.diff(b)
}