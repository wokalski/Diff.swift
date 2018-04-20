#if canImport(AppKit)
import AppKit

extension BatchUpdate {
    public init(
        diff: ExtendedDiff,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
    ) {
        deletions = diff.compactMap { element -> IndexPath? in
            switch element {
            case let .delete(at):
                return indexPathTransform([0, at])
            default: return nil
            }
        }
        insertions = diff.compactMap { element -> IndexPath? in
            switch element {
            case let .insert(at):
                return indexPathTransform([0, at])
            default: return nil
            }
        }
        moves = diff.compactMap { element -> MoveStep? in
            switch element {
            case let .move(from, to):
                return MoveStep(from: indexPathTransform([0, from]), to: indexPathTransform([0, to]))
            default: return nil
            }
        }
    }
}

extension NSTableView {

    /// Animates rows which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `NSTableView`
    ///   - newData:            Data which reflects the current state of `NSTableView`
    ///   - deletionAnimation:  Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired `IndexPath`
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
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
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `NSTableView`
    ///   - newData:            Data which reflects the current state of `NSTableView`
    ///   - isEqual:            A function comparing two elements of `T`
    ///   - deletionAnimation:  Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired `IndexPath`
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqual: EqualityChecker<T>,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
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
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
    ) {
        let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)

        beginUpdates()
        removeRows(at: IndexSet(update.deletions.map { $0.item }), withAnimation: deletionAnimation)
        insertRows(at: IndexSet(update.insertions.map { $0.item }), withAnimation: insertionAnimation)
        update.moves.forEach { moveRow(at: $0.from.item, to: $0.to.item) }
        endUpdates()
    }
}

@available(macOS 10.11, *)
public extension NSCollectionView {
    /// Animates items which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - completion:         Closure to be executed when the animation completes
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
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqual:            A function comparing two elements of `T`
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - completion:         Closure to be executed when the animation completes
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
        self.animator()
        .performBatchUpdates({
            let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)
            self.deleteItems(at: Set(update.deletions))
            self.insertItems(at: Set(update.insertions))
            update.moves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completionHandler: completion)
    }

    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
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
            self.apply(
                oldData.nestedExtendedDiff(to: newData),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }

    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqualElement:     A function comparing two items (elements of `T.Iterator.Element`)
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
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
            self.apply(
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
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqualSection:     A function comparing two sections (elements of `T`)
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
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
            self.apply(
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
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqualSection:     A function comparing two sections (elements of `T`)
    ///   - isEqualElement:     A function comparing two items (elements of `T.Iterator.Element`)
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
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
            self.apply(
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
        self.animator()
        .performBatchUpdates({
            let update = NestedBatchUpdate(diff: diff, indexPathTransform: indexPathTransform, sectionTransform: sectionTransform)
            self.insertSections(update.sectionInsertions)
            self.deleteSections(update.sectionDeletions)
            update.sectionMoves.forEach { self.moveSection($0.from, toSection: $0.to) }
            self.deleteItems(at: Set(update.itemDeletions))
            self.insertItems(at: Set(update.itemInsertions))
            update.itemMoves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completionHandler: completion)
    }
}

#endif
