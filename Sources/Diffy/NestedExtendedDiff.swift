public struct NestedExtendedDiff: DiffProtocol {

    public typealias Index = Int

    public enum Element {
        case deleteSection(Int)
        case insertSection(Int)
        case moveSection(from: Int, to: Int)
        case deleteElement(Int, section: Int)
        case insertElement(Int, section: Int)
        case moveElement(from: (item: Int, section: Int), to: (item: Int, section: Int))
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

public typealias NestedElementEqualityChecker<T: Collection> = (T.Iterator.Element.Iterator.Element, T.Iterator.Element.Iterator.Element) -> Bool where T.Iterator.Element: Collection

public extension Collection
    where Iterator.Element: Collection {

    /// Creates a diff between the callee and `other` collection. It diffs elements two levels deep (therefore "nested")
    ///
    /// - Parameters:
    ///   - other: a collection to compare the calee to
    /// - Returns: a `NestedDiff` between the calee and `other` collection
    public func nestedExtendedDiff(
        to: Self,
        isEqualSection: EqualityChecker<Self>,
        isEqualElement: NestedElementEqualityChecker<Self>
    ) -> NestedExtendedDiff {

        // FIXME: This implementation is a copy paste of NestedDiff with some adjustments.

        let diffTraces = outputDiffPathTraces(to: to, isEqual: isEqualSection)

        let sectionDiff =
            extendedDiff(
                from: Diff(traces: diffTraces),
                other: to,
                isEqual: isEqualSection
            ).map { element -> NestedExtendedDiff.Element in
                switch element {
                case let .delete(at):
                    return .deleteSection(at)
                case let .insert(at):
                    return .insertSection(at)
                case let .move(from, to):
                    return .moveSection(from: from, to: to)
                }
            }

        // Diff matching sections (moves, deletions, insertions)
        let filterMatchPoints = { (trace: Trace) -> Bool in
            if case .matchPoint = trace.type() {
                return true
            }
            return false
        }

        let sectionMoves =
            sectionDiff.flatMap { diffElement -> (Int, Int)? in
                if case let .moveSection(from, to) = diffElement {
                    return (from, to)
                }
                return nil
            }.flatMap { move -> [NestedExtendedDiff.Element] in
                return itemOnStartIndex(advancedBy: move.0).extendedDiff(to.itemOnStartIndex(advancedBy: move.1), isEqual: isEqualElement)
                    .map { diffElement -> NestedExtendedDiff.Element in
                        switch diffElement {
                        case let .insert(at):
                            return .insertElement(at, section: move.1)
                        case let .delete(at):
                            return .deleteElement(at, section: move.0)
                        case let .move(from, to):
                            return .moveElement(from: (from, move.0), to: (to, move.1))
                        }
                    }
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
            .flatMap { (args) -> [NestedExtendedDiff.Element] in
                let (sections, trace) = args
                return sections.0.extendedDiff(sections.1, isEqual: isEqualElement).map { diffElement -> NestedExtendedDiff.Element in
                    switch diffElement {
                    case let .delete(at):
                        return .deleteElement(at, section: trace.from.x)
                    case let .insert(at):
                        return .insertElement(at, section: trace.from.y)
                    case let .move(from, to):
                        return .moveElement(from: (from, trace.from.x), to: (to, trace.from.y))
                    }
                }
            }

        return NestedExtendedDiff(elements: sectionDiff + sectionMoves + elementDiff)
    }
}

public extension Collection
    where Iterator.Element: Collection,
    Iterator.Element.Iterator.Element: Equatable {

    /// - SeeAlso: `nestedDiff(to:isEqualSection:isEqualElement:)`
    public func nestedExtendedDiff(
        to: Self,
        isEqualSection: EqualityChecker<Self>
    ) -> NestedExtendedDiff {
        return nestedExtendedDiff(
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
    public func nestedExtendedDiff(
        to: Self,
        isEqualElement: NestedElementEqualityChecker<Self>
    ) -> NestedExtendedDiff {
        return nestedExtendedDiff(
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
    public func nestedExtendedDiff(to: Self) -> NestedExtendedDiff {
        return nestedExtendedDiff(
            to: to,
            isEqualSection: { $0 == $1 },
            isEqualElement: { $0 == $1 }
        )
    }
}

extension NestedExtendedDiff.Element: CustomDebugStringConvertible {
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
        case let .moveElement(from, to):
            return "ME((\(from.item),\(from.section)),(\(to.item),\(to.section)))"
        case let .moveSection(from, to):
            return "MS(\(from),\(to))"
        }
    }
}
