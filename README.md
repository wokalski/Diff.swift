# Diff.swift
Diff any CollectionType&lt;T> where T is equatable

## Which diff library should I choose

There are many implementations of diff algorithms around. You should consider the following before choosing the right one:
1. If your dataset is small and/or speed **and** memory usage is not a big concern, then use any of them.
2. If you need better performance, look for libraries which don't use the classic LCS algorithm. - The classic algorithm operates on a 2D array. It contains `original.count * changed.count)` elements. The array is allocated beforehands which wastes a lot of memory (it's 25 MB vs ~250 MB in the benchmark). They are also typically very slow because they iterate through the whole array.

## Performance comparison
Source code is available [here](https://github.com/wokalski/Diff.swift/blob/master/PerfTests/Utils/PerformanceTestUtils.swift). The result of a measurement is mean diff time in seconds over 10 runs.

         | Diff.swift | Dwifft 
-------------------------------
 same    |   0.0226   | 8.2496
 created |   0.0194   | 0.5835
 deleted |   0.0199   | 0.5769
 diff    |   0.1219   | 9.1734

