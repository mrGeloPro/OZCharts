//
//  LineSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class LineSeriesTests: XCTestCase {
    func testLinearInterpolationKeepsOriginalPoints() {
        let series = LineSeries<Point2D>(data: [], color: .blue, interpolation: .linear)
        let points = [
            CGPoint(x: 0, y: 10),
            CGPoint(x: 20, y: 30),
            CGPoint(x: 40, y: 15)
        ]

        XCTAssertEqual(series.pathPoints(from: points), points)
    }

    func testStepInterpolationAddsHorizontalTransitionPoints() {
        let series = LineSeries<Point2D>(data: [], color: .blue, interpolation: .step)
        let points = [
            CGPoint(x: 0, y: 10),
            CGPoint(x: 20, y: 30),
            CGPoint(x: 40, y: 15)
        ]

        XCTAssertEqual(
            series.pathPoints(from: points),
            [
                CGPoint(x: 0, y: 10),
                CGPoint(x: 20, y: 10),
                CGPoint(x: 20, y: 30),
                CGPoint(x: 40, y: 30),
                CGPoint(x: 40, y: 15)
            ]
        )
    }

    func testLTTBDownsamplingKeepsFirstAndLastContexts() {
        let data = (0..<20).map { Point2D(x: Double($0), y: Double(($0 % 3) * 10)) }
        let contexts = data.map {
            ChartPointContext(
                originalPoint: $0,
                position: CGPoint(x: $0.x, y: $0.y)
            )
        }
        let series = LineSeries(
            data: data,
            color: .blue,
            downsampling: .lttb(threshold: 6)
        )

        let sampled = series.renderContexts(from: contexts, in: CGSize(width: 100, height: 100))

        XCTAssertEqual(sampled.count, 6)
        XCTAssertEqual(sampled.first?.originalPoint.x, 0)
        XCTAssertEqual(sampled.last?.originalPoint.x, 19)
    }

    func testAutomaticDownsamplingUsesCanvasWidthThreshold() {
        let data = (0..<10).map { Point2D(x: Double($0), y: Double($0)) }
        let contexts = data.map {
            ChartPointContext(originalPoint: $0, position: CGPoint(x: $0.x, y: $0.y))
        }
        let series = LineSeries(
            data: data,
            color: .blue,
            downsampling: .automatic(maxPointsPerPixel: 1)
        )

        let sampled = series.renderContexts(from: contexts, in: CGSize(width: 5, height: 100))

        XCTAssertEqual(sampled.count, 5)
    }
}
