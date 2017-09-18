// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Differ",
    products: [
        .library(name: "Differ", targets: ["Differ"]),
        .executable(name: "PerformanceTester", targets: ["PerformanceTester"])
    ],
    dependencies: [
        .package(url: "https://github.com/jflinter/Dwifft.git", from: "0.0.0")
    ],
    targets: [
        .target(name: "Differ"),
        .testTarget(name: "DifferTests", dependencies: ["Differ"]),
        .target(name: "PerformanceTester", dependencies: ["Differ", "Dwifft"], exclude: ["Samples"])
    ],
    swiftLanguageVersions: [4]
)
