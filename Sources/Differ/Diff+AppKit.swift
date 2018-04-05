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
                return indexPathTransform(IndexPath(item: at, section: 0))
            default: return nil
            }
        }
        insertions = diff.compactMap { element -> IndexPath? in
            switch element {
            case let .insert(at):
                return indexPathTransform(IndexPath(item: at, section: 0))
            default: return nil
            }
        }
        moves = diff.compactMap { element -> MoveStep? in
            switch element {
            case let .move(from, to):
                return MoveStep(from: indexPathTransform(IndexPath(item: from, section: 0)), to: indexPathTransform(IndexPath(item: to, section: 0)))
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

#endif
