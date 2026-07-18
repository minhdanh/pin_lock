// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "pin_lock",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "pin_lock", targets: ["pin_lock"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "pin_lock",
            dependencies: [],
            resources: []
        )
    ]
)
