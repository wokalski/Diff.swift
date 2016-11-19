
public extension Diff {
    
    typealias OrderedBefore = (_ fst: DiffElement, _ snd: DiffElement) -> Bool

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
            return fst.sourceIndex < snd.sourceIndex
        })
    }
    
    public func patch<T: Collection>(
        _ a: T,
        b: T,
        sort: OrderedBefore
        ) -> [Patch<T.Iterator.Element>] where T.Iterator.Element : Equatable {
        let shiftedPatch = patch(a, b: b)
        return shiftedPatchElements(from: sortedPatchElements(
            from: shiftedPatch,
            sortBy: sort
        )).map { $0.value }
    }
}
