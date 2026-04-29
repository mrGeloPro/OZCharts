//
//  StackedBarSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class StackedBarSeriesTests: XCTestCase {
    private enum Group: Hashable {
        case first
        case second
    }

    func testSegmentLayoutsFollowStackOrderAndAccumulateWidths() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.second, .first],
            colorMapper: { _ in .blue },
            barHeight: 10,
            cornerRadius: 0,
            segmentGap: 2
        )
        let contexts = [
            context(x: 2, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let layouts = series.segmentLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 2)
        XCTAssertEqual(layouts[0].group, .second)
        XCTAssertEqual(layouts[0].rect.origin.x, 0, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.origin.y, 25, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.width, 28, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.height, 10, accuracy: 0.0001)

        XCTAssertEqual(layouts[1].group, .first)
        XCTAssertEqual(layouts[1].rect.origin.x, 30, accuracy: 0.0001)
        XCTAssertEqual(layouts[1].rect.width, 18, accuracy: 0.0001)
    }

    func testSegmentLayoutsSkipMissingGroupsAndZeroWidthSegments() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first, .second],
            colorMapper: { _ in .blue }
        )
        let contexts = [
            context(x: 0, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let layouts = series.segmentLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 1)
        XCTAssertEqual(layouts[0].group, .second)
    }

    private func context(
        x: Double,
        y: Double,
        group: Group,
        screenY: CGFloat
    ) -> ChartPointContext<GroupedPoint2D<Group>> {
        ChartPointContext(
            originalPoint: GroupedPoint2D(x: x, y: y, group: group),
            position: CGPoint(x: x * 10, y: screenY),
            scaleX: { CGFloat($0 * 10) },
            scaleY: { CGFloat($0) }
        )
    }
}
