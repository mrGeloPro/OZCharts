//
//  AreaSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import XCTest
@testable import OZCharts

final class AreaSeriesTests: XCTestCase {
    func testAreaSeriesCreatesSquareLegendItem() {
        let series = AreaSeries(
            data: [Point2D(x: 1, y: 2)],
            color: .blue,
            fillColor: .cyan,
            label: "Range"
        )

        XCTAssertEqual(series.legendItem?.title, "Range")
        XCTAssertEqual(series.legendItem?.symbol, .square)
    }

    func testAreaSeriesUsesAnimatableOverlay() {
        let series = AreaSeries(
            data: [Point2D(x: 1, y: 2)],
            color: .blue,
            animation: .draw()
        )

        XCTAssertTrue(series.usesAnimatableOverlay)
    }
}
