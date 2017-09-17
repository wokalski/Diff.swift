public final class PerformanceTesterTool {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        guard arguments.count == 3 else {
            throw Error.tooFewFilesSpecified
        }

        let from = arguments[1]
        let to = arguments[2]

        print("Benchmarking Dwifft…", terminator: " ")
        let dwifft = performDiff(fromFilePath: from, toFilePath: to, diffFunc: performDwifft)
        print("Done!")

        print("Benchmarking Diff…", terminator: " ")
        let diff = performDiff(fromFilePath: from, toFilePath: to, diffFunc: diffSwift)
        print("Done!", terminator: "\n\n\n")

        print("         | Diffy          | Dwifft           ")
        print("---------|:-------------------:|:----------------:")
        print(" same    |   \(diff.same)   | \(dwifft.same)")
        print(" created |   \(diff.created)   | \(dwifft.created)")
        print(" deleted |   \(diff.deleted)   | \(dwifft.deleted)")
        print(" diff    |   \(diff.changed)   | \(dwifft.changed)")
    }
}

public extension PerformanceTesterTool {
    enum Error: Swift.Error {
        case tooFewFilesSpecified
    }
}

let tool = PerformanceTesterTool()

do {
    try tool.run()
} catch {
    print("Whoops! An error occurred: \(error)")
}
