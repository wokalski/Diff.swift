public extension Diff {
    public func patch<T: CollectionType where T.Generator.Element : Equatable, T.Index : SignedIntegerType>(a a: T, b: T) -> [PatchElement<T.Generator.Element, T.Index>] {
        var retArray = [PatchElement<T.Generator.Element, T.Index>]()
        let toIndexType: Int -> T.Index = { x in
            return T.Index(x.toIntMax())
        }
        
        for element in elements {
            switch element {
            case let .Insert(from, at):
                //insertions.append(PatchElement.Insertion(index: toIndexType(at), element: b[toIndexType(from)]))
                retArray.append(PatchElement.Insertion(index: toIndexType(at),element: b[toIndexType(from)]))
            case let .Delete(at):
                //deletions.append(PatchElement.Deletion(index: toIndexType(at)))
                retArray.append(PatchElement.Deletion(index: toIndexType(at)))
            }
        }
        return retArray.reverse()
    }
}

public enum PatchElement<Element, Index> {
    case Insertion(index: Index, element: Element)
    case Deletion(index: Index)
}
