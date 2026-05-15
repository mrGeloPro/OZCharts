//
//  ChartHitTestResolverTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import XCTest

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
        XCTAssertEqual(selected.first?.interactionPosition, CGPoint(x: 20, y: 20))
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

    func testPointInteractionIndexSelectsRadiusMatchesInOriginalOrder() {
        let first = ChartPointContext(
            originalPoint: Point2D(x: 1, y: 10),
            position: CGPoint(x: 20, y: 20)
        )
        let second = ChartPointContext(
            originalPoint: Point2D(x: 2, y: 20),
            position: CGPoint(x: 10, y: 20)
        )
        let third = ChartPointContext(
            originalPoint: Point2D(x: 3, y: 30),
            position: CGPoint(x: 100, y: 20)
        )
        let index = ChartPointInteractionIndex(contexts: [first, second, third])

        let selected = index.pointsInRadius(
            near: CGPoint(x: 15, y: 20),
            radius: 8
        )

        XCTAssertEqual(selected.map(\.originalPoint.x), [1, 2])
    }

    func testPointInteractionIndexFindsExactNearestPoint() {
        let farXButNearY = ChartPointContext(
            originalPoint: Point2D(x: 1, y: 10),
            position: CGPoint(x: 90, y: 50)
        )
        let nearXButFarY = ChartPointContext(
            originalPoint: Point2D(x: 2, y: 20),
            position: CGPoint(x: 51, y: 200)
        )
        let exactNearest = ChartPointContext(
            originalPoint: Point2D(x: 3, y: 30),
            position: CGPoint(x: 52, y: 52)
        )
        let index = ChartPointInteractionIndex(
            contexts: [farXButNearY, nearXButFarY, exactNearest]
        )

        let selected = index.nearestPoint(near: CGPoint(x: 50, y: 50))

        XCTAssertEqual(selected?.originalPoint.x, 3)
    }

    func testPointInteractionIndexRadiusUsesTwoDimensionalCells() {
        let sameXOutsideRadius = ChartPointContext(
            originalPoint: Point2D(x: 1, y: 10),
            position: CGPoint(x: 10, y: 80)
        )
        let nearby = ChartPointContext(
            originalPoint: Point2D(x: 2, y: 20),
            position: CGPoint(x: 14, y: 18)
        )
        let negativeCellNearby = ChartPointContext(
            originalPoint: Point2D(x: 3, y: 30),
            position: CGPoint(x: -6, y: -4)
        )
        let index = ChartPointInteractionIndex(
            contexts: [sameXOutsideRadius, nearby, negativeCellNearby]
        )

        let selected = index.pointsInRadius(
            near: CGPoint(x: 0, y: 0),
            radius: 24
        )

        XCTAssertEqual(selected.map(\.originalPoint.x), [2, 3])
    }

    func testPointInteractionIndexNearestPointUsesSpatialGridExactly() {
        let nearXFarY = ChartPointContext(
            originalPoint: Point2D(x: 1, y: 10),
            position: CGPoint(x: 49, y: 200)
        )
        let farXNearY = ChartPointContext(
            originalPoint: Point2D(x: 2, y: 20),
            position: CGPoint(x: 75, y: 52)
        )
        let closest = ChartPointContext(
            originalPoint: Point2D(x: 3, y: 30),
            position: CGPoint(x: 61, y: 56)
        )
        let index = ChartPointInteractionIndex(
            contexts: [nearXFarY, farXNearY, closest]
        )

        let selected = index.nearestPoint(near: CGPoint(x: 50, y: 50))

        XCTAssertEqual(selected?.originalPoint.x, 3)
    }

    func testPointInteractionIndexSelectsNearestOriginalXValue() {
        let first = ChartPointContext(
            originalPoint: Point2D(x: 4, y: 10),
            position: CGPoint(x: 40, y: 20)
        )
        let second = ChartPointContext(
            originalPoint: Point2D(x: 6, y: 20),
            position: CGPoint(x: 60, y: 20)
        )
        let paired = ChartPointContext(
            originalPoint: Point2D(x: 6, y: 30),
            position: CGPoint(x: 60, y: 80)
        )
        let index = ChartPointInteractionIndex(contexts: [first, second, paired])

        let selected = index.nearestOriginalXValue(5.7)

        XCTAssertEqual(selected.map(\.originalPoint.y), [20, 30])
    }
}
