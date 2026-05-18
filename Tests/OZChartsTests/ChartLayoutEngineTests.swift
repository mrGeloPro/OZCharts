//
//  ChartLayoutEngineTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
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

    func testMeasuredInsetsKeepLabelSpacingWhenTicksAreHidden() {
        let tight = ChartLayoutEngine.measuredInsets(
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "10" },
                    height: 1,
                    tickLength: 40,
                    labelSpacing: 2
                )
            ],
            yAxes: []
        )
        let padded = ChartLayoutEngine.measuredInsets(
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "10" },
                    height: 1,
                    tickLength: 40,
                    labelSpacing: 18
                )
            ],
            yAxes: []
        )

        XCTAssertGreaterThan(padded.bottom, tight.bottom + 12)
    }

    func testMeasuredInsetsIgnoreTickLengthWhenTicksAreHidden() {
        let hiddenTicks = ChartLayoutEngine.measuredInsets(
            xAxes: [],
            yAxes: [
                YAxisConfig(
                    position: .leading,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "100" },
                    width: 1,
                    tickLength: 40,
                    labelSpacing: 8
                )
            ]
        )
        let visibleTicks = ChartLayoutEngine.measuredInsets(
            xAxes: [],
            yAxes: [
                YAxisConfig(
                    position: .leading,
                    showTicks: true,
                    explicitValues: [0],
                    labelFormatter: { _ in "100" },
                    width: 1,
                    tickLength: 40,
                    labelSpacing: 8
                )
            ]
        )

        XCTAssertGreaterThan(visibleTicks.leading, hiddenTicks.leading + 30)
    }

    func testMeasuredInsetsIncludeXAxisLabelInsets() {
        let tight = ChartLayoutEngine.measuredInsets(
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "10" },
                    height: 1
                )
            ],
            yAxes: []
        )
        let padded = ChartLayoutEngine.measuredInsets(
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "10" },
                    height: 1,
                    labelInsets: EdgeInsets(top: 8, leading: 0, bottom: 10, trailing: 0)
                )
            ],
            yAxes: []
        )

        XCTAssertGreaterThan(padded.bottom, tight.bottom + 16)
    }

    func testMeasuredInsetsIncludeYAxisLabelInsets() {
        let tight = ChartLayoutEngine.measuredInsets(
            xAxes: [],
            yAxes: [
                YAxisConfig(
                    position: .leading,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "100" },
                    width: 1
                )
            ]
        )
        let padded = ChartLayoutEngine.measuredInsets(
            xAxes: [],
            yAxes: [
                YAxisConfig(
                    position: .leading,
                    showTicks: false,
                    explicitValues: [0],
                    labelFormatter: { _ in "100" },
                    width: 1,
                    labelInsets: EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 9)
                )
            ]
        )

        XCTAssertGreaterThan(padded.leading, tight.leading + 14)
    }

    func testMeasuredInsetsIgnoreTickSpacingWhenAxisProducesNoTicks() {
        let measured = ChartLayoutEngine.measuredInsets(
            xAxes: [
                XAxisConfig(
                    position: .bottom,
                    tickCount: 0,
                    labelFormatter: { _ in "" },
                    height: 1,
                    tickLength: 40,
                    labelSpacing: 24,
                    labelInsets: EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0),
                    title: "Axis"
                )
            ],
            yAxes: []
        )

        XCTAssertLessThan(measured.bottom, 40)
        XCTAssertGreaterThan(measured.bottom, 1)
    }

    func testMeasuredInsetsMatchPerAxisMeasuredDimensions() {
        let xAxes = [
            XAxisConfig(position: .top, explicitValues: [0], labelFormatter: { _ in "Top" }, height: 1),
            XAxisConfig(position: .bottom, explicitValues: [0], labelFormatter: { _ in "Bottom" }, height: 1)
        ]
        let yAxes = [
            YAxisConfig(position: .leading, explicitValues: [0], labelFormatter: { _ in "Leading" }, width: 1),
            YAxisConfig(position: .trailing, explicitValues: [0], labelFormatter: { _ in "Trailing" }, width: 1)
        ]

        let measured = ChartLayoutEngine.measuredInsets(xAxes: xAxes, yAxes: yAxes)

        XCTAssertEqual(measured.top, ChartLayoutEngine.measuredHeight(for: xAxes[0], labelSampleLimit: 12))
        XCTAssertEqual(measured.bottom, ChartLayoutEngine.measuredHeight(for: xAxes[1], labelSampleLimit: 12))
        XCTAssertEqual(measured.leading, ChartLayoutEngine.measuredWidth(for: yAxes[0], labelSampleLimit: 12))
        XCTAssertEqual(measured.trailing, ChartLayoutEngine.measuredWidth(for: yAxes[1], labelSampleLimit: 12))
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
