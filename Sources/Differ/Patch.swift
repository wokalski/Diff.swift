/// Single step in a patch sequence.
public enum Patch<Element> {
    /// A single patch step containing an insertion index and an element to be inserted
    case insertion(index: Int, element: Element)
    /// A single patch step containing a deletion index
    case deletion(index: Int)

    func index() -> Int {
        switch self {
        case let .insertion(index, _):
            return index
        case let .deletion(index):
            return index
        }
    }
}

public extension Diff {

    /// Generates a patch sequence based on a diff. It is a list of steps to be applied to obtain the `to` collection from the `from` one.
    ///
    /// - Complexity: O(N)
    ///
    /// - Parameters:
    ///   - from: The source collection (usually the source collecetion of the callee)
    ///   - to: The target collection (usually the target collecetion of the callee)
    /// - Returns: A sequence of steps to obtain `to` collection from the `from` one.
    public func patch<T: Collection>(
        from: T,
        to: T
    ) -> [Patch<T.Iterator.Element>] where T.Iterator.Element: Equatable {
        var shift = 0
        return map { element in
            switch element {
            case let .delete(at):
                shift -= 1
                return .deletion(index: at + shift + 1)
            case let .insert(at):
                shift += 1
                return .insertion(index: at, element: to.itemOnStartIndex(advancedBy: at))
            }
        }
    }
}

/// Generates a patch sequence. It is a list of steps to be applied to obtain the `to` collection from the `from` one.
///
/// - Complexity: O((N+M)*D)
///
/// - Parameters:
///   - from: The source collection
///   - to: The target collection
/// - Returns: A sequence of steps to obtain `to` collection from the `from` one.
public func patch<T: Collection>(
    from: T,
    to: T
) -> [Patch<T.Iterator.Element>] where T.Iterator.Element: Equatable {
    return from.diff(to).patch(from: from, to: to)
}

extension Patch: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .deletion(at):
            return "D(\(at))"
        case let .insertion(at, element):
            return "I(\(at),\(element))"
        }
    }
}
