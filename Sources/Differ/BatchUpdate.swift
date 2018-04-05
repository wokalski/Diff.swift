import Foundation

public struct BatchUpdate {
    public struct MoveStep: Equatable {
        public let from: IndexPath
        public let to: IndexPath
    }

    public let deletions: [IndexPath]
    public let insertions: [IndexPath]
    public let moves: [MoveStep]
}
