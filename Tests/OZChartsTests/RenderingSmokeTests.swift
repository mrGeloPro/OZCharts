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
    func testProductDonutChartCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = CartesianChartView(
            series: [
                DonutSeries(
                    data: [
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
                    gapAngle: .degrees(9)
                )
            ],
            xDomain: .fixed(0...1),
            yDomain: .fixed(0...1),
            theme: .dark,
            xAxes: [.hidden()],
            yAxes: [.hidden()],
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .frame(width: 260, height: 220)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }
}
