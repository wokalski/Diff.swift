struct SortedPatchElement<T> {
    var value: Patch<T>
    let sourceIndex: Int
    let sortedIndex: Int
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

func edgeType<T>(from: DoublyLinkedList<SortedPatchElement<T>>, to: DoublyLinkedList<SortedPatchElement<T>>) -> EdgeType {
    let fromIndex = from.value.sortedIndex
    let toIndex = to.value.sortedIndex

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

func shiftPatchElement<T>(node: DoublyLinkedList<SortedPatchElement<T>>) {
    var from = node.previous
    while let nextFrom = from, nextFrom.value.sourceIndex < node.value.sourceIndex {
        shiftPatchElement(from: nextFrom, to: node)
        from = nextFrom.previous
    }

    if let next = node.next {
        shiftPatchElement(node: next)
    }
}

func shiftPatchElement<T>(from: DoublyLinkedList<SortedPatchElement<T>>, to: DoublyLinkedList<SortedPatchElement<T>>) {
    let type = edgeType(from: from, to: to)
    switch type {
    case .cycle:
        fatalError()
    case let .neighbor(direction), let .jump(direction):
        if case .left = direction {
            switch (from.value.value, to.value.value) {
            case (.insertion, _):
                to.value = to.value.decremented()
            case (.deletion, _):
                to.value = to.value.incremented()
            }
        }
    }
}

extension SortedPatchElement {
    func incremented() -> SortedPatchElement {
        return SortedPatchElement(
            value: value.incremented(),
            sourceIndex: sourceIndex,
            sortedIndex: sortedIndex)
    }

    func decremented() -> SortedPatchElement {
        return SortedPatchElement(
            value: value.decremented(),
            sourceIndex: sourceIndex,
            sortedIndex: sortedIndex)
    }
}

extension Patch {

    func incremented() -> Patch {
        return shiftedIndex(by: 1)
    }

    func decremented() -> Patch {
        return shiftedIndex(by: -1)
    }

    func shiftedIndex(by n: Int) -> Patch {
        switch self {
        case let .insertion(index, element):
            return .insertion(index: index + n, element: element)
        case let .deletion(index):
            return .deletion(index: index + n)
        }
    }
}

func shiftedPatchElements<T>(from sortedPatchElements: [SortedPatchElement<T>]) -> [SortedPatchElement<T>] {
    let linkedList = DoublyLinkedList(linkedList: LinkedList(array: sortedPatchElements))
    if let secondElement = linkedList?.next {
        shiftPatchElement(node: secondElement)
    }

    guard let result = linkedList?.array().sorted(by: { (fst, second) -> Bool in
        fst.sortedIndex < second.sortedIndex
    }) else {
        return []
    }
    return result
}
