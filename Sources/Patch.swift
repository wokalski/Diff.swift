public extension Diff {
    public func patch<T: Collection>(_ a: T, b: T) -> [PatchElement<T.Iterator.Element, T.Index>] where T.Iterator.Element : Equatable, T.Index : SignedInteger {
        var retArray = [PatchElement<T.Iterator.Element, T.Index>]()
        let toIndexType: (Int) -> T.Index = { x in
            return T.Index(x.toIntMax())
        }
        
        for element in elements {
            switch element {
            case let .insert(from, at):
                //insertions.append(PatchElement.Insertion(index: toIndexType(at), element: b[toIndexType(from)]))
                retArray.append(PatchElement.insertion(index: toIndexType(at),element: b[toIndexType(from)]))
            case let .delete(at):
                //deletions.append(PatchElement.Deletion(index: toIndexType(at)))
                retArray.append(PatchElement.deletion(index: toIndexType(at)))
            }
        }
        return retArray.reversed()
    }
}

public enum PatchElement<Element, Index> {
    case insertion(index: Index, element: Element)
    case deletion(index: Index)
}
