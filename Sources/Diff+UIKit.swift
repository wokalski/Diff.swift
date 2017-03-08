#if !os(macOS) && !os(watchOS)

import UIKit

struct BatchUpdate {
    let deletions: [IndexPath]
    let insertions: [IndexPath]
    let moves: [(from: IndexPath, to: IndexPath)]

    init(
        diff: ExtendedDiff,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
        ) {
        deletions = diff.flatMap { element -> IndexPath? in
            switch element {
            case .delete(let at):
                return indexPathTransform(IndexPath(row: at, section: 0))
            default: return nil
            }
        }
        insertions = diff.flatMap { element -> IndexPath? in
            switch element {
            case .insert(let at):
                return indexPathTransform(IndexPath(row: at, section: 0))
            default: return nil
            }
        }
        moves = diff.flatMap { element -> (IndexPath, IndexPath)? in
            switch element {
            case let .move(from, to):
                return (indexPathTransform(IndexPath(row: from, section: 0)), indexPathTransform(IndexPath(row: to, section: 0)))
            default: return nil
            }
        }
    }
}
    
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

public extension UITableView {

    /// Animates rows which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UITableView`
    /// - parameter newData:            Data which reflects the current state of `UITableView`
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
    ) where T.Iterator.Element: Equatable {
        apply(
            oldData.extendedDiff(newData),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            indexPathTransform: indexPathTransform
        )
    }
    
    /// Animates rows which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UITableView`
    /// - parameter newData:            Data which reflects the current state of `UITableView`
    /// - parameter isEqual:            A function comparing two elements of `T`
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        // https://twitter.com/dgregor79/status/570068545561735169
        isEqual: (EqualityChecker<T>),
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
        ) {
        apply(
            oldData.extendedDiff(newData, isEqual: isEqual),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            indexPathTransform: indexPathTransform
        )
    }
    
    public func apply(
        _ diff: ExtendedDiff,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
        ) {
        let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)

        beginUpdates()
        deleteRows(at: update.deletions, with: deletionAnimation)
        insertRows(at: update.insertions, with: insertionAnimation)
        update.moves.forEach { moveRow(at: $0.from, to: $0.to) }
        endUpdates()
    }
    
    /// Animates rows and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UITableView`
    /// - parameter newData:            Data which reflects the current state of `UITableView`
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateRowAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element: Equatable,
        T.Iterator.Element.Iterator.Element: Equatable {
            apply(
                oldData.nestedExtendedDiff(to: newData),
                rowDeletionAnimation: rowDeletionAnimation,
                rowInsertionAnimation: rowInsertionAnimation,
                sectionDeletionAnimation: sectionDeletionAnimation,
                sectionInsertionAnimation: sectionInsertionAnimation,
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform
            )
    }
    
    
    /// Animates rows and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UITableView`
    /// - parameter newData:            Data which reflects the current state of `UITableView`
    /// - parameter isEqualElement:     A function comparing two items (elements of `T.Iterator.Element`)    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateRowAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        // https://twitter.com/dgregor79/status/570068545561735169
        isEqualElement: (NestedElementEqualityChecker<T>),
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element: Equatable {
            apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualElement: isEqualElement
                ),
                rowDeletionAnimation: rowDeletionAnimation,
                rowInsertionAnimation: rowInsertionAnimation,
                sectionDeletionAnimation: sectionDeletionAnimation,
                sectionInsertionAnimation: sectionInsertionAnimation,
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform
            )
    }
    
    /// Animates rows and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UITableView`
    /// - parameter newData:            Data which reflects the current state of `UITableView`
    /// - parameter isEqualSection:     A function comparing two sections (elements of `T`)
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateRowAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        // https://twitter.com/dgregor79/status/570068545561735169
        isEqualSection: (EqualityChecker<T>),
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element.Iterator.Element: Equatable {
            apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualSection: isEqualSection
                ),
                rowDeletionAnimation: rowDeletionAnimation,
                rowInsertionAnimation: rowInsertionAnimation,
                sectionDeletionAnimation: sectionDeletionAnimation,
                sectionInsertionAnimation: sectionInsertionAnimation,
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform
            )
    }
    
    /// Animates rows and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UITableView`
    /// - parameter newData:            Data which reflects the current state of `UITableView`
    /// - parameter isEqualSection:     A function comparing two sections (elements of `T`)
    /// - parameter isEqualElement:     A function comparing two items (elements of `T.Iterator.Element`)
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateRowAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualSection: EqualityChecker<T>,
        // https://twitter.com/dgregor79/status/570068545561735169
        isEqualElement: (NestedElementEqualityChecker<T>),
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        )
        where T.Iterator.Element: Collection {
            apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualSection: isEqualSection,
                    isEqualElement: isEqualElement
                ),
                rowDeletionAnimation: rowDeletionAnimation,
                rowInsertionAnimation: rowInsertionAnimation,
                sectionDeletionAnimation: sectionDeletionAnimation,
                sectionInsertionAnimation: sectionInsertionAnimation,
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform
            )
    }
    
    public func apply(
        _ diff: NestedExtendedDiff,
        rowDeletionAnimation: UITableViewRowAnimation = .automatic,
        rowInsertionAnimation: UITableViewRowAnimation = .automatic,
        sectionDeletionAnimation: UITableViewRowAnimation = .automatic,
        sectionInsertionAnimation: UITableViewRowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath,
        sectionTransform: (Int) -> Int
        ) {
        
        let update = NestedBatchUpdate(diff: diff, indexPathTransform: indexPathTransform, sectionTransform: sectionTransform)
        beginUpdates()
        deleteRows(at: update.itemDeletions, with: rowDeletionAnimation)
        insertRows(at: update.itemInsertions, with: rowInsertionAnimation)
        update.itemMoves.forEach { moveRow(at: $0.from, to: $0.to) }
        deleteSections(update.sectionDeletions, with: sectionDeletionAnimation)
        insertSections(update.sectionInsertions, with: sectionInsertionAnimation)
        update.sectionMoves.forEach { moveSection($0.from, toSection: $0.to) }
        endUpdates()
    }
}

