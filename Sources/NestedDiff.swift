
public struct NestedDiff: DiffProtocol {

    public enum Element {
        case delete(row: Int, section: Int)
        case insert(row: Int, section: Int)
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public let elements: [Element]
}

public extension Collection
    where Iterator.Element: Collection,
    Iterator.Element.Iterator.Element: Equatable {
    func nestedDiff(to: Self) -> NestedDiff {

        let selfFlatMapped = flatMap { $0 }
        let toFlatMapped = to.flatMap { $0 }
        let diff = selfFlatMapped.diff(toFlatMapped)
        let deletionSectionOffsets = self.sectionOffsets()
        let insertionSectionOffsets = to.sectionOffsets()

        var elements: [NestedDiff.Element] = []
        var deletionSection = 0
        var insertionSection = 0
        for element in diff {

            switch element {
            case let .delete(at):
                while deletionSection < deletionSectionOffsets.count - 1
                    && deletionSectionOffsets[deletionSection + 1] <= at {
                    deletionSection += 1
                }

                let offset = deletionSectionOffsets[deletionSection]
                elements.append(.delete(row: at - offset, section: deletionSection))
            case let .insert(at):
                while insertionSection < insertionSectionOffsets.count - 1
                    && insertionSectionOffsets[insertionSection + 1] <= at {
                    insertionSection += 1
                }

                let offset = insertionSectionOffsets[insertionSection]
                elements.append(.insert(row: at - offset, section: insertionSection))
            }
        }

        return NestedDiff(elements: elements)
    }

    func sectionOffsets() -> [Int] {
        return self
            .flatMap { $0.count }
            .dropLast()
            .reduce([0]) { prev, item in
                let prevCount = prev.last ?? 0
                return prev + [(prevCount + Int(item.toIntMax()))]
            }
    }
}

extension NestedDiff.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .delete(row, section):
            return "D(\(row), \(section))"
        case let .insert(row, section):
            return "I(\(row),\(section))"
        }
    }
}
