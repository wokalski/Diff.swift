
enum BoxedDiffAndPatchElement<T> {
    case move(
        diffElement: ExtendedDiffElement,
        deletion: SortedPatchElement<T>,
        insertion: SortedPatchElement<T>
    )
    case single(
        diffElement: ExtendedDiffElement,
        patchElement: SortedPatchElement<T>
    )
    
    var diffElement: ExtendedDiffElement {
        switch self {
        case .move(let de, _, _):
            return de
        case .single(let de, _):
            return de
        }
    }
}

public enum ExtendedPatch<Element> {
    case insertion(index: Int, element: Element)
    case deletion(index: Int)
    case move(from: Int, to: Int)
}


func flip(array: [Int]) -> [Int] {
    return zip(array, array.indices)
        .sorted { $0.0 < $1.0 }
        .map { $0.1 }
}

extension ExtendedDiff {
    public typealias OrderedBeforeExtended = (_ fst: ExtendedDiffElement, _ snd: ExtendedDiffElement) -> Bool
    
    public func patch<T: Collection>(
        _ a: T,
        b: T,
        sort: OrderedBeforeExtended? = nil
        ) -> [ExtendedPatch<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        
        let result: [SortedPatchElement<T.Iterator.Element>]
        if let sort = sort {
            result = shiftedPatchElements(from: generateSortedPatchElements(a, b: b, sort: sort))
        } else {
            result = shiftedPatchElements(from: generateSortedPatchElements(a, b: b))
        }
        
        return result.indices.flatMap { i -> ExtendedPatch<T.Iterator.Element>? in
            let patchElement = result[i]
            switch patchElement.value {
            case .deletion(let index):
                if moveIndices.contains(patchElement.sourceIndex) {
                    let to = result[i + 1].value
                    if case let .insertion(toIndex, _) = to {
                        return .move(from: index, to: toIndex)
                    }
                }
                return .deletion(index: index)
            case let .insertion(index, element):
                let isPreviousMove = i > 0 && moveIndices.contains(result[i-1].sourceIndex)
                if isPreviousMove {
                    return nil
                }
                return .insertion(index: index, element: element)
            }
        }
    }
    
    func generateSortedPatchElements<T: Collection>(
        _ a: T,
        b: T,
        sort: @escaping OrderedBeforeExtended
        ) -> [SortedPatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        let unboxed = boxDiffAndPatchElements(
            a,
            b: b
        ).sorted { a, b -> Bool in
            return sort(a.diffElement, b.diffElement)
        }.flatMap(unbox)
        
        return unboxed.indices.map { index -> SortedPatchElement<T.Iterator.Element> in
            let old = unboxed[index]
            return SortedPatchElement(
                value: old.value,
                sourceIndex: old.sourceIndex,
                sortedIndex: index)
            }.sorted { (fst, snd) -> Bool in
                return fst.sourceIndex < snd.sourceIndex
        }
    }
    
    func generateSortedPatchElements<T: Collection>(_ a: T, b: T) -> [SortedPatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        let patch = source.patch(a, b: b)
        
        return patch.indices.map {
            SortedPatchElement(
                value: patch[$0],
                sourceIndex: $0,
                sortedIndex: reorderedIndex[$0]
            )
        }
    }
    
    func boxDiffAndPatchElements<T: Collection>(
        _ a: T,
        b: T
        ) -> [BoxedDiffAndPatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        let sourcePatch = generateSortedPatchElements(a, b: b)
        let sourceIndex = flip(array: reorderedIndex)
        var indexDiff = 0
        return indices.map { i in
            let diffElement = self[i]
            switch diffElement {
            case .move:
                indexDiff += 1
                return .move(
                    diffElement: diffElement,
                    deletion: sourcePatch[sourceIndex[i+indexDiff-1]],
                    insertion: sourcePatch[sourceIndex[i+indexDiff]]
                )
            default:
                return .single(
                    diffElement: diffElement,
                    patchElement: sourcePatch[sourceIndex[i+indexDiff]]
                )
            }
        }
    }
}

func unbox<T>(_ element: BoxedDiffAndPatchElement<T>) -> [SortedPatchElement<T>] {
    switch element {
    case let .move(_, deletion, insertion):
        return [deletion, insertion]
    case let .single(_, singasd):
        return [singasd]
    }
}

extension ExtendedPatch: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .deletion(at):
            return "D(\(at))"
        case let .insertion(at, element):
            return "I(\(at),\(element))"
        case let .move(from, to):
            return "M(\(from),\(to))"
        }
    }
}
