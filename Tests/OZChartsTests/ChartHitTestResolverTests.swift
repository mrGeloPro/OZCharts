//
//  ChartHitTestResolverTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartHitTestResolverTests: XCTestCase {
    func testElementHitTestingPrefersHighestZIndex() {
        let low = ChartSelectedElement(
            elementID: UUID(),
            kind: .bar,
            position: CGPoint(x: 20, y: 20),
            bounds: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        let high = ChartSelectedElement(
            elementID: UUID(),
            kind: .donutSegment,
            position: CGPoint(x: 20, y: 20),
            bounds: CGRect(x: 0, y: 0, width: 40, height: 40)
        )

        let selected = ChartHitTestResolver.elements(
            near: CGPoint(x: 20, y: 20),
            contexts: [
                ChartElementContext(payload: low, hitShape: .rect(low.bounds), zIndex: 0),
                ChartElementContext(payload: high, hitShape: .rect(high.bounds), zIndex: 5)
            ]
        )

        XCTAssertEqual(selected.map(\.elementID), [high.elementID])
    }

    func testPointHitTestingCanSelectNearestX() {
        var cycleIDs: [UUID] = []
        var cycleIndex = 0
        let first = ChartPointContext(
            originalPoint: Point2D(x: 1, y: 10),
            position: CGPoint(x: 10, y: 20)
        )
        let second = ChartPointContext(
            originalPoint: Point2D(x: 2, y: 20),
            position: CGPoint(x: 30, y: 60)
        )

        let selected = ChartHitTestResolver.points(
            near: CGPoint(x: 28, y: 1),
            contexts: [first, second],
            radius: 4,
            mode: .nearestX,
            overlappingSelectionMode: .all,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        )

        XCTAssertEqual(selected.map(\.originalPoint.x), [2])
    }
}
