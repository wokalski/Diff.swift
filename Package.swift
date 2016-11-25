import PackageDescription

let package = Package(
    name: "Diff",
    dependencies: []
)

products.append(Product(name: "Diff", type: .Library(.Dynamic), modules: ["Diff"]))
