//
//  Dwifft.swift
//  Benchmark
//
//  Created by Wojciech Czekalski on 26.04.2016.
//  Copyright © 2016 wczekalski. All rights reserved.
//

import Dwifft

func performDwifft(a: [Character], b: [Character]) {
    _ = dwifft(a, b: b)
}

private func dwifft(a: [Character], b: [Character]) -> Dwifft.Diff<Character> {
    return a.diff(b)
}