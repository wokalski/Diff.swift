
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
    public func patch<T: Collection>(
        _ a: T,
        b: T
        ) -> [ExtendedPatch<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        
        let linkedList = DoublyLinkedList(linkedList: LinkedList(array: generate(a, b: b)))
        if let secondElement = linkedList?.next {
            process(node: secondElement)
        }
        
        guard let result = linkedList?.array().sorted(by: { (fst, second) -> Bool in
            return fst.newIndex < second.newIndex
        }) else {
            return []
        }
        
        let resultWithoutMoves = result.map { $0.value }
        let sourceIndex = flip(array: reorderedIndex)
        return resultWithoutMoves.indices.flatMap { i -> ExtendedPatch<T.Iterator.Element>? in
            let patchElement = resultWithoutMoves[i]
            switch patchElement {
            case .deletion(let index):
                if moveIndices.contains(sourceIndex[i]) {
                    let to = resultWithoutMoves[i + 1]
                    if case let .insertion(toIndex, _) = to {
                        return .move(from: index, to: toIndex)
                    }
                }
                return .deletion(index: index)
            case let .insertion(index, element):
                if i > 0 && moveIndices.contains(sourceIndex[i-1]) {
                    return nil
                }
                return .insertion(index: index, element: element)
            }
        }
    }
    
    func generate<T: Collection>(_ a: T, b: T) -> [TemporaryReorderedElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        let patch = source.patch(a, b: b)
        return patch.indices.map {
            TemporaryReorderedElement(
                value: patch[$0],
                oldIndex: $0,
                newIndex: reorderedIndex[$0]
            )
        }
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
