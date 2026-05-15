//
//  PerformanceBenchmarkTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation
import SwiftUI
import XCTest
@testable import OZCharts

final class PerformanceBenchmarkTests: XCTestCase {
    @MainActor
    func testLargeLineLayoutPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let points = (0..<20_000).map { index in
            Point2D(
                x: Double(index),
                y: 50 + sin(Double(index) / 18) * 20 + cos(Double(index) / 71) * 8
            )
        }
        let series = LineSeries(
            data: points,
            color: .cyan,
            downsampling: .automatic(maxPointsPerPixel: 1)
        ).eraseToAnyChartSeries()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...20_000),
            yScale: LinearScale(domain: 0...100)
        )

        measure {
            store.queueUpdate(
                series: [series],
                in: CGSize(width: 390, height: 260),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(store.seriesContexts.count, 1)
        XCTAssertEqual(store.seriesContexts[0].count, points.count)
    }

    @MainActor
    func testStackedAreaLayoutPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let groups = PerformanceGroup.allCases
        let points = (0..<2_500).flatMap { index in
            groups.map { group in
                GroupedPoint2D(
                    x: Double(index),
                    y: 5 + Double(group.weight) * 2 + sin(Double(index) / Double(group.weight * 19)) * 4,
                    group: group
                )
            }
        }
        let series = StackedAreaSeries(
            data: points,
            stackOrder: groups,
            colorMapper: { $0.color },
            interpolation: .step
        ).eraseToAnyChartSeries()
        let store = ChartStore<GroupedPoint2D<PerformanceGroup>, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...2_500),
            yScale: LinearScale(domain: 0...80)
        )

        measure {
            store.queueUpdate(
                series: [series],
                in: CGSize(width: 390, height: 260),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(store.seriesContexts.count, 1)
        XCTAssertEqual(store.seriesContexts[0].count, points.count)
    }

    @MainActor
    func testStackedBarSelectionElementPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let groups = PerformanceGroup.allCases
        let points = (0..<250).flatMap { row in
            groups.map { group in
                GroupedPoint2D(
                    x: Double((row % 7) + group.weight * 4),
                    y: Double(row),
                    group: group
                )
            }
        }
        let series = StackedBarSeries(
            data: points,
            stackOrder: groups,
            colorMapper: { $0.color },
            groupLabel: { $0.rawValue },
            valueLabelStyle: ChartValueLabelStyle(position: .outside),
            barHeight: 12,
            segmentGap: 1
        ).eraseToAnyChartSeries()
        let store = ChartStore<GroupedPoint2D<PerformanceGroup>, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...120),
            yScale: LinearScale(domain: 0...250)
        )

        measure {
            store.queueUpdate(
                series: [series],
                in: CGSize(width: 430, height: 700),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(store.selectableElements.count, points.count)
    }

    @MainActor
    func testDenseHitTestingPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        var contexts: [ChartPointContext<Point2D>] = []
        contexts.reserveCapacity(60_000)
        for index in 0..<60_000 {
            let point = Point2D(
                x: Double(index),
                y: 50 + sin(Double(index) / 31) * 24
            )
            let position = CGPoint(
                x: Double(index % 390),
                y: 130 + sin(Double(index) / 17) * 90
            )
            contexts.append(
                ChartPointContext(
                    originalPoint: point,
                    position: position
                )
            )
        }
        let locations = stride(from: 0, to: 390, by: 13).map {
            CGPoint(x: CGFloat($0), y: 130)
        }
        var selectedCount = 0

        measure {
            var cycleIDs: [UUID] = []
            var cycleIndex = 0
            var localCount = 0
            for location in locations {
                localCount += ChartHitTestResolver.points(
                    near: location,
                    contexts: contexts,
                    radius: 16,
                    mode: .nearestX,
                    overlappingSelectionMode: .all,
                    cycleIDs: &cycleIDs,
                    cycleIndex: &cycleIndex
                ).count
            }
            selectedCount = localCount
        }

        XCTAssertGreaterThan(selectedCount, 0)
    }

    @MainActor
    func testLiveAppendAndTrimLayoutPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...900),
            yScale: LinearScale(domain: 0...120)
        )
        store.canvasSize = CGSize(width: 390, height: 260)
        store.layoutCoalescingIntervalNanoseconds = 0

        measure {
            var points: [Point2D] = []
            for batch in 0..<60 {
                let start = batch * 20
                points.append(contentsOf: (0..<20).map { offset in
                    let x = Double(start + offset)
                    return Point2D(x: x, y: 50 + sin(x / 12) * 18 + cos(x / 43) * 9)
                })
                points = Array(points.suffix(900))
                let latest = points.last?.x ?? 0
                let historyStart = max(0, latest - 900)
                let series = LineSeries(
                    data: points,
                    color: .cyan,
                    downsampling: .automatic(maxPointsPerPixel: 1)
                ).eraseToAnyChartSeries()

                store.updateBaseScales(
                    xScale: LinearScale(domain: historyStart...max(900, latest)),
                    yScale: LinearScale(domain: 0...120)
                )
                store.handleDataChange(
                    series: [series],
                    isLiveTrackingEnabled: true,
                    liveTrackingMode: .followLatest(pausedBehavior: .preserveTrailingOffset),
                    initialViewport: .xWindow(length: 120, anchor: .trailing)
                )
                store.queueUpdate(
                    series: [series],
                    in: store.canvasSize,
                    animate: false,
                    coalesce: false
                )
            }
        }

        XCTAssertEqual(store.viewport.liveTrackingStatus, .followingLatest)
        XCTAssertFalse(store.seriesContexts.isEmpty)
    }

    @MainActor
    func testDonutElementHitTestingPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let points = (0..<120).map { index in
            Point2D(x: Double(index), y: Double((index % 9) + 1))
        }
        let series = DonutSeries(
            data: points,
            colors: [.cyan, .purple, .yellow, .orange],
            thickness: 32,
            gapAngle: .degrees(1)
        ).eraseToAnyChartSeries()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...120),
            yScale: LinearScale(domain: 0...10)
        )
        store.queueUpdate(
            series: [series],
            in: CGSize(width: 300, height: 300),
            animate: false,
            coalesce: false
        )
        let locations = store.selectableElements.map(\.payload.position)
        var hitCount = 0

        measure {
            var localHits = 0
            for location in locations {
                localHits += store.selectElements(near: location).count
            }
            hitCount = localHits
        }

        XCTAssertGreaterThan(hitCount, 0)
    }

    private func requirePerformanceBenchmarks() throws {
        guard ProcessInfo.processInfo.environment["RUN_OZCHARTS_PERFORMANCE_TESTS"] == "1" else {
            throw XCTSkip("Set RUN_OZCHARTS_PERFORMANCE_TESTS=1 to run performance benchmarks.")
        }
    }
}

private enum PerformanceGroup: String, CaseIterable, Hashable {
    case basic
    case bonus
    case streak
    case recovery

    var weight: Int {
        switch self {
        case .basic: return 1
        case .bonus: return 2
        case .streak: return 3
        case .recovery: return 4
        }
    }

    var color: Color {
        switch self {
        case .basic: return .cyan
        case .bonus: return .purple
        case .streak: return .yellow
        case .recovery: return .orange
        }
    }
}
