/// A sequence of deletions, insertions, and moves where deletions point to locations in the source and insertions point to locations in the output.
/// Examples:
/// ```
/// "12" -> "": D(0)D(1)
/// "" -> "12": I(0)I(1)
/// ```
/// - SeeAlso: Diff
public struct ExtendedDiff: DiffProtocol {

    public typealias Index = Int

    public enum Element {
        case insert(at: Int)
        case delete(at: Int)
        case move(from: Int, to: Int)
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameters:
    ///   - i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    /// Diff used to compute an instance
    public let source: Diff
    /// An array which holds indices of diff elements in the source diff (i.e. diff without moves).
    let sourceIndex: [Int]
    /// An array which holds indices of diff elements in a diff where move's subelements (deletion and insertion) are ordered accordingly
    let reorderedIndex: [Int]

    /// An array of particular diff operations
    public let elements: [ExtendedDiff.Element]
    let moveIndices: Set<Int>
}

extension ExtendedDiff.Element {
    init(_ diffElement: Diff.Element) {
        switch diffElement {
        case let .delete(at):
            self = .delete(at: at)
        case let .insert(at):
            self = .insert(at: at)
        }
    }
}

public extension Collection {

    /// Creates an extended diff between the calee and `other` collection
    ///
    /// - Complexity: O((N+M)*D). There's additional cost of O(D^2) to compute the moves.
    ///
    /// - Parameters:
    ///   - other: a collection to compare the calee to
    ///   - isEqual: instance comparator closure
    /// - Returns: ExtendedDiff between the calee and `other` collection
    public func extendedDiff(_ other: Self, isEqual: EqualityChecker<Self>) -> ExtendedDiff {
        return extendedDiff(from: diff(other, isEqual: isEqual), other: other, isEqual: isEqual)
    }

    /// Creates an extended diff between the calee and `other` collection
    ///
    /// - Complexity: O(D^2). where D is number of elements in diff.
    ///
    /// - Parameters:
    ///   - diff: source diff
    ///   - other: a collection to compare the calee to
    ///   - isEqual: instance comparator closure
    /// - Returns: ExtendedDiff between the calee and `other` collection
    public func extendedDiff(from diff: Diff, other: Self, isEqual: EqualityChecker<Self>) -> ExtendedDiff {

        var elements: [ExtendedDiff.Element] = []
        var moveOriginIndices = Set<Int>()
        var moveTargetIndices = Set<Int>()
        // It maps indices after reordering (e.g. bringing move origin and target next to each other in the output) to their positions in the source Diff
        var sourceIndex = [Int]()

        // Complexity O(d^2) where d is the length of the diff

        /*
         * 1. Iterate all objects
         * 2. For every iteration find the next matching element
         a) if it's not found insert the element as is to the output array
         b) if it's found calculate move as in 3
         * 3. Calculating the move.
         We call the first element a *candidate* and the second element a *match*
         1. The position of the candidate never changes
         2. The position of the match is equal to its initial position + m where m is equal to -d + i where d = deletions between candidate and match and i = insertions between candidate and match
         * 4. Remove the candidate and match and insert the move in the place of the candidate
         *
         */

        for candidateIndex in diff.indices {
            if !moveTargetIndices.contains(candidateIndex) && !moveOriginIndices.contains(candidateIndex) {
                let candidate = diff[candidateIndex]
                let match = firstMatch(diff, dirtyIndices: moveTargetIndices.union(moveOriginIndices), candidate: candidate, candidateIndex: candidateIndex, other: other, isEqual: isEqual)
                if let match = match {
                    switch match.0 {
                    case let .move(from, _):
                        if from == candidate.at() {
                            sourceIndex.append(candidateIndex)
                            sourceIndex.append(match.1)
                            moveOriginIndices.insert(candidateIndex)
                            moveTargetIndices.insert(match.1)
                        } else {
                            sourceIndex.append(match.1)
                            sourceIndex.append(candidateIndex)
                            moveOriginIndices.insert(match.1)
                            moveTargetIndices.insert(candidateIndex)
                        }
                    default: fatalError()
                    }
                    elements.append(match.0)
                } else {
                    sourceIndex.append(candidateIndex)
                    elements.append(ExtendedDiff.Element(candidate))
                }
            }
        }

        let reorderedIndices = flip(array: sourceIndex)

        return ExtendedDiff(
            source: diff,
            sourceIndex: sourceIndex,
            reorderedIndex: reorderedIndices,
            elements: elements,
            moveIndices: moveOriginIndices
        )
    }

    func firstMatch(
        _ diff: Diff,
        dirtyIndices: Set<Diff.Index>,
        candidate: Diff.Element,
        candidateIndex: Diff.Index,
        other: Self,
        isEqual: EqualityChecker<Self>
    ) -> (ExtendedDiff.Element, Diff.Index)? {
        for matchIndex in (candidateIndex + 1) ..< diff.endIndex {
            if !dirtyIndices.contains(matchIndex) {
                let match = diff[matchIndex]
                if let move = createMatch(candidate, match: match, other: other, isEqual: isEqual) {
                    return (move, matchIndex)
                }
            }
        }
        return nil
    }

    func createMatch(_ candidate: Diff.Element, match: Diff.Element, other: Self, isEqual: EqualityChecker<Self>) -> ExtendedDiff.Element? {
        switch (candidate, match) {
        case (.delete, .insert):
            if isEqual(itemOnStartIndex(advancedBy: candidate.at()), other.itemOnStartIndex(advancedBy: match.at())) {
                return .move(from: candidate.at(), to: match.at())
            }
        case (.insert, .delete):
            if isEqual(itemOnStartIndex(advancedBy: match.at()), other.itemOnStartIndex(advancedBy: candidate.at())) {
                return .move(from: match.at(), to: candidate.at())
            }
        default: return nil
        }
        return nil
    }
}

public extension Collection where Iterator.Element: Equatable {

    /// - SeeAlso: `extendedDiff(_:isEqual:)`
    public func extendedDiff(_ other: Self) -> ExtendedDiff {
        return extendedDiff(other, isEqual: { $0 == $1 })
    }
}

extension Collection {
    func itemOnStartIndex(advancedBy n: Int) -> Iterator.Element {
        return self[self.index(startIndex, offsetBy: n)]
    }
}

func flip(array: [Int]) -> [Int] {
    return zip(array, array.indices)
        .sorted { $0.0 < $1.0 }
        .map { $0.1 }
}

extension ExtendedDiff.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .delete(at):
            return "D(\(at))"
        case let .insert(at):
            return "I(\(at))"
        case let .move(from, to):
            return "M(\(from),\(to))"
        }
    }
}
