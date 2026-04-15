// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OZCharts",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "OZCharts",
            targets: ["OZCharts"]),
    ],
    targets: [
        .target(
            name: "OZCharts"),
    ]
)
