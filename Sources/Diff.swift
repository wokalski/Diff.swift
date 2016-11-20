
public protocol DiffProtocol: Collection, Sequence {
    
    associatedtype DiffElementType
    associatedtype Index = Array<DiffElementType>.Index
    
    var elements: [DiffElementType] { get }
}

public struct Diff: DiffProtocol {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    public let elements: [DiffElement]
}

public enum DiffElement {
    case insert(at: Int)
    case delete(at: Int)
}

public struct ExtendedDiff: DiffProtocol {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public let source: Diff
    /// An array which holds indices of diff elements in the source diff (i.e. diff without moves).
    public let reorderedIndex: [Int]
    public let elements: [ExtendedDiffElement]
    public let moveIndices: Set<Int>
}


public enum ExtendedDiffElement {
    case insert(at: Int)
    case delete(at: Int)
    case move(from: Int, to: Int)
}


extension DiffElement {
    public init?(trace: Trace) {
        switch trace.type() {
        case .insertion:
            self = .insert(at: trace.from.y)
        case .deletion:
            self = .delete(at: trace.from.x)
        case .matchPoint:
            return nil
        }
    }
    
    func at() -> Int {
        switch self {
        case let .delete(at):
            return at
        case let .insert(at):
            return at
        }
    }
}

extension ExtendedDiffElement {
    init(_ diffElement: DiffElement) {
        switch diffElement {
        case let .delete(at):
            self = .delete(at: at)
        case let .insert(at):
            self = .insert(at: at)
        }
    }
}

public struct Point {
    public let x: Int
    public let y: Int
}

extension Point: Equatable {}

public func ==(l: Point, r: Point) -> Bool {
    return (l.x == r.x) && (l.y == r.y)
}

public struct Trace {
    public let from: Point
    public let to: Point
    public let D: Int
}

extension Trace: Equatable {}

public func ==(l: Trace, r: Trace) -> Bool {
    return (l.from == r.from) && (l.to == r.to)
}

enum TraceType {
    case insertion
    case deletion
    case matchPoint
}

extension Trace {
    func type() -> TraceType {
        if from.x+1 == to.x && from.y+1 == to.y {
            return .matchPoint
        } else if from.y < to.y {
            return .insertion
        } else {
            return .deletion
        }
    }
    
    func k() -> Int {
        return from.x - from.y
    }
}

public extension String {
    public func diff(_ b: String) -> Diff {
        if self == b {
            return Diff(elements: [])
        }
        return characters.diff(b.characters)
    }
    
    public func extendedDiff(_ other: String) -> ExtendedDiff {
        if self == other {
            return ExtendedDiff(
                source: Diff(elements: []),
                reorderedIndex: [],
                elements: [],
                moveIndices: Set()
            )
        }
        return characters.extendedDiff(other.characters)
    }
}

extension Array {
    func value(at index: Index) -> Iterator.Element? {
        if (index < 0 || index >= self.count) {
            return nil
        }
        return self[index]
    }
}

struct TraceStep {
    let D: Int
    let k: Int
    let previousX: Int?
    let nextX: Int?
}

public extension Collection where Iterator.Element : Equatable {
    
    public func diff(_ other: Self) -> Diff {
        return findPath(diffTraces(other), n: Int(self.count.toIntMax()), m: Int(other.count.toIntMax()))
    }
    
    public func extendedDiff(_ other: Self) -> ExtendedDiff {
        return extendedDiffFrom(diff(other), other: other)
    }
    
    fileprivate func extendedDiffFrom(_ diff: Diff, other: Self) -> ExtendedDiff {
        
        
        var elements = [ExtendedDiffElement]()
        var dirtyDiffElements: Set<Diff.Index> = []
        var sourceIndex = [Int]()
        var moveIndices = Set<Int>()
        

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
            if !dirtyDiffElements.contains(candidateIndex) {
                let candidate = diff[candidateIndex]
                let match = firstMatch(diff, dirtyIndices: dirtyDiffElements, candidate: candidate, candidateIndex: candidateIndex, other: other)
                if let match = match {
                    sourceIndex.append(candidateIndex) // Index of the deletion
                    sourceIndex.append(match.1) // Index of the insertion
                    moveIndices.insert(candidateIndex)
                    dirtyDiffElements.insert(match.1)
                    elements.append(match.0)
                } else {
                    sourceIndex.append(candidateIndex)
                    elements.append(ExtendedDiffElement(candidate))
                }
            }
        }
        
        let reorderedIndices = zip(sourceIndex, sourceIndex.indices)
            .sorted { $0.0 < $1.0 }
            .map { $0.1 }
        
