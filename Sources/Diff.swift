
public protocol DiffProtocol: Collection, Sequence {

    associatedtype DiffElementType

    var elements: [DiffElementType] { get }
}

/**
 A sequence of deletions and insertions where deletions point to locations in the source and insertions point to locations in the output.
 Examples:
 "12" -> "": D(0)D(1)
 "" -> "12": I(0)I(1)

 SeeAlso: Diff
 */
public struct Diff: DiffProtocol {

    public enum Element {
        case insert(at: Int)
        case delete(at: Int)
    }

    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

    /// An array of particular diff operations
    public let elements: [Diff.Element]
}

extension Diff.Element {
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

public struct Point {
    public let x: Int
    public let y: Int
}

extension Point: Equatable {}

public func ==(l: Point, r: Point) -> Bool {
    return (l.x == r.x) && (l.y == r.y)
}

/// A data structure representing single trace produced by the diff algorithm. See the [paper](http://www.xmailserver.org/diff2.pdf) for more information on traces.
public struct Trace {
    public let from: Point
    public let to: Point
    public let D: Int
}

extension Trace: Equatable {
    public static func ==(l: Trace, r: Trace) -> Bool {
        return (l.from == r.from) && (l.to == r.to)
    }
}

enum TraceType {
    case insertion
    case deletion
    case matchPoint
}

extension Trace {
    func type() -> TraceType {
        if from.x + 1 == to.x && from.y + 1 == to.y {
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

    /// Creates a diff between the calee and `to` string
    ///
    /// - parameter to: a string to compare the calee to.
    /// - complexity: O((N+M)*D)
    /// - returns: a Diff between the calee and `to` string
    public func diff(to: String) -> Diff {
        if self == to {
            return Diff(elements: [])
        }
        return characters.diff(to.characters)
    }

    /// Creates an extended diff (includes insertions, deletions, and moves) between the calee and `other` string
    ///
    /// - parameter other: a string to compare the calee to.
    /// - complexity: O((N+M)*D)
    /// - returns: an ExtendedDiff between the calee and `other` string
    public func extendedDiff(_ other: String) -> ExtendedDiff {
        if self == other {
            return ExtendedDiff(
                source: Diff(elements: []),
                sourceIndex: [],
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
        if index < 0 || index >= self.count {
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

public extension Collection where Iterator.Element: Equatable {

    /// Creates a diff between the calee and `other` collection
    ///
    /// - parameter other: a collection to compare the calee to
    /// - complexity: O((N+M)*D)
    /// - returns: a Diff between the calee and `other` collection
    public func diff(_ other: Self) -> Diff {
        return findPath(diffTraces(to: other), n: Int(self.count.toIntMax()), m: Int(other.count.toIntMax()))
    }

    /// Generates all traces required to create an output diff. See the [paper](http://www.xmailserver.org/diff2.pdf) for more information on traces.
    ///
    /// - parameter to: other collection
    ///
    /// - returns: all traces required to create an output diff
    public func diffTraces(to: Self) -> [Trace] {
        if self.count == 0 && to.count == 0 {
            return []
        } else if self.count == 0 {
            return tracesForInsertions(to: to)
        } else if to.count == 0 {
            return tracesForDeletions()
        } else {
            return myersDiffTraces(to: to)
        }
    }

    fileprivate func tracesForDeletions() -> [Trace] {
        var traces = [Trace]()
        for index in 0 ..< self.count.toIntMax() {
            let intIndex = index.toIntMax()
            traces.append(Trace(from: Point(x: Int(intIndex), y: 0), to: Point(x: Int(intIndex) + 1, y: 0), D: 0))
        }
        return traces
    }

    fileprivate func tracesForInsertions(to: Self) -> [Trace] {
        var traces = [Trace]()
        for index in 0 ..< to.count.toIntMax() {
            let intIndex = index.toIntMax()
            traces.append(Trace(from: Point(x: 0, y: Int(intIndex)), to: Point(x: 0, y: Int(intIndex) + 1), D: 0))
        }
        return traces
    }

    fileprivate func myersDiffTraces(to: Self) -> [Trace] {

        let fromCount = Int(self.count.toIntMax())
        let toCount = Int(to.count.toIntMax())
        var traces = Array<Trace>()

        let max = fromCount + toCount // this is arbitrary, maximum difference between from and to. N+M assures that this algorithm always finds from diff

        var vertices = Array(repeating: -1, count: 2 * Int(max) + 1) // from [0...2*max], it is -max...max in the whitepaper

        vertices[max + 1] = 0

        for numberOfDifferences in 0 ... max {
            for k in stride(from: (-numberOfDifferences), through: numberOfDifferences, by: 2) {

                let index = k + max
                let traceStep = TraceStep(D: numberOfDifferences, k: k, previousX: vertices.value(at: index - 1), nextX: vertices.value(at: index + 1))
                if let trace = bound(trace: nextTrace(traceStep), maxX: fromCount, maxY: toCount) {
                    var x = trace.to.x
                    var y = trace.to.y

                    traces.append(trace)

                    // keep going as long as they match on diagonal k
                    while x >= 0 && y >= 0 && x < fromCount && y < toCount {
                        let targetItem = to.itemOnStartIndex(advancedBy: y)
                        let baseItem = itemOnStartIndex(advancedBy: x)
                        if baseItem == targetItem {
                            x += 1
                            y += 1
                            traces.append(Trace(from: Point(x: x - 1, y: y - 1), to: Point(x: x, y: y), D: numberOfDifferences))
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

        if traceType == .insertion {
            let x = traceStep.nextX!
            return Trace(from: Point(x: x, y: x - k - 1), to: Point(x: x, y: x - k), D: D)
        } else {
            let x = traceStep.previousX! + 1
            return Trace(from: Point(x: x - 1, y: x - k), to: Point(x: x, y: x - k), D: D)
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
            if let previousX = previousX, let nextX = nextX, previousX < nextX {
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

        if item.from != Point(x: 0, y: 0) {
            for trace in traces.reversed() {
                if trace.to.x == item.from.x && trace.to.y == item.from.y {
                    array.insert(trace, at: 0)
                    item = trace

                    if trace.from == Point(x: 0, y: 0) {
                        break
                    }
                }
            }
        }

        return Diff(elements: array
            .flatMap { Diff.Element(trace: $0) }
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

extension Diff.Element: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .delete(at):
            return "D(\(at))"
        case let .insert(at):
            return "I(\(at))"
        }
    }
}
