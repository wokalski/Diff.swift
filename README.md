[![Build Status](https://travis-ci.org/wokalski/Diff.swift.svg?branch=master)](https://travis-ci.org/wokalski/Diff.swift)
[![codecov](https://codecov.io/gh/wokalski/Diff.swift/branch/master/graph/badge.svg)](https://codecov.io/gh/wokalski/Diff.swift)


# Diff.swift

This library generates differences between any two `Collection`s (and Strings). It uses a [fast algorithm](http://www.xmailserver.org/diff2.pdf) `(O((N+M)*D))`.

## Documentation

Documentation is available [here](http://wokalski.com/docs/Diff/)

## Features

- `Diff.swift` supports three types of operations:
    - Insertions
    - Deletions
    - Moves (use `ExtendedDiff`)
- Arbitrary sorting of the `Patch`
- Utilities for `UITableView` and `UICollectionView` (if that's just what you want, [skip to examples](#how-to-use))
- ⚡️ [fast](#performance-notes)
- Diffing collections containing collections (use `NestedDiff`)

## Why would I need it?

There's more to diffs than performing `UITableView` animations easily.

Wherever you have code which propagates `added`/`removed`/`moved` callbacks from your model to the UI it's good to consider using a diffing library instead. What you get is clear separation and more declarative approach. The model just performs state transition and the UI code performs appropriate UI actions based on the diff output.

## Diff vs Patch (Sorting)

Let's consider a simple example of a patch to transform string `"a"` into `"b"`.

1. Delete item at index 0 (we get `""`)
2. Insert `b` at index 0 (we get `"b"`)

If we want to perform these operations in different order, simple reordering of the steps doesn't work.

1. Insert `b` at index 0 (we get `"ba"`)
2. Delete item at index 0 (we get `"a"`)

... ooooops

We need to shift insertions and deletions so that we get this:

1. Insert `b` at index 1 (we get `"ab"`
2. Delete item at index 0 (we get `"b"`)

### Solution

In order to mitigate this issue there are two types of output:

- *Diff*
    - A sequence of deletions, insertions, and moves (if using `ExtendedDiff`) where deletions point to locations of an item to be deleted in the source and insertions point to the items in the output. `Diff.swift` produces just one `Diff`.
- *Patch*
    - An _ordered sequence_ of steps to be applied to obtain the second sequence from the first one. It is based on a `Diff` but can be arbitrarly sorted.

### Sorting in practice

In practice it means that a diff to transform string `"1234"` to `"1"` is `"D(1)D(2)D(3)"` the default patch is `"D(1)D(1)D(1)"`. However, if we decide to sort it so that deletions and bigger indices happen first we get this patch: `"D(3)D(2)D(1)"`.

## How to use

### `UITableView`/`UICollectionView`
    
```swift
    
// It will automatically animate deletions, insertions, and moves
tableView.animateRowChanges(
            oldData: old,
            newData: new)

collectionView.animateItemChanges(
    oldData: old,
    newData: new,
    completion: {_ in}) 

// Works with sections, too

tableView.animateRowAndSectionChanges(
    oldData: old,
    newData: new
)

collectionView.animateItemAndSectionChanges(
    oldData: old,
    newData: new
)

```

See [examples](/Examples/) for a working example.

### Using Patch and Diff

When you want to get steps to transform one sequence into another (e.g. you want to animate UI according to the changes in the model)

```swift

let from: T
let to: T

// only insertions and deletions
// Returns [Patch<T.Iterator.Element>]
let patch = patch(
                from: from,
                to: to
            )

// Patch + moves
// Returns [ExtendedPatch<T.Iterator.Element>]
let patch = extendedPatch(
                from: from,
                to: to
            )
```

When you need additional control over ordering

```swift

let insertionsFirst = { fst, snd -> Bool in 
    switch (element1, element2) {
    case (.insert(let at1), .insert(let at2)):
        return at1 < at2
    case (.insert, .delete):
        return true
    case (.delete, .insert):
        return false
    case (.delete(let at1), .delete(let at2)):
        return at1 < at2
    default: fatalError() // unreachable
    }    
}

// Results in a [Patch] with insertions preceeding deletions
let patch = patch(
                from: from,
                to: to,
                sort: insertionsFirst
            )
```

More advanced - you want to calculate diff first and generate patch. In certain cases it's a good performance improvement. Generating a sorted patch takes O(D^2) time. The default order takes `O(D)` to generate. `D` is the length of a diff.

```swift

// Generate diff first
let diff = from.diff(to)
let patch = diff.patch(from: from, to: to)
```

## Performance notes

This library is fast. Most other libraries use a simple `O(n*m)` algorithm which allocates a 2 dimensional array and goes through all elements. It takes _a lot_ of memory. In the benchmark it is an order of magnitude difference. 

Source code is available [here](https://github.com/wokalski/Diff.swift/blob/master/PerfTests/Utils/PerformanceTestUtils.swift). The result of a measurement is mean diff time in seconds over 10 runs on an iPhone 6.

             | Diff.swift | Dwifft 
    ---------|------------|--------
     same    |   0.0555   | 19.8632
     created |   0.0511   | 2.4461
     deleted |   0.0502   | 2.4260
     diff    |   0.2807   | 21.9684

This algorithm works great for collections with _small_ diffs. I mean, even for big diffs, it's still better than the simple algorithm. 
However, if you need good performance and you have big differences between the inputs consider another diffing algorithm. Look at Hunt & Szymanski's and/or Hirschberg's work.

## Installation

Carthage (preferred)

```
// Cartfile
github "wokalski/Diff.swift"
```

Cocoapods

```
// podfile
pod 'Diff'
```

## Get in touch

If you have any questions, you can find me on [Twitter](https://twitter.com/wokalski).

## Misc

If you want to learn how it works `Graph.playground` is a good place to start.
