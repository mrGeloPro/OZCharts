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
    func testLineSeriesStyleKeepsFillDisabledByDefault() {
        let style = LineSeriesStyle(color: .blue)
        let series = LineSeries<Point2D>(data: [], style: style)

        XCTAssertEqual(series.lineWidth, 2)
        XCTAssertNil(series.area)
    }

    func testLineSeriesStyleMapsFillConfigurationToAreaStyle() {
        let style = LineSeriesStyle(
            color: .orange,
            interpolation: .monotone,
            showsFill: true,
            fillColor: .orange,
            fillOpacity: 0.35,
            fillBaseline: 42
        )
        let series = LineSeries<Point2D>(data: [], style: style)

        XCTAssertEqual(series.interpolation, .monotone)
        XCTAssertNotNil(series.area)
        XCTAssertEqual(series.area?.fillOpacity, 0.35)
        XCTAssertEqual(series.area?.baseline, 42)
    }

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

    func testMonotoneInterpolationBuildsCubicSegmentsBetweenPoints() {
        let series = LineSeries<Point2D>(data: [], color: .blue, interpolation: .monotone)
        let points = [
            CGPoint(x: 0, y: 10),
            CGPoint(x: 30, y: 40),
            CGPoint(x: 60, y: 20)
        ]

        let segments = series.monotoneSegments(from: points)

        XCTAssertEqual(segments.count, 2)
        XCTAssertEqual(segments.first?.end, points[1])
        XCTAssertEqual(segments.last?.end, points[2])
        XCTAssertEqual(segments.first?.control1.x, 10)
        XCTAssertEqual(segments.first?.control2.x, 20)
    }

    func testMonotoneInterpolationFlattensTangentAtDirectionChanges() {
        let series = LineSeries<Point2D>(data: [], color: .blue, interpolation: .monotone)
        let points = [
            CGPoint(x: 0, y: 10),
            CGPoint(x: 20, y: 40),
            CGPoint(x: 40, y: 12)
        ]

        let segments = series.monotoneSegments(from: points)

        XCTAssertEqual(segments[0].control2.y, points[1].y)
        XCTAssertEqual(segments[1].control1.y, points[1].y)
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
