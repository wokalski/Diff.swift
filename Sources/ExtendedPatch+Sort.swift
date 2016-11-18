
enum ReorderingElement<T> {
    case move(
        deletion: TemporaryReorderedElement<T>,
        insertion: TemporaryReorderedElement<T>
    )
    case single(element: TemporaryReorderedElement<T>)
}

extension ExtendedDiff {
    
    public typealias OrderedBeforeExtended = (_ fst: ExtendedDiffElement, _ snd: ExtendedDiffElement) -> Bool
    public typealias UnprocessedPatchElement<T> = (element: PatchElement<T>, index: Diff.Index)
    /*
     1. Box unsorted with indices in the source (move has an index of deletion)
     1. Sort elements
     3. Unwrap indices (move produces deletion and insertion)
     3. Perform normal sorting
     4. Check if reorderedIndex[oldIndex] is move (or reorderedIndex[oldIndex]-1 is move if it's an insertion) and if yes, map it to a move.
     */
    
    public func patch<T: Collection>(
        _ a: T,
        b: T,
        sort: @escaping OrderedBeforeExtended
        ) -> [ExtendedPatch<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        
        let p = generate(a, b: b)
        let sourceIndex = flip(array: reorderedIndex)

        var dupa = 0
        let toBeSORTED = indices.map { i -> (ExtendedDiffElement, ReorderingElement<T.Iterator.Element>) in
            let de = self[i]
            switch de {
            case .move:
                dupa += 1
                return (de, .move(deletion: p[sourceIndex[i+dupa-1]], insertion: p[sourceIndex[i+dupa]]))
            default:
                return (de, .single(element: p[sourceIndex[i+dupa]]))
            }
        }
        
        let sorted = toBeSORTED.sorted { a, b -> Bool in
            return sort(a.0, b.0)
        }
        
        let unwrapped = sorted.flatMap { element -> [TemporaryReorderedElement<T.Iterator.Element>] in
            switch element.1 {
            case let .move(deletion, insertion):
                return [deletion, insertion]
            case let .single(singasd):
                return [singasd]
            }
        }
        
        
        let resorted = unwrapped.indices.map { index -> TemporaryReorderedElement<T.Iterator.Element> in
            let old = unwrapped[index]
            return TemporaryReorderedElement(
                value: old.value,
                oldIndex: old.oldIndex,
                newIndex: index
            )
        }
        
        let masdfpadsofkpasf = zip(resorted, unwrapped).sorted { (fst, snd) -> Bool in
            return fst.0.newIndex < snd.0.newIndex
        }.map { $0.1.newIndex }
        
        let linkedList = DoublyLinkedList(linkedList: LinkedList(array: resorted.sorted { (fst, snd) -> Bool in
            return fst.oldIndex < snd.oldIndex
        }))
        if let secondElement = linkedList?.next {
            process(node: secondElement)
        }
        
        guard let result = linkedList?.array().sorted(by: { (fst, second) -> Bool in
            return fst.newIndex < second.newIndex
        }) else {
            return []
        }
        
        let resultWithoutMoves = result.map { $0.value }
        return resultWithoutMoves.indices.flatMap { i -> ExtendedPatch<T.Iterator.Element>? in
            let virginIndex = sourceIndex[masdfpadsofkpasf[i]]
            let patchElement = resultWithoutMoves[i]
            switch patchElement {
            case .deletion(let index):
                
                if moveIndices.contains(virginIndex) {
                    let to = resultWithoutMoves[i + 1]
                    if case let .insertion(toIndex, _) = to {
                        return .move(from: index, to: toIndex)
                    }
                }
                return .deletion(index: index)
            case let .insertion(index, element):
                if i > 0 && moveIndices.contains(sourceIndex[masdfpadsofkpasf[i-1]]) {
                    return nil
                }
                return .insertion(index: index, element: element)
            }
        }
    }
}
