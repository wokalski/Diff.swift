#if !os(macOS) && !os(watchOS)

import UIKit

struct BatchUpdate {
    let deletions: [IndexPath]
    let insertions: [IndexPath]
    let moves: [(from: IndexPath, to: IndexPath)]

    init(diff: ExtendedDiff) {
        deletions = diff.flatMap { element -> IndexPath? in
            switch element {
            case .delete(let at):
                return IndexPath(row: at, section: 0)
            default: return nil
            }
        }
        insertions = diff.flatMap { element -> IndexPath? in
            switch element {
            case .insert(let at):
                return IndexPath(row: at, section: 0)
            default: return nil
            }
        }
        moves = diff.flatMap { element -> (IndexPath, IndexPath)? in
            switch element {
            case let .move(from, to):
                return (IndexPath(row: from, section: 0), IndexPath(row: to, section: 0))
            default: return nil
            }
        }
    }
}

public extension UITableView {

    /// Animates rows which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of UITableView
    /// - parameter newData:            Data which reflects the current state of UITableView
    /// - parameter deletionAnimation:  Animation type for deletions
    /// - parameter insertionAnimation: Animation type for insertions
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: UITableViewRowAnimation = .automatic,
        insertionAnimation: UITableViewRowAnimation = .automatic
    ) where T.Iterator.Element: Equatable {
        let update = BatchUpdate(diff: oldData.extendedDiff(newData))
        beginUpdates()
        deleteRows(at: update.deletions, with: deletionAnimation)
        insertRows(at: update.insertions, with: insertionAnimation)
        update.moves.forEach { moveRow(at: $0.from, to: $0.to) }
        endUpdates()
    }
}

public extension UICollectionView {

    /// Animates items which changed between oldData and newData.
    ///
    /// - parameter oldData:            Data which reflects the previous state of UITableView
    /// - parameter newData:            Data which reflects the current state of UITableView
    public func animateItemChanges<T: Collection>(
        oldData: T,
        newData: T,
        completion: ((Bool) -> Void)? = nil
    ) where T.Iterator.Element: Equatable {
        performBatchUpdates({
            let update = BatchUpdate(diff: oldData.extendedDiff(newData))
            self.deleteItems(at: update.deletions)
            self.insertItems(at: update.insertions)
            update.moves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completion: completion)
    }
}

#endif
