
import Dwifft

func performDwifft(_ a: [Character], b: [Character]) {
    _ = dwifft(a, b: b)
}

private func dwifft(_ a: [Character], b: [Character]) -> Dwifft.Diff<Character> {
    return a.diff(b)
}