public extension UICollectionView {

    /// Animates items which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UICollectionView`
    /// - parameter newData:            Data which reflects the current state of `UICollectionView`
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    public func animateItemChanges<T: Collection>(
        oldData: T,
        newData: T,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        completion: ((Bool) -> Void)? = nil
    ) where T.Iterator.Element: Equatable {
        let diff = oldData.extendedDiff(newData)
        apply(diff, completion: completion, indexPathTransform: indexPathTransform)
    }
    
    /// Animates items which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UICollectionView`
    /// - parameter newData:            Data which reflects the current state of `UICollectionView`
    /// - parameter isEqual:            A function comparing two elements of `T`
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    public func animateItemChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqual: EqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        ) {
        let diff = oldData.extendedDiff(newData, isEqual: isEqual)
        apply(diff, completion: completion, indexPathTransform: indexPathTransform)
    }
    
    public func apply(
        _ diff: ExtendedDiff,
        completion: ((Bool) -> Swift.Void)? = nil,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 }
        ) {
        performBatchUpdates({
            let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)
            self.deleteItems(at: update.deletions)
            self.insertItems(at: update.insertions)
            update.moves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completion: completion)
    }
    
    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UICollectionView`
    /// - parameter newData:            Data which reflects the current state of `UICollectionView`
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element: Equatable,
        T.Iterator.Element.Iterator.Element: Equatable {
            apply(
                oldData.nestedExtendedDiff(to: newData),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }
    
    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UICollectionView`
    /// - parameter newData:            Data which reflects the current state of `UICollectionView`
    /// - parameter isEqualElement:     A function comparing two items (elements of `T.Iterator.Element`)
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualElement: NestedElementEqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element: Equatable {
            apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualElement: isEqualElement
                ),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }
    
    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UICollectionView`
    /// - parameter newData:            Data which reflects the current state of `UICollectionView`
    /// - parameter isEqualSection:     A function comparing two sections (elements of `T`)
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualSection: EqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Iterator.Element: Collection,
        T.Iterator.Element.Iterator.Element: Equatable {
            apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualSection: isEqualSection
                ),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
        )
    }
    
    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of `UICollectionView`
    /// - parameter newData:            Data which reflects the current state of `UICollectionView`
    /// - parameter isEqualSection:     A function comparing two sections (elements of `T`)
    /// - parameter isEqualElement:     A function comparing two items (elements of `T.Iterator.Element`)
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    /// - parameter indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    /// - parameter sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    public func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualSection: EqualityChecker<T>,
        isEqualElement: NestedElementEqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Iterator.Element: Collection {
            apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualSection: isEqualSection,
                    isEqualElement: isEqualElement
                ),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
        )
    }
    
    public func apply(
        _ diff: NestedExtendedDiff,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Void)? = nil
        ) {
        performBatchUpdates({ 
            let update = NestedBatchUpdate(diff: diff, indexPathTransform: indexPathTransform, sectionTransform: sectionTransform)
            self.insertSections(update.sectionInsertions)
            self.deleteSections(update.sectionDeletions)
            update.sectionMoves.forEach { self.moveSection($0.from, toSection: $0.to) }
            self.deleteItems(at: update.itemDeletions)
            self.insertItems(at: update.itemInsertions)
            update.itemMoves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completion: completion)
    }
}

#endif
