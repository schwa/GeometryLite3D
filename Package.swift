// swift-tools-version: 6.1

import PackageDescription

let package = Package(
name: "GeometryLite3D",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)

    ],
    products: [
        .library(name: "GeometryLite3D", targets: ["GeometryLite3D"]),
    ],


    targets: [
        .target(name: "GeometryLite3D"),
        .testTarget(name: "GeometryLite3DTests", dependencies: ["GeometryLite3D"]),
    ]
)
