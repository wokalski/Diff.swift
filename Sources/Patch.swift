
public enum PatchElement<Element> {
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

public enum ExtendedPatch<Element, Index> {
    case insertion(index: Index, element: Element)
    case deletion(index: Index)
    case move(from: Index, to: Index)
}

public extension Diff {
    
    public func patch<T: Collection>(
        _ a: T,
        b: T
        ) -> [PatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        var shift = 0
        return self.indices.map { i in
            let element = self[i]
            switch element {
            case let .delete(at):
                shift -= 1
                return .deletion(index: at+shift+1)
            case let .insert(at):
                shift += 1
                return .insertion(index: at, element: b.itemOnStartIndex(advancedBy: at))
            }
        }
    }
}

extension PatchElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .deletion(at):
            return "D(\(at))"
        case let .insertion(at, element):
            return "I(\(at),\(element))"
        }
    }
}
