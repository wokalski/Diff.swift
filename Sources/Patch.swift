public extension Diff {
    
    typealias OrderedBefore = (fst: DiffElement, snd: DiffElement) -> Bool
    
    public func patch<T: CollectionType where T.Generator.Element : Equatable>(
        a a: T,
          b: T
        ) -> [PatchElement<T.Generator.Element>] {
        
//        for element in elements {
//            switch element {
//            case let .Insert(at):
//                //insertions.append(PatchElement.Insertion(index: toIndexType(at), element: b[toIndexType(from)]))
//                retArray.append(PatchElement.Insertion(index: toIndexType(at),element: b[toIndexType(from)]))
//            case let .Delete(at):
//                //deletions.append(PatchElement.Deletion(index: toIndexType(at)))
//                retArray.append(PatchElement.Deletion(index: toIndexType(at)))
//            }
//        }
        return self.map { element in
            switch (element) {
            case let .Delete(at): return .Deletion(index: at)
            case let .Insert(at): return .Insertion(index: at, element: b.element(atIndex: at))
            }
        }
    }
}

public enum PatchElement<Element> {
    case Insertion(index: Int, element: Element)
    case Deletion(index: Int)
}

public enum ExtendedPatch<Element, Index> {
    case Insertion(index: Index, element: Element)
    case Deletion(index: Index)
    case Move(from: Index, to: Index)
}

extension PatchElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .Deletion(at):
            return "D(\(at))"
        case let .Insertion(at, element):
            return "I(\(at),\(element))"
        }
    }
}

