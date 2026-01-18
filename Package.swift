// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AudioSourceApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "AudioSourceApp", targets: ["AudioSourceApp"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AudioSourceApp",
            dependencies: []
        )
    ]
)
