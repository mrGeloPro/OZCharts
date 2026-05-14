//
//  PerformanceBenchmarkTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation
import SwiftUI
import XCTest
@testable import OZCharts

final class PerformanceBenchmarkTests: XCTestCase {
    @MainActor
    func testLargeLineLayoutPerformanceWhenEnabled() throws {
        guard ProcessInfo.processInfo.environment["RUN_OZCHARTS_PERFORMANCE_TESTS"] == "1" else {
            throw XCTSkip("Set RUN_OZCHARTS_PERFORMANCE_TESTS=1 to run performance benchmarks.")
        }

        let points = (0..<20_000).map { index in
            Point2D(
                x: Double(index),
                y: 50 + sin(Double(index) / 18) * 20 + cos(Double(index) / 71) * 8
            )
        }
        let series = LineSeries(
            data: points,
            color: .cyan,
            downsampling: .automatic(maxPointsPerPixel: 1)
        ).eraseToAnyChartSeries()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...20_000),
            yScale: LinearScale(domain: 0...100)
        )

        measure {
            store.queueUpdate(
                series: [series],
                in: CGSize(width: 390, height: 260),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(store.seriesContexts.count, 1)
        XCTAssertLessThan(store.seriesContexts[0].count, points.count)
    }
}
