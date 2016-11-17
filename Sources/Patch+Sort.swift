
public extension Diff {
    
    typealias UnprocessedPatchElement<T> = (element: PatchElement<T>, index: Diff.Index)
    typealias OrderedBefore = (_ fst: DiffElement, _ snd: DiffElement) -> Bool

    private func sortedUnprocessedPatch<T>(from source: [PatchElement<T>], sortBy areInIncreasingOrder: OrderedBefore) -> [UnprocessedPatchElement<T>] {
        return indices.map { (self[$0], $0) }
            .sorted { areInIncreasingOrder($0.0, $1.0) }
            .map { (source[$0.1], $0.1) }
    }
    
    private func mapSortedToShiftedIndices<T>(sorted patch: [UnprocessedPatchElement<T>]) -> [Array<Any>.Index] {
        return zip(patch.map { $0.1 }, patch.indices)
            .sorted { $0.0 < $1.0 }
            .map { $0.1 }
    }
    
    private func generateTemporarySortedPatch<T>(
        from shiftedPatch: [PatchElement<T>],
        sortBy areInIncreasingOrder: OrderedBefore
        ) -> [TemporaryReorderedElement<T>] {
        let sortedToShiftedIndex = mapSortedToShiftedIndices(sorted: sortedUnprocessedPatch(from: shiftedPatch, sortBy: areInIncreasingOrder))
        return shiftedPatch.indices.map {
            TemporaryReorderedElement(
                value: shiftedPatch[$0],
                oldIndex: $0,
                newIndex: sortedToShiftedIndex[$0]
            )
        }
    }
    
    public func patch<T: Collection>(
        _ a: T,
        b: T,
        sort: OrderedBefore
        ) -> [PatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        
        let shiftedPatch = patch(a, b: b)
        let sortedPatchElements = generateTemporarySortedPatch(
            from: shiftedPatch,
            sortBy: sort
        )
        
        let linkedList = DoublyLinkedList(linkedList: LinkedList(array: sortedPatchElements))
        if let secondElement = linkedList?.next {
            process(node: secondElement)
        }
        
        guard let result = linkedList?.array().sorted(by: { (fst, second) -> Bool in
            return fst.newIndex < second.newIndex
        }) else {
            return shiftedPatch
        }
        
        return result.map { $0.value }
    }
}

enum Direction {
    case left
    case right
}

enum EdgeType {
    case cycle
    case neighbor(direction: Direction)
    case jump(direction: Direction)
}

func edgeType<T>(from: DoublyLinkedList<TemporaryReorderedElement<T>>, to: DoublyLinkedList<TemporaryReorderedElement<T>>) -> EdgeType {
    let fromIndex = from.value.newIndex
    let toIndex = to.value.newIndex
    
    if fromIndex == toIndex {
        return .cycle
    } else if abs(fromIndex - toIndex) == 1 {
        if fromIndex > toIndex {
            return .neighbor(direction: .left)
        } else {
            return .neighbor(direction: .right)
        }
    } else if fromIndex > toIndex {
        return .jump(direction: .left)
    } else {
        return .jump(direction: .right)
    }
}

func process<T>(node: DoublyLinkedList<TemporaryReorderedElement<T>>) {
    var from = node.previous
    while let nextFrom = from, nextFrom.value.oldIndex < node.value.oldIndex {
        process(from: nextFrom, to: node)
        from = nextFrom.previous
    }
    
    if let next = node.next {
        process(node: next)
    }
}

func process<T>(from: DoublyLinkedList<TemporaryReorderedElement<T>>, to: DoublyLinkedList<TemporaryReorderedElement<T>>) {
    let type = edgeType(from: from, to: to)
    switch type {
    case .cycle:
        fatalError()
    case .neighbor(let direction), .jump(let direction):
        if case .left = direction {
            switch (from.value.value, to.value.value) {
            case (.insertion, .insertion(let position, let element)):
                to.value = TemporaryReorderedElement(
                    value: .insertion(index: position - 1, element: element),
                    oldIndex: to.value.oldIndex,
                    newIndex: to.value.newIndex)
            case (.deletion, .deletion(let toPosition)):
                to.value = TemporaryReorderedElement(
                    value: .deletion(index: toPosition + 1),
                    oldIndex: to.value.oldIndex,
                    newIndex: to.value.newIndex
                    )
            case (.insertion, .deletion(let position)):
                to.value = TemporaryReorderedElement(
                    value: .deletion(index: position - 1),
                    oldIndex: to.value.oldIndex,
                    newIndex: to.value.newIndex)
            case (.deletion(_), .insertion(let iPosition, let element)):
                    to.value = TemporaryReorderedElement(
                        value: .insertion(index: iPosition + 1, element: element),
                        oldIndex: to.value.oldIndex,
                        newIndex: to.value.newIndex)
            }
        }
    }
}

struct TemporaryReorderedElement<T> {
    var value: PatchElement<T>
    let oldIndex: Int
    let newIndex: Int
}
