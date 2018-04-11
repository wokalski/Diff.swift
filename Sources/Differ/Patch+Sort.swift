/// Generates arbitrarly sorted patch sequence. It is a list of steps to be applied to obtain the `to` collection from the `from` one. The sorting function lets you sort the output e.g. you might want the output patch to have insertions first.
///
/// - Complexity: O((N+M)*D)
///
/// - Parameters:
///   - from: The source collection
///   - to: The target collection
///   - sort: A sorting function
/// - Returns: Arbitrarly sorted sequence of steps to obtain `to` collection from the `from` one.
public func patch<T: Collection>(
    from: T,
    to: T,
    sort: Diff.OrderedBefore
) -> [Patch<T.Iterator.Element>] where T.Iterator.Element: Equatable {
    return from.diff(to).patch(from: from, to: to, sort: sort)
}

public extension Diff {

    public typealias OrderedBefore = (_ fst: Diff.Element, _ snd: Diff.Element) -> Bool

    /// Generates arbitrarly sorted patch sequence based on the callee. It is a list of steps to be applied to obtain the `to` collection from the `from` one. The sorting function lets you sort the output e.g. you might want the output patch to have insertions first.
    ///
    /// - Complexity: O(D^2)
    ///
    /// - Parameters:
    ///   - from: The source collection (usually the source collecetion of the callee)
    ///   - to: The target collection (usually the target collecetion of the callee)
    ///   - sort: A sorting function
    /// - Returns: Arbitrarly sorted sequence of steps to obtain `to` collection from the `from` one.
    public func patch<T: Collection>(
        from: T,
        to: T,
        sort: OrderedBefore
    ) -> [Patch<T.Iterator.Element>] {
        let shiftedPatch = patch(from: from, to: to)
        return shiftedPatchElements(from: sortedPatchElements(
            from: shiftedPatch,
            sortBy: sort
        )).map { $0.value }
    }

    private func sortedPatchElements<T>(from source: [Patch<T>], sortBy areInIncreasingOrder: OrderedBefore) -> [SortedPatchElement<T>] {
        let sorted = indices.map { (self[$0], $0) }
            .sorted { areInIncreasingOrder($0.0, $1.0) }
        return sorted.indices.map { i in
            let p = sorted[i]
            return SortedPatchElement(
                value: source[p.1],
                sourceIndex: p.1,
                sortedIndex: i)
        }.sorted(by: { (fst, snd) -> Bool in
            fst.sourceIndex < snd.sourceIndex
        })
    }
}
