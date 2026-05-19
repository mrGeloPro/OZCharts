//
//  ChartTickBuilderTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartTickBuilderTests: XCTestCase {
    func testNiceTicksUseReadableIntervalsInsideDomain() {
        let scale = LinearScale(domain: 3...97, range: 0...94)

        let ticks = ChartTickBuilder.ticks(
            scale: scale,
            explicitValues: nil,
            tickCount: 5,
            strategy: .nice,
            formatter: { "\(Int($0))" }
        )

        XCTAssertEqual(ticks.map(\.value), [20, 40, 60, 80])
        XCTAssertEqual(ticks.map(\.label), ["20", "40", "60", "80"])
    }

    func testExplicitValuesOverrideNiceTickStrategy() {
        let scale = LinearScale(domain: 0...100, range: 0...100)

        let ticks = ChartTickBuilder.ticks(
            scale: scale,
            explicitValues: [0, 30, 100],
            tickCount: 5,
            strategy: .nice,
            formatter: { "\(Int($0))" }
        )

        XCTAssertEqual(ticks.map(\.value), [0, 30, 100])
    }

    func testGeneratedTicksDeduplicateRoundedLabels() {
        let scale = LinearScale(domain: 32.0...32.9, range: 0...100)

        let ticks = ChartTickBuilder.ticks(
            scale: scale,
            explicitValues: nil,
            tickCount: 5,
            strategy: .regular,
            formatter: { "\(Int($0))m" }
        )

        XCTAssertEqual(ticks.map(\.label), ["32m"])
    }

    func testCollisionFilterKeepsMinimumSpacing() {
        let ticks = [
            ScaleTick(value: Double(0), position: CGFloat(0), label: "0"),
            ScaleTick(value: Double(1), position: CGFloat(10), label: "1"),
            ScaleTick(value: Double(2), position: CGFloat(50), label: "2")
        ]

        let filtered = ChartTickBuilder.filteredTicks(
            ticks,
            strategy: .hideOverlapping(minSpacing: 24)
        )

        XCTAssertEqual(filtered.map(\.value), [0, 2].map(Double.init))
    }

    func testVisibleTickFilterRemovesPositionsOutsideAxisLength() {
        let ticks = [
            ScaleTick(value: Double(330), position: CGFloat(-25), label: "330"),
            ScaleTick(value: Double(400), position: CGFloat(0), label: "400"),
            ScaleTick(value: Double(600), position: CGFloat(120), label: "600"),
            ScaleTick(value: Double(900), position: CGFloat(240), label: "900"),
            ScaleTick(value: Double(1000), position: CGFloat(265), label: "1000")
        ]

        let filtered = ChartTickBuilder.visibleTicks(ticks, length: 240)

        XCTAssertEqual(filtered.map(\.value), [400, 600, 900].map(Double.init))
    }
}
