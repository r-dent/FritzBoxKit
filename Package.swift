// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "FritzBoxKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v9)
    ],
    products: [
        .library(
            name: "FritzBoxKit",
            targets: ["FritzBoxKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tadija/AEXML.git", from: "4.3.3"),
        .package(url: "https://github.com/gcharita/XMLMapper.git", from: "1.5.1")
    ],
    targets: [
        .target(
            name: "FritzBoxKit",
            dependencies: ["AEXML", "XMLMapper"],
            path: "Sources"
        ),
        .testTarget(
            name: "FritzBoxKitTests",
            dependencies: ["FritzBoxKit", "AEXML"],
            path: "Tests",
            exclude: ["Info.plist"],
            resources: [.process("TestResources")]
        )
    ]
)
