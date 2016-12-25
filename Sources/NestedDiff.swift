
public struct NestedDiff: DiffProtocol {

    public enum Element {
        case deleteSection(Int)
        case insertSection(Int)
        case deleteRow(Int, section: Int)
        case insertRow(Int, section: Int)
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
    Iterator.Element: Equatable,
    Iterator.Element.Iterator.Element: Equatable {
    func nestedDiff(to: Self) -> NestedDiff {

        let diffTraces = outputDiffPathTraces(to: to)
        
        // Diff sections
        let sectionDiff = Diff(traces: diffTraces).map { element -> NestedDiff.Element in
            switch(element) {
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
            .flatMap { sections, trace -> [NestedDiff.Element] in
                return sections.0.diff(sections.1).map { diffElement -> NestedDiff.Element in
                    switch diffElement {
                    case let .delete(at):
                        return .deleteRow(at, section: trace.from.x)
                    case let .insert(at):
                        return .insertRow(at, section: trace.from.y)
                    }
                }
        }
        
        return NestedDiff(elements: sectionDiff + elementDiff)
    }
}

func sectionOffsets<T: Collection>(in array: Array<T>) -> [Int] {
    return array
        .flatMap { $0.count }
        .dropLast()
        .reduce([0]) { prev, item in
            let prevCount = prev.last ?? 0
            return prev + [(prevCount + Int(item.toIntMax()))]
    }
}

extension NestedDiff.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .deleteRow(row, section):
            return "DR(\(row),\(section))"
        case let .deleteSection(section):
            return "DS(\(section))"
        case let .insertRow(row, section):
            return "IR(\(row),\(section))"
        case let .insertSection(section):
            return "IS(\(section))"        }
    }
}
