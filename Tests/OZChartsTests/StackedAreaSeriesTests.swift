//
//  StackedAreaSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class StackedAreaSeriesTests: XCTestCase {
    private enum Group: Hashable {
        case basic
        case bonus
    }

    func testStackedAreaLayersAccumulateValuesByStackOrder() {
        let series = StackedAreaSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.basic, .bonus],
            colorMapper: { _ in .blue }
        )

        let contexts = [
            context(x: 0, y: 10, group: .basic),
            context(x: 1, y: 20, group: .basic),
            context(x: 0, y: 3, group: .bonus),
            context(x: 1, y: 5, group: .bonus)
        ]

        let layers = series.stackedAreaLayers(contexts: contexts)

        XCTAssertEqual(layers.count, 2)
        XCTAssertEqual(layers[0].group, .basic)
        XCTAssertEqual(layers[0].upper.map(\.y), [10, 20])
        XCTAssertEqual(layers[1].group, .bonus)
        XCTAssertEqual(layers[1].lower.map(\.y), [10, 20])
        XCTAssertEqual(layers[1].upper.map(\.y), [13, 25])
    }

    func testStackedAreaLegendUsesStackOrder() {
        let series = StackedAreaSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.bonus, .basic],
            colorMapper: { _ in .blue },
            groupLabel: { $0 == .basic ? "Basic" : "Bonus" }
        )

        XCTAssertEqual(series.legendItems.map(\.title), ["Bonus", "Basic"])
    }

    func testStackedAreaAggregatesDuplicateGroupXValues() {
        let series = StackedAreaSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.basic, .bonus],
            colorMapper: { _ in .blue }
        )

        let contexts = [
            context(x: 0, y: 4, group: .basic),
            context(x: 0, y: 6, group: .basic),
            context(x: 0, y: 3, group: .bonus)
        ]

        let layers = series.stackedAreaLayers(contexts: contexts)

        XCTAssertEqual(layers.count, 2)
        XCTAssertEqual(layers[0].upper.map(\.y), [10])
        XCTAssertEqual(layers[1].upper.map(\.y), [13])
    }

    private func context(
        x: Double,
        y: Double,
        group: Group
    ) -> ChartPointContext<GroupedPoint2D<Group>> {
        ChartPointContext(
            originalPoint: GroupedPoint2D(x: x, y: y, group: group),
            position: CGPoint(x: x, y: y),
            scaleX: { CGFloat($0) },
            scaleY: { CGFloat($0) }
        )
    }
}
