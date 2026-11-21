// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Ferah",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Ferah", targets: ["Ferah"]),
        .library(name: "FerahCore", targets: ["FerahCore"]),
    ],
    targets: [
        .target(name: "FerahCore"),
        .executableTarget(name: "Ferah", dependencies: ["FerahCore"]),
    ],
    swiftLanguageModes: [.v5]
)
