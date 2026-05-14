//
//  AnyChartSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class AnyChartSeriesTests: XCTestCase {
    func testTypeErasurePreservesSeriesMetadataAndData() {
        let points = [Point2D(x: 1, y: 2), Point2D(x: 3, y: 4)]
        let line = LineSeries(data: points, color: .blue, label: "Actual", animation: .fade(), zIndex: 7)

        let erased = line.eraseToAnyChartSeries()

        XCTAssertEqual(erased.id, line.id)
        XCTAssertEqual(erased.data, points)
        XCTAssertEqual(erased.zIndex, 7)
        XCTAssertEqual(erased.legendItem?.title, "Actual")
        XCTAssertEqual(erased.legendItem?.symbol, .line)
        XCTAssertTrue(erased.usesAnimatableOverlay)
        if case .fade = erased.animation.kind {
            return
        }
        XCTFail("Expected erased series to preserve fade animation")
    }

    func testSeriesWithoutLabelDoNotCreateLegendItems() {
        let points = [Point2D(x: 0, y: 10), Point2D(x: 1, y: 20)]
        let line = LineSeries(data: points, color: .blue)

        XCTAssertNil(line.legendItem)
    }

    func testSeriesInitializersAcceptStableIDs() {
        let id = UUID()
        let points = [Point2D(x: 0, y: 10), Point2D(x: 1, y: 20)]

        XCTAssertEqual(LineSeries(data: points, id: id, color: .blue).id, id)
        XCTAssertEqual(AreaSeries(data: points, id: id, color: .blue).id, id)
        XCTAssertEqual(BarSeries(data: points, id: id).id, id)
        XCTAssertEqual(ScatterSeries(data: points, id: id).id, id)
        XCTAssertEqual(DonutSeries(data: points, id: id, colors: [.blue]).id, id)
    }

    func testStaticSeriesDoNotOptIntoAnimatableOverlayByDefault() {
        let points = [Point2D(x: 0, y: 10), Point2D(x: 1, y: 20)]
        let donut = DonutSeries(data: points, colors: [.blue, .green])

        let erased = donut.eraseToAnyChartSeries()

        XCTAssertFalse(erased.usesAnimatableOverlay)
    }
}
