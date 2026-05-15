//
//  ChartLayoutEngineTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import XCTest

final class ChartLayoutEngineTests: XCTestCase {
    func testInsetsUseAxisDimensions() {
        let layout = ChartLayoutEngine.layout(
            in: CGSize(width: 320, height: 240),
            xAxes: [
                XAxisConfig(position: .top, height: 24),
                XAxisConfig(position: .bottom, height: 32)
            ],
            yAxes: [
                YAxisConfig(position: .leading, width: 40),
                YAxisConfig(position: .trailing, width: 52)
            ]
        )

        XCTAssertEqual(layout.insets.top, 24)
        XCTAssertEqual(layout.insets.bottom, 32)
        XCTAssertEqual(layout.insets.leading, 40)
        XCTAssertEqual(layout.insets.trailing, 52)
        XCTAssertEqual(layout.plotArea, CGRect(x: 40, y: 24, width: 228, height: 184))
    }

    func testMeasuredInsetsExpandForLongAxisLabels() {
        let measured = ChartLayoutEngine.measuredInsets(
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    explicitValues: [0],
                    labelFormatter: { _ in "Extremely long localized bottom label" },
                    height: 8
                )
            ],
            yAxes: [
                YAxisConfig(
                    position: .trailing,
                    explicitValues: [0],
                    labelFormatter: { _ in "1,000,000 bpm" },
                    width: 8
                )
            ]
        )

        XCTAssertGreaterThan(measured.bottom, 8)
        XCTAssertGreaterThan(measured.trailing, 8)
    }

    func testMeasuredLayoutUsesExpandedInsetsWhenRequested() {
        let layout = ChartLayoutEngine.layout(
            in: CGSize(width: 200, height: 120),
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    explicitValues: [0],
                    labelFormatter: { _ in "Long bottom label" },
                    height: 8
                )
            ],
            yAxes: [],
            usesMeasuredInsets: true
        )

        XCTAssertGreaterThan(layout.insets.bottom, 8)
        XCTAssertLessThan(layout.plotArea.height, 112)
    }

    func testPlotAreaNeverBecomesNegative() {
        let plotArea = ChartLayoutEngine.plotArea(
            in: CGSize(width: 80, height: 60),
            insets: ChartInsets(top: 40, leading: 30, bottom: 40, trailing: 80)
        )

        XCTAssertEqual(plotArea.origin.x, 30)
        XCTAssertEqual(plotArea.origin.y, 40)
        XCTAssertEqual(plotArea.size.width, 0)
        XCTAssertEqual(plotArea.size.height, 0)
    }
}
