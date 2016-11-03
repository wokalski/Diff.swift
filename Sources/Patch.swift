func valuesSortedByKey<T>(_ dict: [Int:[T]]) -> [T] {
    let keys = dict.keys.sorted()
    return keys.flatMap { (key: Int) -> [T] in return dict[key]! }
}

public extension Diff {
    
    typealias OrderedBefore = (_ fst: DiffElement, _ snd: DiffElement) -> Bool
    
    public func patch<T: Collection>(
        _ a: T,
        b: T
        ) -> [PatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        
        typealias PE = PatchElement<T.Generator.Element>
        
        let patchElements: [(PE, Int)] = self.indices.map { i in
            let element = self[i]
            switch element {
            case let .delete(at): return (.deletion(index: at), i)
            case let .insert(at): return (.insertion(index: at, element: b.itemOnStartIndex(advancedBy: at)), i)
            }
        }
        
        var dict: [Int:[(PE, Int)]] = [:]
        
        patchElements.forEach { (element) in
            let key = element.0.index()
            if var bucket = dict[key] {
                bucket.append(element)
                dict[key] = bucket
            } else {
                dict[key] = [element]
            }
        }
        
        let allValues = valuesSortedByKey(dict)
        print(allValues)
        var shift = 0
        let update: [(Int, Int)] = allValues.map { patchElement,index in
            switch patchElement {
            case .deletion:
                let result = (index, shift)
                shift -= 1
                return result
            case .insertion:
                let result = (index, shift)
                shift += 1
                return result
            }
        }
        
        var shiftedPatch = patchElements.map { element,_ in return element }
            
        update.forEach { i,shiftValue in
            let element = shiftedPatch[i]
            switch element {
            case let .deletion(index):
                shiftedPatch[i] = .deletion(index: (index+shiftValue) >= 0 ? (index+shiftValue) : 0)
            case let .insertion(index, value):
                shiftedPatch[i] = .insertion(index: (index+shiftValue) >= 0 ? (index+shiftValue) : 0, element: value)
            }
        }
//            print(update)
        
        return shiftedPatch
    }
}

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

//public extension RangeReplaceableCollectionType where Self.Generator.Element : Equatable, Self.Index : SignedIntegerType {
//    
//    public func apply(patch: [PatchElement<Generator.Element>]) -> Self {
//        var mutableSelf = self
//        
//        for change in patch {
//            switch change {
//            case let .insertion(index, element):
//                mutableSelf.insert(element, atIndex: index)
//            case let .deletion(index):
//                mutableSelf.removeAtIndex(index)
//            }
//        }
//        
//        return mutableSelf
//    }
//}
