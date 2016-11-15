
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
    
    typealias OrderedBefore = (_ fst: DiffElement, _ snd: DiffElement) -> Bool

    public func patch<T: Collection>(
        _ a: T,
        b: T,
        sort: OrderedBefore? = nil
        ) -> [PatchElement<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        
        typealias PE = PatchElement<T.Generator.Element>

        var shift = 0
        let shiftedDiff: [PE] = self.indices.map { i in
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
        
        guard let sort = sort else {
            return shiftedDiff
        }
        
        let sortedDiff = indices.map { index in
            return (self[index], index)
        }.sorted { (fst, snd) -> Bool in
            return sort(fst.0, snd.0)
        }.map { (shiftedDiff[$0.1], $0.1) }
        
        
        let sortedDiffToShiftedDiffIndex =
            zip(sortedDiff.map { $0.1 }, sortedDiff.indices)
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        
        let sortedPatchElements = shiftedDiff.indices.map {
            PatchReorderedElement(
                value: shiftedDiff[$0],
                oldIndex: $0,
                newIndex: sortedDiffToShiftedDiffIndex[$0]
            )
        }
        
        let linkedList = DoublyLinkedList(linkedList: LinkedList(array: sortedPatchElements))
        if let secondElement = linkedList?.next {
            process(node: secondElement)
        }
        
        guard let result = linkedList?.array().sorted(by: { (fst, second) -> Bool in
            return fst.newIndex < second.newIndex
        }) else {
            return shiftedDiff
        }
        return result.map { $0.value }
    }
}

// MARK: Patch reordering

enum Direction {
    case left
    case right
}

enum EdgeType {
    case cycle
    case neighbor(direction: Direction)
    case jump(direction: Direction)
}

func edgeDirection<T>(from: DoublyLinkedList<PatchReorderedElement<T>>, to: DoublyLinkedList<PatchReorderedElement<T>>) -> EdgeType {
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

func process<T>(node: DoublyLinkedList<PatchReorderedElement<T>>) {
    var from = node.previous
    while let nextFrom = from, nextFrom.value.oldIndex < node.value.oldIndex {
        process(from: nextFrom, to: node)
        from = nextFrom.previous
    }
    
    if let next = node.next {
        process(node: next)
    }
}

func process<T>(from: DoublyLinkedList<PatchReorderedElement<T>>, to: DoublyLinkedList<PatchReorderedElement<T>>) {
    switch edgeDirection(from: from, to: to) {
    case .cycle:
        fatalError()
    case .neighbor(let direction), .jump(let direction):
        if case .left = direction {
            switch (from.value.value, to.value.value) {
            case (.insertion, .insertion):
                break
            case (.deletion, .deletion):
                break
            case (.insertion, .deletion(let position)):
                to.value = PatchReorderedElement(value: .deletion(index: position - 1), oldIndex: to.value.oldIndex, newIndex: to.value.newIndex)
            case (.deletion(let dPosition), .insertion(let iPosition, let element)):
                if dPosition == iPosition {
                    from.value = PatchReorderedElement(value: .deletion(index: dPosition + 1), oldIndex: from.value.oldIndex, newIndex: from.value.newIndex)
                } else if dPosition < iPosition {
                    to.value = PatchReorderedElement(value: .insertion(index: iPosition + 1, element: element), oldIndex: to.value.oldIndex, newIndex: to.value.newIndex)
                }
            }
        }
    }
}

struct PatchReorderedElement<T> {
    var value: PatchElement<T>
    let oldIndex: Int
    let newIndex: Int

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
