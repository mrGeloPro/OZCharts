//
//  PerformanceBenchmarkTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation
@testable import OZCharts
import SwiftUI
import XCTest

final class PerformanceBenchmarkTests: XCTestCase {
    @MainActor
    func testLargeLineLayoutPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let lineSamples = (0 ..< 20000).map { index in
            Point2D(
                x: Double(index),
                y: 50 + sin(Double(index) / 18) * 20 + cos(Double(index) / 71) * 8
            )
        }
        let lineSeries = LineSeries(
            data: lineSamples,
            color: .cyan,
            downsampling: .automatic(maxPointsPerPixel: 1)
        ).eraseToAnyChartSeries()
        let chartStore = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 20000),
            yScale: LinearScale(domain: 0 ... 100)
        )

        measure {
            chartStore.queueUpdate(
                series: [lineSeries],
                in: CGSize(width: 390, height: 260),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(chartStore.seriesContexts.count, 1)
        XCTAssertEqual(chartStore.seriesContexts[0].count, lineSamples.count)
    }

    @MainActor
    func testStackedAreaLayoutPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let benchmarkGroups = BenchmarkGroup.allCases
        let areaSamples = (0 ..< 2500).flatMap { index in
            benchmarkGroups.map { group in
                GroupedPoint2D(
                    x: Double(index),
                    y: 5 + Double(group.signalWeight) * 2 + sin(Double(index) / Double(group.signalWeight * 19)) * 4,
                    group: group
                )
            }
        }
        let areaSeries = StackedAreaSeries(
            data: areaSamples,
            stackOrder: benchmarkGroups,
            colorMapper: { $0.color },
            interpolation: .step
        ).eraseToAnyChartSeries()
        let chartStore = ChartStore<GroupedPoint2D<BenchmarkGroup>, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 2500),
            yScale: LinearScale(domain: 0 ... 80)
        )

        measure {
            chartStore.queueUpdate(
                series: [areaSeries],
                in: CGSize(width: 390, height: 260),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(chartStore.seriesContexts.count, 1)
        XCTAssertEqual(chartStore.seriesContexts[0].count, areaSamples.count)
    }

    @MainActor
    func testStackedBarSelectionElementPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let benchmarkGroups = BenchmarkGroup.allCases
        let barSegments = (0 ..< 250).flatMap { row in
            benchmarkGroups.map { group in
                GroupedPoint2D(
                    x: Double((row % 7) + group.signalWeight * 4),
                    y: Double(row),
                    group: group
                )
            }
        }
        let barSeries = StackedBarSeries(
            data: barSegments,
            stackOrder: benchmarkGroups,
            colorMapper: { $0.color },
            groupLabel: { $0.rawValue },
            valueLabelStyle: ChartValueLabelStyle(position: .outside),
            barHeight: 12,
            segmentGap: 1
        ).eraseToAnyChartSeries()
        let chartStore = ChartStore<GroupedPoint2D<BenchmarkGroup>, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 120),
            yScale: LinearScale(domain: 0 ... 250)
        )

        measure {
            chartStore.queueUpdate(
                series: [barSeries],
                in: CGSize(width: 430, height: 700),
                animate: false,
                coalesce: false
            )
        }

        XCTAssertEqual(chartStore.selectableElements.count, barSegments.count)
    }

    @MainActor
    func testDenseHitTestingPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        var pointContexts: [ChartPointContext<Point2D>] = []
        pointContexts.reserveCapacity(60000)
        for index in 0 ..< 60000 {
            let point = Point2D(
                x: Double(index),
                y: 50 + sin(Double(index) / 31) * 24
            )
            let position = CGPoint(
                x: Double(index % 390),
                y: 130 + sin(Double(index) / 17) * 90
            )
            pointContexts.append(
                ChartPointContext(
                    originalPoint: point,
                    position: position
                )
            )
        }
        let probeLocations = stride(from: 0, to: 390, by: 13).map {
            CGPoint(x: CGFloat($0), y: 130)
        }
        let pointIndex = ChartPointInteractionIndex(
            contexts: pointContexts,
            canvasSize: CGSize(width: 390, height: 260),
            preferredHitRadius: 16
        )
        var selectedPointCount = 0

        measure {
            var cycleIDs: [UUID] = []
            var cycleIndex = 0
            var selectedInRun = 0
            for location in probeLocations {
                selectedInRun += ChartHitTestResolver.points(
                    near: location,
                    index: pointIndex,
                    radius: 16,
                    mode: .pointsInRadius,
                    overlappingSelectionMode: .all,
                    cycleIDs: &cycleIDs,
                    cycleIndex: &cycleIndex
                ).count
            }
            selectedPointCount = selectedInRun
        }

        XCTAssertGreaterThan(selectedPointCount, 0)
    }

    @MainActor
    func testLiveAppendAndTrimLayoutPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let chartStore = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 900),
            yScale: LinearScale(domain: 0 ... 120)
        )
        chartStore.canvasSize = CGSize(width: 390, height: 260)
        chartStore.layoutCoalescingIntervalNanoseconds = 0

        measure {
            var liveSamples: [Point2D] = []
            for batch in 0 ..< 60 {
                let batchStartIndex = batch * 20
                liveSamples.append(contentsOf: (0 ..< 20).map { offset in
                    let x = Double(batchStartIndex + offset)
                    return Point2D(x: x, y: 50 + sin(x / 12) * 18 + cos(x / 43) * 9)
                })
                liveSamples = Array(liveSamples.suffix(900))
                let latestXValue = liveSamples.last?.x ?? 0
                let historyStart = max(0, latestXValue - 900)
                let liveSeries = LineSeries(
                    data: liveSamples,
                    color: .cyan,
                    downsampling: .automatic(maxPointsPerPixel: 1)
                ).eraseToAnyChartSeries()

                chartStore.updateBaseScales(
                    xScale: LinearScale(domain: historyStart ... max(900, latestXValue)),
                    yScale: LinearScale(domain: 0 ... 120)
                )
                chartStore.handleDataChange(
                    series: [liveSeries],
                    isLiveTrackingEnabled: true,
                    liveTrackingMode: .followLatest(pausedBehavior: .preserveTrailingOffset),
                    initialViewport: .xWindow(length: 120, anchor: .trailing)
                )
                chartStore.queueUpdate(
                    series: [liveSeries],
                    in: chartStore.canvasSize,
                    animate: false,
                    coalesce: false
                )
            }
        }

        XCTAssertEqual(chartStore.viewport.liveTrackingStatus, .followingLatest)
        XCTAssertFalse(chartStore.seriesContexts.isEmpty)
    }

    @MainActor
    func testDonutElementHitTestingPerformanceWhenEnabled() throws {
        try requirePerformanceBenchmarks()

        let donutSegments = (0 ..< 120).map { index in
            Point2D(x: Double(index), y: Double((index % 9) + 1))
        }
        let donutSeries = DonutSeries(
            data: donutSegments,
            colors: [.cyan, .purple, .yellow, .orange],
            thickness: 32,
            gapAngle: .degrees(1)
        ).eraseToAnyChartSeries()
        let chartStore = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 120),
            yScale: LinearScale(domain: 0 ... 10)
        )
        chartStore.queueUpdate(
            series: [donutSeries],
            in: CGSize(width: 300, height: 300),
            animate: false,
            coalesce: false
        )
        let segmentCenters = chartStore.selectableElements.map(\.payload.position)
        var selectedSegmentCount = 0

        measure {
            var selectedInRun = 0
            for location in segmentCenters {
                selectedInRun += chartStore.selectElements(near: location).count
            }
            selectedSegmentCount = selectedInRun
        }

        XCTAssertGreaterThan(selectedSegmentCount, 0)
    }

    private func requirePerformanceBenchmarks() throws {
        guard ProcessInfo.processInfo.environment["RUN_OZCHARTS_PERFORMANCE_TESTS"] == "1" else {
            throw XCTSkip("Set RUN_OZCHARTS_PERFORMANCE_TESTS=1 to run performance benchmarks.")
        }
    }
}

private enum BenchmarkGroup: String, CaseIterable, Hashable {
    case basic
    case bonus
    case streak
    case recovery

    var signalWeight: Int {
        switch self {
        case .basic: 1
        case .bonus: 2
        case .streak: 3
        case .recovery: 4
        }
    }

    var color: Color {
        switch self {
        case .basic: .cyan
        case .bonus: .purple
        case .streak: .yellow
        case .recovery: .orange
        }
    }
}
