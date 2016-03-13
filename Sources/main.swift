#! /usr/bin/swift

let a = Array("KITTEN".characters)
let b = Array("dUPCIA".characters)
let patch = a.diff(b).patch(a: a, b: b)
print(patch)
print(a.apply(patch))
