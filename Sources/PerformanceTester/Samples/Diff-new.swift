

public struct Diff {
    let elements: [DiffElement]
}

public enum DiffElement {
    case Insert(from: Int, at: Int)
    case Delete(at: Int)
    case Equal(aIndex: Int, bIndex: Int)
}

extension DiffElement {
    init(trace: Trace) {
        if trace.from.x + 1 == trace.to.x && trace.from.y + 1 == trace.to.y {
            self = .Equal(aIndex: trace.to.x, bIndex: trace.to.y)
        } else if trace.from.y < trace.to.y {
            self = .Insert(from: trace.from.y, at: trace.from.x)
        } else {
            self = .Delete(at: trace.from.x)
        }
    }
}

public struct Point {
    let x: Int
    let y: Int
}

public struct Trace {
    let from: Point
    let to: Point
    let D: Int
}

enum TraceType {
    case Insertion
    case Deletion
    case MatchPoint
}

extension Trace {
    func type() -> TraceType {
        if from.x + 1 == to.x && from.y + 1 == to.y {
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

public extension RangeReplaceableCollectionType where Self.Generator.Element: Equatable, Self.Index: SignedIntegerType {
    public func apply(patch: Patch<Generator.Element, Index>) -> Self {
        var mutableSelf = self

        for insertion in patch.insertions {
            mutableSelf.insert(insertion.element, atIndex: insertion.index)
        }
        for deletion in patch.deletions {
            mutableSelf.removeAtIndex(deletion)
        }
        return mutableSelf
    }

    public func apply(patch: [PatchElement<Generator.Element, Index>]) -> Self {
        var mutableSelf = self

        for change in patch {
            switch change {
            case let .Insertion(index, element):
                mutableSelf.insert(element, atIndex: index)
            case let .Deletion(index):
                mutableSelf.removeAtIndex(index)
            }
        }

        return mutableSelf
    }
}

public extension CollectionType where Generator.Element: Equatable, Index: SignedIntegerType {

    public func diffTraces(b: Self) -> Array<Trace> {

        let N = Int(self.count.toIntMax())
        let M = Int(b.count.toIntMax())
        var traces = Array<Trace>()

        let max = N + M // this is arbitrary, maximum difference between a and b. N+M assures that this algorithm always finds a diff

        var V = Array(count: 2 * Int(max) + 1, repeatedValue: -1) // from [0...2*max], it is -max...max in the whitepaper

        V[max + 1] = 0

        for D in 0 ... max {
            for k in (-D).stride(through: D, by: 2) {

                let index = k + max

                // if x value for bigger (x-y) V[index-1] is smaller than x value for smaller (x-y) V[index+1]
                // then return smaller (x-y)
                // well, why??
                // It means that y = x - k will be bigger
                // otherwise y = x - k will be smaller
                // What is the conclusion? Hell knows.

                /*
                 case 1: k == -D: take the furthest going k+1 trace and go greedly down. We take x of the furthest going k+1 path and go greedly down.
                 case 2: k == D: take the furthest going k-d trace and go right. Again, k+1 is unknown so we have to take k-1. What's more k-1 is right most one trace. We add 1 so that we go 1 to the right direction and stay on the same y
                 case 3: -D<k<D: take the rightmost one (biggest x) and if it the previous trace went right go down, otherwise (if it the trace went down) go right
                 */

                var x = { _ -> Int in
                    if k == -D || (k != D && V[index - 1] < V[index + 1]) { // V[index-1] - y is bigger V[index+1] - y is smaller
                        let x = V[index + 1]
                        traces.append(Trace(from: Point(x: x, y: x - k - 1), to: Point(x: x, y: x - k), D: D))
                        return x // go down AKA insert
                    } else {
                        let x = V[index - 1] + 1
                        traces.append(Trace(from: Point(x: x - 1, y: x - k), to: Point(x: x, y: x - k), D: D))
                        return x // go right AKA delete
                    }
                }()

                var y = x - k

                // keep going as long as they match on diagonal k
                while x < N && y < M && self[Self.Index(x.toIntMax())] == b[Self.Index(y.toIntMax())] {
                    x += 1
                    y += 1
                    traces.append(Trace(from: Point(x: x - 1, y: y - 1), to: Point(x: x, y: y), D: D))
                }

                V[index] = x

                if x >= N && y >= M {
                    return traces
                }
            }
        }
        return []
    }

    func diff(b: Self) -> Diff {
        return findPath(diffTraces(b), n: Int(self.count.toIntMax()), m: Int(b.count.toIntMax()))
    }

    private func findPath(traces: Array<Trace>, n: Int, m: Int) -> Diff {

        guard traces.count > 0 else {
            return Diff(elements: [])
        }

        var array = Array<Trace>()
        var item = traces.last!
        array.append(item)

        for trace in traces.reverse() {
            if trace.to.x == item.from.x && trace.to.y == item.from.y {
                array.append(trace)
                item = trace
            }

            if trace.from.x == 0 && trace.from.y == 0 {
                break
            }
        }
        return Diff(elements: array.reverse().map { DiffElement(trace: $0) })
    }
}
