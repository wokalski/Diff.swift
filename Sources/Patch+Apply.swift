
public extension RangeReplaceableCollection where Self.Iterator.Element: Equatable {

    public func apply(_ patch: [Patch<Generator.Element>]) -> Self {
        var mutableSelf = self

        for change in patch {
            switch change {
            case let .insertion(i, element):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.insert(element, at: target)
            case let .deletion(i):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.remove(at: target)
            }
        }

        return mutableSelf
    }
}

public extension String {

    public func apply(_ patch: [Patch<String.CharacterView.Iterator.Element>]) -> String {
        var mutableSelf = self

        for change in patch {
            switch change {
            case let .insertion(i, element):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.insert(element, at: target)
            case let .deletion(i):
                let target = mutableSelf.index(mutableSelf.startIndex, offsetBy: IndexDistance(IntMax(i)))
                mutableSelf.remove(at: target)
            }
        }

        return mutableSelf
    }
}
