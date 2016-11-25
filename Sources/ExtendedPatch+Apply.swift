
// TODO: Fix ugly copy paste :/

public extension RangeReplaceableCollection where Self.Iterator.Element: Equatable {

    public func apply(_ patch: [ExtendedPatch<Generator.Element>]) -> Self {
        var mutableSelf = self

        for change in patch {
            switch change {
            case let .insertion(i, element):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.insert(element, at: target)
            case let .deletion(i):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.remove(at: target)
            case let .move(from, to):
                let fromIndex = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(from)))
                let toIndex = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(to)))
                let element = mutableSelf.remove(at: fromIndex)
                mutableSelf.insert(element, at: toIndex)
            }
        }

        return mutableSelf
    }
}

public extension String {

    public func apply(_ patch: [ExtendedPatch<String.CharacterView.Iterator.Element>]) -> String {
        var mutableSelf = self

        for change in patch {
            switch change {
            case let .insertion(i, element):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.insert(element, at: target)
            case let .deletion(i):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.remove(at: target)
            case let .move(from, to):
                let fromIndex = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(from)))
                let toIndex = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(to)))
                let element = mutableSelf.remove(at: fromIndex)
                mutableSelf.insert(element, at: toIndex)
            }
        }

        return mutableSelf
    }
}
