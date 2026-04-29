// swift-tools-version: 5.9
//
//  Package.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "OZCharts",
    platforms: [
        .iOS(.v16),
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
        .testTarget(
            name: "OZChartsTests",
            dependencies: ["OZCharts"]),
    ]
)
