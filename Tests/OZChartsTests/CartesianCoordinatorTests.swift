//
//  CartesianCoordinatorTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class CartesianCoordinatorTests: XCTestCase {
    func testCalculateLayoutMapsPointsIntoCanvasCoordinates() {
        var coordinator = CartesianCoordinator<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...100)
        )
        let points = [Point2D(x: 5, y: 25)]

        let contexts = coordinator.calculateLayout(
            for: points,
            in: CGSize(width: 200, height: 100)
        )

        XCTAssertEqual(contexts.count, 1)
        XCTAssertEqual(contexts[0].position.x, 100, accuracy: 0.0001)
        XCTAssertEqual(contexts[0].position.y, 75, accuracy: 0.0001)
        XCTAssertEqual(contexts[0].scaleX(2.5), 50, accuracy: 0.0001)
        XCTAssertEqual(contexts[0].scaleY(50), 50, accuracy: 0.0001)
    }

    func testValueInvertsScreenCoordinatesBackToDomainValues() {
        var coordinator = CartesianCoordinator<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...100)
        )

        let value = coordinator.value(
            at: CGPoint(x: 50, y: 25),
            in: CGSize(width: 100, height: 100)
        )

        XCTAssertEqual(value.x, 5, accuracy: 0.0001)
        XCTAssertEqual(value.y, 75, accuracy: 0.0001)
    }

    func testNearestPointUsesEuclideanDistance() {
        let contexts = [
            ChartPointContext(originalPoint: Point2D(x: 0, y: 0), position: CGPoint(x: 0, y: 0)),
            ChartPointContext(originalPoint: Point2D(x: 10, y: 10), position: CGPoint(x: 10, y: 10))
        ]
        let coordinator = CartesianCoordinator<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )

        let nearest = coordinator.nearestPoint(
            to: CGPoint(x: 8, y: 9),
            from: contexts
        )

        XCTAssertEqual(nearest?.originalPoint.x, 10)
        XCTAssertEqual(nearest?.originalPoint.y, 10)
    }
}
