
class LinkedList<T> {
    let next: LinkedList?
    let value: T

    init(next: LinkedList?, value: T) {
        self.next = next
        self.value = value
    }

    init?(array: [T]) {
        guard let first = array.first else {
            return nil
        }
        self.next = LinkedList(array: Array(array.dropFirst()))
        self.value = first
    }
}

class DoublyLinkedList<T> {
    let next: DoublyLinkedList?
    private(set) var previous: DoublyLinkedList? = nil
    var head: DoublyLinkedList {
        guard let previous = previous else {
            return self
        }
        return previous.head
    }

    var value: T

    init?(linkedList: LinkedList<T>?) {
        guard let element = linkedList else {
            return nil
        }

        self.value = element.value
        self.next = DoublyLinkedList(linkedList: element.next)
        self.next?.previous = self
    }

    func array() -> Array<T> {
        if let next = next {
            return [value] + next.array()
        }
        return [value]
    }
}
