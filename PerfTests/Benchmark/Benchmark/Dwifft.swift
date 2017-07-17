
import Dwifft

func performDwifft(_ a: [Character], b: [Character]) {
    _ = dwifft(a, b: b)
}

private func dwifft(_ a: [Character], b: [Character]) -> [DiffStep<Character>] {
    return Dwifft.diff(a, b);
}