        return ExtendedDiff(
            source: diff,
            reorderedIndex: reorderedIndices,
            elements: elements,
            moveIndices: moveIndices
        )
    }
    
    func firstMatch(
        _ diff: Diff,
        dirtyIndices: Set<Diff.Index>,
        candidate: DiffElement,
        candidateIndex: Diff.Index,
        other: Self) -> (ExtendedDiffElement, Diff.Index)? {
        for matchIndex in (candidateIndex + 1)..<diff.endIndex {
            
            if !dirtyIndices.contains(matchIndex) {
                let match = diff[matchIndex]
                if let move = createMatCH(candidate, match: match, other: other) {
                    return (move, matchIndex)
                }
            }
        }
        return nil
    }
    
    func createMatCH(_ candidate: DiffElement, match: DiffElement, other: Self) -> ExtendedDiffElement? {
        switch (candidate, match) {
        case (.delete, .insert):
            if itemOnStartIndex(advancedBy: candidate.at()) == other.itemOnStartIndex(advancedBy: match.at()) {
                return .move(from: candidate.at(), to: match.at())
            }
        case (.insert, .delete):
            if itemOnStartIndex(advancedBy: match.at()) == other.itemOnStartIndex(advancedBy: candidate.at()) {
                return .move(from: match.at(), to: candidate.at())
            }
        default: return nil
        }
        return nil
    }
    
    func itemOnStartIndex(advancedBy n: Int) -> Iterator.Element {
        return self[self.index(startIndex, offsetBy: IndexDistance(n.toIntMax()))]
    }
    
    public func diffTraces(_ b: Self) -> [Trace] {
        if (self.count == 0 && b.count == 0) {
            return []
        } else if (self.count == 0) {
            return tracesForInsertions(b)
        } else if (b.count == 0) {
            return tracesForDeletions()
        } else {
            return myersDiffTraces(b)
        }
    }
    
    fileprivate func tracesForDeletions() -> [Trace] {
        var traces = [Trace]()
        for index in 0..<self.count.toIntMax() {
            let intIndex = index.toIntMax()
            traces.append(Trace(from: Point(x: Int(intIndex), y: 0), to: Point(x: Int(intIndex)+1, y: 0), D: 0))
        }
        return traces
    }
    
    fileprivate func tracesForInsertions(_ b: Self) -> [Trace] {
        var traces = [Trace]()
        for index in 0..<b.count.toIntMax() {
            let intIndex = index.toIntMax()
            traces.append(Trace(from: Point(x: 0, y: Int(intIndex)), to: Point(x: 0, y: Int(intIndex)+1), D: 0))
        }
        return traces
    }
    
    fileprivate func myersDiffTraces(_ b: Self) -> [Trace] {
        
        let fromCount = Int(self.count.toIntMax())
        let toCount = Int(b.count.toIntMax())
        var traces = Array<Trace>()
        
        let max = fromCount+toCount // this is arbitrary, maximum difference between a and b. N+M assures that this algorithm always finds a diff
        
        var vertices = Array(repeating: -1, count: 2 * Int(max) + 1) // from [0...2*max], it is -max...max in the whitepaper
        
        vertices[max+1] = 0
        
        for numberOfDifferences in 0...max {
            for k in stride(from: (-numberOfDifferences), through: numberOfDifferences, by: 2) {
                
                let index = k+max
                let traceStep = TraceStep(D: numberOfDifferences, k: k, previousX: vertices.value(at: index-1), nextX: vertices.value(at: index+1))
                if let trace = bound(trace: nextTrace(traceStep), maxX: fromCount, maxY: toCount) {
                    var x = trace.to.x
                    var y = trace.to.y
                    
                    traces.append(trace)
                    
                    // keep going as long as they match on diagonal k
                    while x >= 0 && y >= 0 && x < fromCount && y < toCount {
                        let targetItem = b.itemOnStartIndex(advancedBy: y)
                        let baseItem = itemOnStartIndex(advancedBy: x)
                        if baseItem == targetItem {
                            x += 1
                            y += 1
                            traces.append(Trace(from: Point(x: x-1, y: y-1), to: Point(x: x, y: y), D: numberOfDifferences))
                        } else {
                            break
                        }
                    }
                    
                    vertices[index] = x
                    
                    if x >= fromCount && y >= toCount {
                        return traces
                    }
                }
            }
        }
        return []
    }
    
    fileprivate func bound(trace: Trace, maxX: Int, maxY: Int) -> Trace? {
        guard trace.to.x <= maxX && trace.to.y <= maxY else {
            return nil
        }
        return trace
    }
    
    fileprivate func nextTrace(_ traceStep: TraceStep) -> Trace {
        let traceType = nextTraceType(traceStep)
        let k = traceStep.k
        let D = traceStep.D
        
        if  traceType == .insertion {
            let x = traceStep.nextX!
            return Trace(from: Point(x: x, y: x-k-1), to: Point(x: x, y: x-k), D: D)
        } else {
            let x = traceStep.previousX! + 1
            return Trace(from: Point(x: x-1, y: x-k), to: Point(x: x, y: x-k), D: D)
        }
    }
    
    fileprivate func nextTraceType(_ traceStep: TraceStep) -> TraceType {
        let D = traceStep.D
        let k = traceStep.k
        let previousX = traceStep.previousX
        let nextX = traceStep.nextX
        
        if k == -D {
            return .insertion
        } else if k != D {
            if let previousX = previousX, let nextX = nextX , previousX < nextX {
                return .insertion
            }
            return .deletion
        } else {
            return .deletion
        }
    }
    
    fileprivate func findPath(_ traces: [Trace], n: Int, m: Int) -> Diff {
        
        guard traces.count > 0 else {
            return Diff(elements: [])
        }
        
        var array = [Trace]()
        var item = traces.last!
        array.append(item)
        
        for trace in traces.reversed() {
            if trace.to.x == item.from.x && trace.to.y == item.from.y {
                array.insert(trace, at: 0)
                item = trace
                
                if trace.from == Point(x: 0, y: 0) {
                    break;
                }
            }
        }
        
        return Diff(elements: array
            .flatMap { DiffElement(trace: $0) }
        )
    }
}

extension DiffProtocol {
    
    public typealias IndexType = Array<DiffElementType>.Index
    
    public var startIndex: IndexType {
        return elements.startIndex
    }
    
    public var endIndex: IndexType {
        return elements.endIndex
    }
    
    public subscript(i: IndexType) -> DiffElementType {
        return elements[i]
    }
}

extension ExtendedDiffElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .delete(at):
            return "D(\(at))"
        case let .insert(at):
            return "I(\(at))"
        case let .move(from, to):
            return "M(\(from)\(to))"
        }
    }
}

extension DiffElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .delete(at):
            return "D(\(at))"
        case let .insert(at):
            return "I(\(at))"
        }
    }
}

