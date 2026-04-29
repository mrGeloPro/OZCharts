//
//  BarSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class BarSeriesTests: XCTestCase {
    func testBarLayoutsGrowFromBaseline() {
        let series = BarSeries(
            data: [Point2D(x: 1, y: 8)],
            color: .blue,
            barWidth: 12,
            baseline: 0
        )
        let contexts = [
            ChartPointContext(
                originalPoint: Point2D(x: 1, y: 8),
                position: CGPoint(x: 50, y: 20),
                scaleY: { value in CGFloat(100 - value * 10) }
            )
        ]

        let layouts = series.barLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 1)
        XCTAssertEqual(layouts[0].rect.origin.x, 44, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.origin.y, 20, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.width, 12, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.height, 80, accuracy: 0.0001)
    }

    func testBarSeriesCreatesLegendItemWhenLabelExists() {
        let series = BarSeries(
            data: [Point2D(x: 1, y: 2)],
            color: .green,
            label: "Volume"
        )

        XCTAssertEqual(series.legendItem?.title, "Volume")
        XCTAssertEqual(series.legendItem?.symbol, .square)
    }
}
