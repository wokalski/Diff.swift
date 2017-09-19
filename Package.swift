// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Differ",
    products: [
        .library(name: "Differ", targets: ["Differ"]),
    ],
    targets: [
        .target(name: "Differ"),
        .testTarget(name: "DifferTests", dependencies: ["Differ"]),
    ],
    swiftLanguageVersions: [4]
)
