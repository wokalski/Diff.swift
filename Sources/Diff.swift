
public protocol DiffProtocol: CollectionType, SequenceType {
    
    associatedtype DiffElementType
    associatedtype Index = Array<DiffElementType>.Index
    
    var elements: [DiffElementType] { get }
}

public struct Diff: DiffProtocol {
    public let elements: [DiffElement]
}

public enum DiffElement {
    case Insert(at: Int)
    case Delete(at: Int)
}

public struct ExtendedDiff: DiffProtocol {
    public let elements: [ExtendedDiffElement]
}

public enum ExtendedDiffElement {
    case Insert(at: Int)
    case Delete(at: Int)
    case Move(from: Int, to: Int)
}

extension DiffElement {
    public init?(trace: Trace) {
        switch trace.type() {
        case .Insertion:
            self = .Insert(at: trace.from.y)
        case .Deletion:
            self = .Delete(at: trace.from.x)
        case .MatchPoint:
            return nil
        }
    }
    
    func at() -> Int {
        switch self {
        case let .Delete(at):
            return at
        case let .Insert(at):
            return at
        }
    }
}

extension ExtendedDiffElement {
    init(_ diffElement: DiffElement) {
        switch diffElement {
        case let .Delete(at):
            self = .Delete(at: at)
        case let .Insert(at):
            self = .Insert(at: at)
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
    case Insertion
    case Deletion
    case MatchPoint
}

extension Trace {
    func type() -> TraceType {
        if from.x+1 == to.x && from.y+1 == to.y {
            return .MatchPoint
        } else if from.y < to.y {
            return .Insertion
        } else {
            return .Deletion
        }
    }
    
    func k() -> Int {
        return from.x - from.y
    }
}

extension ForwardIndexType {
    func advancedByInt(x: Int) -> Self {
        return advancedBy(Distance(x.toIntMax()))
    }
}

public extension String {
    public func diff(b: String) -> Diff {
        if self == b {
            return Diff(elements: [])
        }
        return characters.diff(b.characters)
    }
    public func extendedDiff(other: String) -> ExtendedDiff {
        if self == other {
            return ExtendedDiff(elements: [])
        }
        return characters.extendedDiff(other.characters)
    }
}

extension Array {
    func value(at index: Index) -> Generator.Element? {
        if (index < 0 || index >= self.count) {
            return nil
        }
        return self[index]
    }
}

struct TraceStep {
    let D: Int
    let  k: Int
    let previousX: Int?
    let nextX: Int?
}

public extension CollectionType where Generator.Element : Equatable {
    
    public func diff(other: Self) -> Diff {
        return findPath(diffTraces(other), n: Int(self.count.toIntMax()), m: Int(other.count.toIntMax()))
    }
    
    public func extendedDiff(other: Self) -> ExtendedDiff {
        return extendedDiffFrom(diff(other), other: other)
    }
    
    private func extendedDiffFrom(diff: Diff, other: Self) -> ExtendedDiff {
        
        
        var elements = [ExtendedDiffElement]()
        var dirtyDiffElements: Set<Diff.Index> = []
        

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
            let candidate = diff[candidateIndex]
            let match = firstMatch(diff, dirtyIndices: dirtyDiffElements, candidate: candidate, candidateIndex: candidateIndex, other: other)
            if let match = match {
                elements.append(match.0)
                dirtyDiffElements.insert(match.1)
            } else if !dirtyDiffElements.contains(candidateIndex) {
                elements.append(ExtendedDiffElement(candidate))
            }
        }
        
        return ExtendedDiff(elements: elements)
    }
    
    func firstMatch(
        diff: Diff,
        dirtyIndices: Set<Diff.Index>,
        candidate: DiffElement,
        candidateIndex: Diff.Index,
        other: Self) -> (ExtendedDiffElement, Diff.Index)? {
        
        var others = [DiffElement]()

        for matchIndex in candidateIndex.successor()..<diff.endIndex {
            if !dirtyIndices.contains(matchIndex) {
                let match = diff[matchIndex]
                if let move = createMatCH(candidate, match: match, other: other) {
                    return (move, matchIndex)
                } else {
                    others.append(match)
                }
            }
        }
        return nil
    }
    
    func createMatCH(candidate: DiffElement, match: DiffElement, other: Self) -> ExtendedDiffElement? {
        switch (candidate, match) {
        case (.Delete, .Insert):
            if self.element(atIndex: candidate.at()) == other.element(atIndex: match.at()) {
                return .Move(from: candidate.at(), to: match.at())
            }
        case (.Insert, .Delete):
            if self[self.startIndex.advancedByInt(match.at())] == other[other.startIndex.advancedByInt(candidate.at())] {
                return .Move(from: match.at(), to: candidate.at())
            }
        default: return nil
        }
        return nil
    }
    
    
    public func diffTraces(b: Self) -> [Trace] {
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
    
    private func tracesForDeletions() -> [Trace] {
        var traces = [Trace]()
        for index in 0..<self.count.toIntMax() {
            let intIndex = index.toIntMax()
            traces.append(Trace(from: Point(x: Int(intIndex), y: 0), to: Point(x: Int(intIndex)+1, y: 0), D: 0))
        }
        return traces
    }
    
    private func tracesForInsertions(b: Self) -> [Trace] {
        var traces = [Trace]()
        for index in 0..<b.count.toIntMax() {
            let intIndex = index.toIntMax()
            traces.append(Trace(from: Point(x: 0, y: Int(intIndex)), to: Point(x: 0, y: Int(intIndex)+1), D: 0))
        }
        return traces
    }
    
    private func myersDiffTraces(b: Self) -> [Trace] {
        
        let fromCount = Int(self.count.toIntMax())
        let toCount = Int(b.count.toIntMax())
        var traces = Array<Trace>()
        
        let max = fromCount+toCount // this is arbitrary, maximum difference between a and b. N+M assures that this algorithm always finds a diff
        
        var vertices = Array(count: 2 * Int(max) + 1, repeatedValue: -1) // from [0...2*max], it is -max...max in the whitepaper
        
        vertices[max+1] = 0
        
        for numberOfDifferences in 0...max {
            for k in (-numberOfDifferences).stride(through: numberOfDifferences, by: 2) {
                
                let index = k+max
                let traceStep = TraceStep(D: numberOfDifferences, k: k, previousX: vertices.value(at: index-1), nextX: vertices.value(at: index+1))
                if let trace = bound(trace: nextTrace(traceStep), maxX: fromCount, maxY: toCount) {
                    var x = trace.to.x
                    var y = trace.to.y
                    
                    traces.append(trace)
                    
                    // keep going as long as they match on diagonal k
                    while x >= 0 && y >= 0 && x < fromCount && y < toCount {
                        let yIndex = b.startIndex.advancedByInt(y)
                        let xIndex = startIndex.advancedByInt(x)
                        if self[xIndex] == b[yIndex] {
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
    
    private func bound(trace trace: Trace, maxX: Int, maxY: Int) -> Trace? {
        guard trace.to.x <= maxX && trace.to.y <= maxY else {
            return nil
        }
        return trace
    }
    
    private func nextTrace(traceStep: TraceStep) -> Trace {
        let traceType = nextTraceType(traceStep)
        let k = traceStep.k
        let D = traceStep.D
        
        if  traceType == .Insertion {
            let x = traceStep.nextX!
            return Trace(from: Point(x: x, y: x-k-1), to: Point(x: x, y: x-k), D: D)
        } else {
            let x = traceStep.previousX! + 1
            return Trace(from: Point(x: x-1, y: x-k), to: Point(x: x, y: x-k), D: D)
        }
    }
    
    private func nextTraceType(traceStep: TraceStep) -> TraceType {
        let D = traceStep.D
        let k = traceStep.k
        let previousX = traceStep.previousX
        let nextX = traceStep.nextX
        
        if k == -D {
            return .Insertion
        } else if k != D {
            if let previousX = previousX, nextX = nextX where previousX < nextX {
                return .Insertion
            }
            return .Deletion
        } else {
            return .Deletion
        }
    }
    
    private func findPath(traces: [Trace], n: Int, m: Int) -> Diff {
        
        guard traces.count > 0 else {
            return Diff(elements: [])
        }
        
        var array = [Trace]()
        var item = traces.last!
        array.append(item)
        
        for trace in traces.reverse() {
            if trace.to.x == item.from.x && trace.to.y == item.from.y {
                array.insert(trace, atIndex: 0)
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
    
    
    // Move this out to a protocol so that it's possible to specify it per class - allows for some performance gains. For instance Array could simply implement it as self[index] 
    func element(atIndex i: Int) -> Generator.Element {
        let index = self.startIndex.advancedByInt(i)
        return self[index]
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
        case let Delete(at):
            return "D(\(at))"
        case let Insert(at):
            return "I(\(at))"
        case let Move(from, to):
            return "M(\(from)\(to))"
        }
    }
}

extension DiffElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let Delete(at):
            return "D(\(at))"
        case let Insert(at):
            return "I(\(at))"
        }
    }
}

