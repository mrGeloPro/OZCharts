//
//  ChartStoreTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class ChartStoreTests: XCTestCase {
    @MainActor
    func testQueueUpdateCoalescesUntilIntervalElapses() async {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )
        store.layoutCoalescingIntervalNanoseconds = 80_000_000
        let series = LineSeries(data: [Point2D(x: 1, y: 1)], color: .blue)
            .eraseToAnyChartSeries()

        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false
        )

        try? await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertTrue(store.seriesContexts.isEmpty)

        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(store.seriesContexts.count, 1)
        XCTAssertEqual(store.seriesContexts[0].count, 1)
    }

    @MainActor
    func testQueueUpdateKeepsOnlyLatestPendingLayout() async {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )
        store.layoutCoalescingIntervalNanoseconds = 80_000_000

        let firstSeries = LineSeries(
            data: [Point2D(x: 1, y: 1)],
            color: .blue
        ).eraseToAnyChartSeries()
        let latestSeries = LineSeries(
            data: [Point2D(x: 1, y: 1), Point2D(x: 2, y: 2), Point2D(x: 3, y: 3)],
            color: .blue
        ).eraseToAnyChartSeries()

        store.queueUpdate(
            series: [firstSeries],
            in: CGSize(width: 100, height: 100),
            animate: false
        )
        store.queueUpdate(
            series: [latestSeries],
            in: CGSize(width: 100, height: 100),
            animate: false
        )

        try? await Task.sleep(nanoseconds: 120_000_000)

        XCTAssertEqual(store.seriesContexts.count, 1)
        XCTAssertEqual(store.seriesContexts[0].count, 3)
    }

    @MainActor
    func testQueueUpdateCanBypassCoalescingForInitialLayout() async {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )
        store.layoutCoalescingIntervalNanoseconds = 1_000_000_000
        let series = LineSeries(data: [Point2D(x: 4, y: 4)], color: .blue)
            .eraseToAnyChartSeries()

        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        XCTAssertEqual(store.seriesContexts.count, 1)
        XCTAssertEqual(store.seriesContexts[0].count, 1)
    }

    @MainActor
    func testPanRecalculatesSeriesContextsSynchronously() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )
        store.canvasSize = CGSize(width: 100, height: 100)
        store.viewport.visibleXDomain = 0...5
        store.applyViewportToScales()

        let series = LineSeries(data: [Point2D(x: 2.5, y: 5)], color: .blue)
            .eraseToAnyChartSeries()

        store.queueUpdate(
            series: [series],
            in: store.canvasSize,
            animate: false,
            coalesce: false
        )

        XCTAssertEqual(store.seriesContexts[0][0].position.x, 50, accuracy: 0.0001)

        store.handleGestureEvent(
            .panChanged(translation: CGSize(width: -20, height: 0)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: false,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: 20,
            series: [series]
        )

        XCTAssertEqual(store.seriesContexts[0][0].position.x, 30, accuracy: 0.0001)
    }

    @MainActor
    func testGestureUpdateDisablesAnimatableOverlay() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )
        store.canvasSize = CGSize(width: 100, height: 100)
        store.isAnimationActive = true
        store.oldSeriesContexts = [[
            ChartPointContext(
                originalPoint: Point2D(x: 1, y: 1),
                position: CGPoint(x: 10, y: 90),
                scaleX: { $0 * 10 },
                scaleY: { 100 - $0 * 10 }
            )
        ]]

        let series = LineSeries(
            data: [Point2D(x: 2, y: 5)],
            color: .green,
            animation: .morph()
        ).eraseToAnyChartSeries()

        store.queueUpdate(
            series: [series],
            in: store.canvasSize,
            animate: false,
            coalesce: false
        )

        XCTAssertFalse(store.isAnimationActive)
        XCTAssertTrue(store.oldSeriesContexts.isEmpty)
        XCTAssertEqual(store.animationProgress, 1, accuracy: 0.0001)
    }

    @MainActor
    func testViewportCanUpdateLogScaleDomains() {
        let store = ChartStore<Point2D, LogScale, LogScale>(
            xScale: LogScale(domain: 1...100),
            yScale: LogScale(domain: 1...100)
        )
        store.activeXScale.range = 0...100
        store.viewport.visibleXDomain = 10...100

        store.applyViewportToScales()

        XCTAssertEqual(store.activeXScale.domain.lowerBound, 10, accuracy: 0.0001)
        XCTAssertEqual(store.activeXScale.domain.upperBound, 100, accuracy: 0.0001)
    }

    @MainActor
    func testStoreAppliesExternalViewportState() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...24),
            yScale: LinearScale(domain: 0...100)
        )

        store.applyViewportState(
            ChartViewportState(visibleXDomain: 4...12, visibleYDomain: 20...60)
        )

        XCTAssertEqual(store.activeXScale.domain.lowerBound, 4, accuracy: 0.0001)
        XCTAssertEqual(store.activeXScale.domain.upperBound, 12, accuracy: 0.0001)
        XCTAssertEqual(store.activeYScale.domain.lowerBound, 20, accuracy: 0.0001)
        XCTAssertEqual(store.activeYScale.domain.upperBound, 60, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain, 4...12)
    }

    @MainActor
    func testStoreProgrammaticZoomUpdatesViewportState() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...24),
            yScale: LinearScale(domain: 0...100)
        )
        store.applyViewportState(ChartViewportState(visibleXDomain: 0...24))

        store.applyProgrammaticZoom(
            magnification: 3,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: false
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 8, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 16, accuracy: 0.0001)
        XCTAssertEqual(store.activeXScale.domain.lowerBound, 8, accuracy: 0.0001)
        XCTAssertEqual(store.activeXScale.domain.upperBound, 16, accuracy: 0.0001)
    }

    @MainActor
    func testDataRefreshPreservesInteractiveViewportAfterInitialViewport() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...24),
            yScale: LinearScale(domain: 0...100)
        )

        let initialSeries = LineSeries(
            data: [Point2D(x: 16, y: 40), Point2D(x: 24, y: 70)],
            color: .blue
        ).eraseToAnyChartSeries()

        store.handleDataChange(
            series: [initialSeries],
            isLiveTrackingEnabled: false,
            initialViewport: .xWindow(length: 8, anchor: .trailing)
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 16, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 24, accuracy: 0.0001)

        store.applyProgrammaticZoom(
            magnification: 2,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: false
        )

        let zoomedDomain = store.viewportState.visibleXDomain
        XCTAssertEqual(zoomedDomain?.lowerBound ?? -1, 18, accuracy: 0.0001)
        XCTAssertEqual(zoomedDomain?.upperBound ?? -1, 22, accuracy: 0.0001)

        let refreshedSeries = LineSeries(
            data: [Point2D(x: 16, y: 42), Point2D(x: 24, y: 74)],
            color: .green
        ).eraseToAnyChartSeries()

        store.handleDataChange(
            series: [refreshedSeries],
            isLiveTrackingEnabled: false,
            initialViewport: .xWindow(length: 8, anchor: .trailing)
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, zoomedDomain?.lowerBound ?? -2, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, zoomedDomain?.upperBound ?? -2, accuracy: 0.0001)
    }

    @MainActor
    func testSelectionModeNoneReturnsNoPoints() {
        let store = selectionStore()

        let selected = store.selectPoints(
            near: CGPoint(x: 50, y: 50),
            radius: 100,
            mode: .none
        )

        XCTAssertTrue(selected.isEmpty)
    }

    @MainActor
    func testSelectionModePointsInRadiusReturnsOnlyNearbyPoints() {
        let store = selectionStore()

        let selected = store.selectPoints(
            near: CGPoint(x: 50, y: 50),
            radius: 8,
            mode: .pointsInRadius
        )

        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.first?.originalPoint.x, 5)
        XCTAssertEqual(selected.first?.originalPoint.y, 5)
    }

    @MainActor
    func testSelectionModeNearestPointReturnsClosestPoint() {
        let store = selectionStore()

        let selected = store.selectPoints(
            near: CGPoint(x: 47, y: 53),
            radius: 1,
            mode: .nearestPoint
        )

        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.first?.originalPoint.x, 5)
        XCTAssertEqual(selected.first?.originalPoint.y, 5)
    }

    @MainActor
    func testSelectionModeNearestXReturnsAllPointsAtNearestX() {
        let store = selectionStore()

        let selected = store.selectPoints(
            near: CGPoint(x: 52, y: 20),
            radius: 1,
            mode: .nearestX
        )

        XCTAssertEqual(selected.count, 2)
        XCTAssertTrue(selected.allSatisfy { $0.originalPoint.x == 5 })
    }

    @MainActor
    func testSelectionStateSelectsNearestXValue() {
        let store = selectionStore()

        store.applySelectionState(ChartSelectionState(selectedX: 5.2))

        XCTAssertEqual(store.highlightedPoints.count, 2)
        XCTAssertTrue(store.highlightedPoints.allSatisfy { $0.originalPoint.x == 5 })
        XCTAssertEqual(store.selectionState.selectedX, 5)

        store.applySelectionState(.none)

        XCTAssertTrue(store.highlightedPoints.isEmpty)
        XCTAssertNil(store.selectionState.selectedX)
    }

    @MainActor
    func testOverlappingSelectionCycleReturnsOnePointAtATime() {
        let store = selectionStore()

        let first = store.selectPoints(
            near: CGPoint(x: 52, y: 20),
            radius: 1,
            mode: .nearestX,
            overlappingSelectionMode: .cycle
        )
        let second = store.selectPoints(
            near: CGPoint(x: 52, y: 20),
            radius: 1,
            mode: .nearestX,
            overlappingSelectionMode: .cycle
        )
        let third = store.selectPoints(
            near: CGPoint(x: 52, y: 20),
            radius: 1,
            mode: .nearestX,
            overlappingSelectionMode: .cycle
        )

        XCTAssertEqual(first.count, 1)
        XCTAssertEqual(second.count, 1)
        XCTAssertEqual(third.count, 1)
        XCTAssertNotEqual(first.first?.id, second.first?.id)
        XCTAssertEqual(first.first?.id, third.first?.id)
    }

    @MainActor
    func testOverlappingSelectionCycleResetsForDifferentCluster() {
        let store = selectionStore()

        let first = store.selectPoints(
            near: CGPoint(x: 52, y: 20),
            radius: 1,
            mode: .nearestX,
            overlappingSelectionMode: .cycle
        )
        _ = store.selectPoints(
            near: CGPoint(x: 82, y: 20),
            radius: 1,
            mode: .nearestX,
            overlappingSelectionMode: .cycle
        )
        let again = store.selectPoints(
            near: CGPoint(x: 52, y: 20),
            radius: 1,
            mode: .nearestX,
            overlappingSelectionMode: .cycle
        )

        XCTAssertEqual(first.first?.id, again.first?.id)
    }

    @MainActor
    private func selectionStore() -> ChartStore<Point2D, LinearScale, LinearScale> {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        )
        store.queueUpdate(
            series: [
                LineSeries(
                    data: [
                        Point2D(x: 2, y: 1),
                        Point2D(x: 5, y: 5)
                    ],
                    color: .blue
                ).eraseToAnyChartSeries(),
                LineSeries(
                    data: [
                        Point2D(x: 5, y: 7),
                        Point2D(x: 8, y: 2)
                    ],
                    color: .green
                ).eraseToAnyChartSeries()
            ],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )
        return store
    }
}
