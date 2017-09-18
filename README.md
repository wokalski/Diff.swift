# Differ

[![Build Status](https://travis-ci.org/tonyarnold/Differ.svg?branch=master)](https://travis-ci.org/tonyarnold/Differ) [![codecov](https://codecov.io/gh/tonyarnold/Differ/branch/master/graph/badge.svg)](https://codecov.io/gh/tonyarnold/Differ)

Differ generates the differences between `Collection` instances (this includes Strings!).

It uses a [fast algorithm](http://www.xmailserver.org/diff2.pdf) `(O((N+M)*D))` to do this.

## Features

- ⚡️ [It is fast](#performance-notes)
- Differ supports three types of operations:
    - Insertions
    - Deletions
    - Moves (when using `ExtendedDiff`)
- Arbitrary sorting of patches (`Patch`)
- Utilities for updating `UITableView` and `UICollectionView`
- Calculating differences between collections containing collections (use `NestedDiff`)

## Why do I need it?

There's a lot more to calculating diffs than performing `UITableView` animations easily!

Wherever you have code that propagates `added`/`removed`/`moved` callbacks from your model to your user interface, you should consider using a library that can calculate differences. Animating small batches of changes is usually going to be faster and provide a more responsive experience than reloading all of your data.

Calculating and acting on differences should also aid you in making a clear separation between data and user interface, and hopefully provide a more declarative approach: your model performs state transition, then your UI code performs appropriate actions based on the calculated differences to that state.

## Diffs, patches and sorting

Let's consider a simple example of using a patch to transform string `"a"` into `"b"`. The following steps describe the patches required to move between these states:

 Change                          | Result
:--------------------------------|:-------------
Delete the item at index 0       | `""`
Insert `b` at index 0            | `"b"`

If we want to perform these operations in different order, simple reordering of the existing patches won't work:

 Change                           | Result
:---------------------------------|:-------
Insert `b` at index 0             | `"ba"`
Delete the item at index 0        | `"a"`

...whoops!

To get to the correct outcome, we need to shift the order of insertions and deletions so that we get this:

 Change                           | Result
:---------------------------------|:------
Insert `b` at index 1             | `"ab"`
Delete the item at index 0        | `"b"`

### Solution

In order to mitigate this issue, there are two types of output:

- *Diff*
    - A sequence of deletions, insertions, and moves (if using `ExtendedDiff`) where deletions point to locations of an item to be deleted in the source and insertions point to the items in the output. Differ produces just one `Diff`.
- *Patch*
    - An _ordered sequence_ of steps to be applied to the source collection that will result in the second collection. This is based on a `Diff`, but it can be arbitrarily sorted.

### Practical sorting

In practice, this means that a diff to transform the string `1234` into `1` could be described as the following set of steps:

```
DELETE 1
DELETE 2
DELETE 3
```

The patch to describe the same change would be:

```
DELETE 1
DELETE 1
DELETE 1
```

However, if we decided to sort it so that deletions and higher indices are processed first, we get this patch:

```
DELETE 3
DELETE 2
DELETE 1
```

## How to use

### `UITableView`/`UICollectionView`

```swift
// The following will automatically animate deletions, insertions, and moves:

tableView.animateRowChanges(oldData: old, newData: new)

collectionView.animateItemChanges(oldData: old, newData: new)

// It can work with sections, too!

tableView.animateRowAndSectionChanges(oldData: old, newData: new)

collectionView.animateItemAndSectionChanges(oldData: old, newData: new)

```

Please see the [included examples](/Examples/) for a working sample.

### Using Patch and Diff

When you want to determine the steps to transform one collection into another (e.g. you want to animate your user interface according to changes in your model), you could do the following:

```swift
let from: T
let to: T

// patch() only includes insertions and deletions
let patch: [Patch<T.Iterator.Element>] = patch(from: from, to: to)

// extendedPatch() includes insertions, deletions and moves
let patch: [ExtendedPatch<T.Iterator.Element>] = extendedPatch(from: from, to: to)
```

When you need additional control over ordering, you could use the following:

```swift
let insertionsFirst = { element1, element2 -> Bool in
    switch (element1, element2) {
    case (.insert(let at1), .insert(let at2)):
        return at1 < at2
    case (.insert, .delete):
        return true
    case (.delete, .insert):
        return false
    case (.delete(let at1), .delete(let at2)):
        return at1 < at2
    default: fatalError() // Unreachable
    }
}

// Results in a list of patches with insertions preceding deletions
let patch = patch(from: from, to: to, sort: insertionsFirst)
```

An advanced example: you would like to calculate the difference first, and then generate a patch. In certain cases this can result in a performance improvement.

`D` is the length of a diff:

 - Generating a sorted patch takes `O(D^2)` time.
 - The default order takes `O(D)` to generate.

```swift
// Generate the difference first
let diff = from.diff(to)

// Now generate the list of patches utilising the diff we've just calculated
let patch = diff.patch(from: from, to: to)
```

If you'd like to learn more about how this library works, `Graph.playground` is a great place to start.

## Performance notes

Differ is **fast**. Many of the other Swift diff libraries use a simple `O(n*m)` algorithm, which allocates a 2 dimensional array and then walks through every element. This can use _a lot_ of memory.

In the bundled benchmarks, you should see an order of magnitude difference in calculation time between the two algorithms.

Each measurement is the mean time in seconds it takes to calculate a diff, over 10 runs on an iPhone 6.

|         |   Diff    | Dwifft  |
|---------|:----------|:--------|
| same    |  0.0213   | 52.3642 |
| created |  0.0188   | 0.0033  |
| deleted |  0.0184   | 0.0050  |
| diff    |  0.1320   | 63.4084 |

You can run these benchmarks yourself:

```sh
swift run -c release PerformanceTester Sources/PerformanceTester/Samples/Diff-old.swift Sources/PerformanceTester/Samples/Diff-new.swift
```

All of the above being said, the algorithm used by Diff works best for collections with _small_ differences between them. However, even for big differences this library is still likely to be faster than those that use the simple `O(n*m)` algorithm. If you need better performance with large differences between collections, please consider implementing a more suitable approach such as [Hunt & Szymanski's algorithm](http://par.cse.nsysu.edu.tw/~lcs/Hunt-Szymanski%20Algorithm.php) and/or [Hirschberg's algorithm](https://en.wikipedia.org/wiki/Hirschberg%27s_algorithm).

## Requirements

Differ requires Swift 4 / Xcode 9 or later to compile.

## Installation

You can add Differ to your project using Carthage, CocoaPods, Swift Package Manager, or as an Xcode subproject.

### Carthage

```ruby
github "tonyarnold/Differ"
```

### CocoaPods

```ruby
pod 'Differ'
```

## Acknowledgements

Differ is a modified fork of [Wojtek Czekalski's](https://github.com/wokalski) [Diff.swift](https://github.com/wokalski/Diff.swift) - Wojtek deserves all the credit for the original implementation, I am merely it's present custodian.

Please, [file issues with this fork here in this repository](/tonyarnold/Diff/issues/new), not in Wojtek's original repository.
