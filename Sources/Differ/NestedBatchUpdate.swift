//
//  Copyright © 2018 wczekalski. All rights reserved.

#if !os(watchOS)
import Foundation

struct NestedBatchUpdate {
    let itemDeletions: [IndexPath]
    let itemInsertions: [IndexPath]
    let itemMoves: [(from: IndexPath, to: IndexPath)]
    let sectionDeletions: IndexSet
    let sectionInsertions: IndexSet
    let sectionMoves: [(from: Int, to: Int)]

    init(
        diff: NestedExtendedDiff,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        ) {
        var itemDeletions: [IndexPath] = []
        var itemInsertions: [IndexPath] = []
        var itemMoves: [(IndexPath, IndexPath)] = []
        var sectionDeletions: IndexSet = []
        var sectionInsertions: IndexSet = []
        var sectionMoves: [(from: Int, to: Int)] = []

        diff.forEach { element in
            switch element {
            case let .deleteElement(at, section):
                itemDeletions.append(indexPathTransform(IndexPath(item: at, section: section)))
            case let .insertElement(at, section):
                itemInsertions.append(indexPathTransform(IndexPath(item: at, section: section)))
            case let .moveElement(from, to):
                itemMoves.append((indexPathTransform(IndexPath(item: from.item, section: from.section)), indexPathTransform(IndexPath(item: to.item, section: to.section))))
            case let .deleteSection(at):
                sectionDeletions.insert(sectionTransform(at))
            case let .insertSection(at):
                sectionInsertions.insert(sectionTransform(at))
            case let .moveSection(move):
                sectionMoves.append((sectionTransform(move.from), sectionTransform(move.to)))
            }
        }

        self.itemInsertions = itemInsertions
        self.itemDeletions = itemDeletions
        self.itemMoves = itemMoves
        self.sectionMoves = sectionMoves
        self.sectionInsertions = sectionInsertions
        self.sectionDeletions = sectionDeletions
    }
}

#endif

