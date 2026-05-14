//
//  AxisPresetTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import XCTest
@testable import OZCharts

final class AxisPresetTests: XCTestCase {
    func testTimeAxisFormatsIntegerSeconds() {
        let axis = XAxisConfig.time(suffix: "ms")

        XCTAssertEqual(axis.labelFormatter(42.7), "42ms")
    }

    func testPercentAxisFormatsFractionValuesWhenRequested() {
        let axis = YAxisConfig.percent(fractionValues: true)

        XCTAssertEqual(axis.labelFormatter(0.42), "42%")
    }

    func testHiddenAxesReserveNoSpace() {
        XCTAssertEqual(XAxisConfig.hidden().height, 0)
        XCTAssertEqual(YAxisConfig.hidden().width, 0)
    }

    func testAxisTransformMapsDisplayValues() {
        XCTAssertEqual(AxisTransform.identity(42), 42)
        XCTAssertEqual(AxisTransform.linear(multiplier: 2, offset: 1)(4), 9)
        XCTAssertEqual(AxisTransform.offset(5)(4), 9)
        XCTAssertEqual(AxisTransform.percentage(of: 200)(50), 25)
        XCTAssertEqual(AxisTransform.reciprocal(numerator: 60_000)(500), 120)
        XCTAssertEqual(AxisTransform.reciprocal(numerator: 60_000)(0), 0)
        XCTAssertEqual(AxisTransform.linear(multiplier: 10).clamped(to: 0...100)(20), 100)
        XCTAssertEqual(AxisTransform { _ in Double.infinity }.replacingNonFinite(with: -1)(20), -1)
        XCTAssertEqual(
            AxisTransform.linear(multiplier: 2).combined(with: .linear(offset: 1))(4),
            9
        )
    }

    func testAxisConfigStoresTransform() {
        let axis = YAxisConfig(axisTransform: .reciprocal(numerator: 60_000))

        XCTAssertEqual(axis.axisTransform(500), 120)
    }
}
