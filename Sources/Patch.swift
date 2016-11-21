
public enum Patch<Element> {
    case insertion(index: Int, element: Element)
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
    
    public func patch<T: Collection>(
        from: T,
        to: T
        ) -> [Patch<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        var shift = 0
        return map { element in
            switch element {
            case let .delete(at):
                shift -= 1
                return .deletion(index: at+shift+1)
            case let .insert(at):
                shift += 1
                return .insertion(index: at, element: to.itemOnStartIndex(advancedBy: at))
            }
        }
    }
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
