// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Diffy",
    products: [
        .library(name: "Diffy", targets: ["Diffy"]),
        .executable(name: "PerformanceTester", targets: ["PerformanceTester"])
    ],
    dependencies: [
        .package(url: "https://github.com/jflinter/Dwifft.git", from: "0.0.0")
    ],
    targets: [
        .target(name: "Diffy"),
        .testTarget(name: "DiffyTests", dependencies: ["Diffy"]),
        .target(name: "PerformanceTester", dependencies: ["Diffy", "Dwifft"], exclude: ["Samples"])
    ],
    swiftLanguageVersions: [4]
)
