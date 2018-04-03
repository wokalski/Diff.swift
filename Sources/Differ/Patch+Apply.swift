public extension RangeReplaceableCollection where Self.Iterator.Element: Equatable {

    public func apply(_ patch: [Patch<Iterator.Element>]) -> Self {
        var mutableSelf = self

        for change in patch {
            switch change {
            case let .insertion(i, element):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: i)
                mutableSelf.insert(element, at: target)
            case let .deletion(i):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: i)
                mutableSelf.remove(at: target)
            }
        }

        return mutableSelf
    }
}
