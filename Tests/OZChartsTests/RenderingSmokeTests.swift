//
//  RenderingSmokeTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import XCTest
@testable import OZCharts

final class RenderingSmokeTests: XCTestCase {
    @MainActor
    func testLegendCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = ChartLegendView(
            items: [
                ChartLegendItem(title: "Current", color: .blue),
                ChartLegendItem(title: "Target", color: .orange, symbol: .circle)
            ]
        )
        .frame(width: 240, height: 44)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testProductCalloutCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = VStack(alignment: .leading, spacing: 4) {
            Text("High score")
                .font(.caption.bold())
            Text("Star 1: 1.00min")
            Text("Star 2: 3.00min (total)")
        }
        .font(.caption)
        .frame(width: 168, alignment: .leading)
        .chartCalloutStyle(.productLight)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testProductLineChartCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let data = [
            Point2D(x: 1, y: 2),
            Point2D(x: 3, y: 4),
            Point2D(x: 5, y: 3),
            Point2D(x: 8, y: 5),
            Point2D(x: 12, y: 9),
            Point2D(x: 15, y: 4)
        ]

        let view = CartesianChartView(
            series: [
                LineSeries(
                    data: data,
                    color: .purple,
                    lineWidth: 4,
                    interpolation: .monotone,
                    strokeStyle: .gradient([.purple, .pink], startPoint: .leading, endPoint: .trailing),
                    area: AreaStyle(fillStyle: .gradient([Color.purple.opacity(0.28), Color.purple.opacity(0.02)]), baseline: 0)
                )
            ],
            xDomain: .fixed(0...16),
            yDomain: .fixed(0...10),
            theme: .dark,
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .frame(width: 320, height: 220)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testAnnotationRegionsCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = CartesianChartView(
            series: [
                LineSeries(
                    data: [
                        Point2D(x: 0, y: 100),
                        Point2D(x: 1, y: 140),
                        Point2D(x: 2, y: 120)
                    ],
                    color: .white
                )
            ],
            xDomain: .fixed(0...2),
            yDomain: .fixed(50...250),
            theme: .dark,
            xRangeAnnotations: [
                XRangeAnnotation(xRange: 0.25...0.75, color: .gray, opacity: 0.18)
            ],
            xyRangeAnnotations: [
                XYRangeAnnotation(xRange: 1...1.75, yRange: 180...250, color: .yellow, opacity: 0.10)
            ],
            rangeAnnotations: [
                RangeAnnotation(yRange: 70...180, color: .green, opacity: 0.12)
            ],
            verticalAnnotations: [
                VerticalAnnotation(xValue: 1.5, label: "Now", color: .yellow, lineWidth: 1, dash: [3, 4])
            ],
            horizontalAnnotations: [
                HorizontalAnnotation(yValue: 180, label: "High", color: .orange, lineWidth: 1, dash: [])
            ],
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .frame(width: 320, height: 220)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }

    @MainActor
    func testProductDonutChartCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = OZDonutChart(
            [
                Point2D(x: 0, y: 85.2),
                Point2D(x: 1, y: 11.3),
                Point2D(x: 2, y: 3.5)
            ],
            colors: [.cyan, .purple, .yellow],
            segmentStyles: [
                DonutSegmentStyle(fill: .gradient([.cyan, .blue.opacity(0.75)])),
                DonutSegmentStyle(fill: .gradient([.purple, .pink]), explodedOffset: 10),
                DonutSegmentStyle(fill: .gradient([.yellow, .orange]), explodedOffset: 12)
            ],
            thickness: 38,
            gapAngle: .degrees(9),
            theme: .dark
        )
        .frame(width: 260, height: 220)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }
}
