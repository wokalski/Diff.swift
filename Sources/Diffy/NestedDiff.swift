public struct NestedDiff: DiffProtocol {

    public typealias Index = Int

    public enum Element {
        case deleteSection(Int)
        case insertSection(Int)
        case deleteElement(Int, section: Int)
        case insertElement(Int, section: Int)
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection. `i` must be less than `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public let elements: [Element]
}

public extension Collection
    where Iterator.Element: Collection {

    /// Creates a diff between the callee and `other` collection. It diffs elements two levels deep (therefore "nested")
    ///
    /// - Parameters:
    ///   - other: a collection to compare the calee to
    /// - Returns: a `NestedDiff` between the calee and `other` collection
    public func nestedDiff(
        to: Self,
        isEqualSection: EqualityChecker<Self>,
        isEqualElement: NestedElementEqualityChecker<Self>
    ) -> NestedDiff {
        let diffTraces = outputDiffPathTraces(to: to, isEqual: isEqualSection)

        // Diff sections
        let sectionDiff = Diff(traces: diffTraces).map { element -> NestedDiff.Element in
            switch element {
            case let .delete(at):
                return .deleteSection(at)
            case let .insert(at):
                return .insertSection(at)
            }
        }

        // Diff matching sections (moves, deletions, insertions)
        let filterMatchPoints = { (trace: Trace) -> Bool in
            if case .matchPoint = trace.type() {
                return true
            }
            return false
        }

        // offset & section

        let matchingSectionTraces = diffTraces
            .filter(filterMatchPoints)

        let fromSections = matchingSectionTraces.map {
            itemOnStartIndex(advancedBy: $0.from.x)
        }

        let toSections = matchingSectionTraces.map {
            to.itemOnStartIndex(advancedBy: $0.from.y)
        }

        let elementDiff = zip(zip(fromSections, toSections), matchingSectionTraces)
            .flatMap { (args) -> [NestedDiff.Element] in
                let (sections, trace) = args
                return sections.0.diff(sections.1, isEqual: isEqualElement).map { diffElement -> NestedDiff.Element in
                    switch diffElement {
                    case let .delete(at):
                        return .deleteElement(at, section: trace.from.x)
                    case let .insert(at):
                        return .insertElement(at, section: trace.from.y)
                    }
                }
            }

        return NestedDiff(elements: sectionDiff + elementDiff)
    }
}

public extension Collection
    where Iterator.Element: Collection,
    Iterator.Element.Iterator.Element: Equatable {

    /// - SeeAlso: `nestedDiff(to:isEqualSection:isEqualElement:)`
    public func nestedDiff(
        to: Self,
        isEqualSection: EqualityChecker<Self>
    ) -> NestedDiff {
        return nestedDiff(
            to: to,
            isEqualSection: isEqualSection,
            isEqualElement: { $0 == $1 }
        )
    }
}

public extension Collection
    where Iterator.Element: Collection,
    Iterator.Element: Equatable {

    /// - SeeAlso: `nestedDiff(to:isEqualSection:isEqualElement:)`
    public func nestedDiff(
        to: Self,
        isEqualElement: NestedElementEqualityChecker<Self>
    ) -> NestedDiff {
        return nestedDiff(
            to: to,
            isEqualSection: { $0 == $1 },
            isEqualElement: isEqualElement
        )
    }
}

public extension Collection
    where Iterator.Element: Collection,
    Iterator.Element: Equatable,
    Iterator.Element.Iterator.Element: Equatable {

    /// - SeeAlso: `nestedDiff(to:isEqualSection:isEqualElement:)`
    public func nestedDiff(to: Self) -> NestedDiff {
        return nestedDiff(
            to: to,
            isEqualSection: { $0 == $1 },
            isEqualElement: { $0 == $1 }
        )
    }
}

extension NestedDiff.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .deleteElement(row, section):
            return "DE(\(row),\(section))"
        case let .deleteSection(section):
            return "DS(\(section))"
        case let .insertElement(row, section):
            return "IE(\(row),\(section))"
        case let .insertSection(section):
            return "IS(\(section))"
        }
    }
}
