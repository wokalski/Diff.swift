# Diff.swift
Diff any CollectionType&lt;T> where T is equatable

## Performance comparison
Source code is available [here](https://github.com/wokalski/Diff.swift/blob/master/PerfTests/Utils/PerformanceTestUtils.swift). The result of a measurement is mean diff time in seconds over 10 runs.

         | Diff.swift | Dwifft 
---------|------------|--------
 same    |   0.0022   | 8.1218 
 created |   1.2114   | 0.6060
 deleted |   1.2135   | 0.5859
 diff    |   0.0785   | 9.2118
