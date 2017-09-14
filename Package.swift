// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Diff",
    products: [
    	.library(name: "Diff", targets: ["Diff"]),
        .executable(name: "PerformanceTester", targets: ["PerformanceTester"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jflinter/Dwifft.git", from: "0.0.0")
    ],
    targets: [
	    .target(name: "Diff"),
	    .testTarget(name: "DiffTests", dependencies: ["Diff"]),
	    .target(name: "PerformanceTester", dependencies: ["Diff", "Dwifft"], exclude: ["Samples"])
    ],
    swiftLanguageVersions: [4]
)
