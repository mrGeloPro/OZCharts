//
//  ChartStoreTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import SwiftUI
import XCTest

final class ChartStoreTests: XCTestCase {
    private enum StackGroup: Hashable {
        case star1
        case star2
    }

    @MainActor
    func testQueueUpdateCoalescesUntilIntervalElapses() async {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
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
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
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
    func testQueueUpdateCanBypassCoalescingForInitialLayout() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
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
    func testRenderContextsCanBeDownsampledWhileInteractionContextsStayComplete() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 1000),
            yScale: LinearScale(domain: 0 ... 100)
        )
        let data = (0 ..< 1000).map { index in
            Point2D(x: Double(index), y: Double(index % 100))
        }
        let series = LineSeries(
            data: data,
            color: .blue,
            downsampling: .automatic(maxPointsPerPixel: 1)
        ).eraseToAnyChartSeries()

        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        XCTAssertEqual(store.seriesContexts[0].count, data.count)
        XCTAssertLessThan(store.renderSeriesContexts[0].count, store.seriesContexts[0].count)
    }

    @MainActor
    func testPanRecalculatesSeriesContextsSynchronously() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        )
        store.canvasSize = CGSize(width: 100, height: 100)
        store.viewport.visibleXDomain = 0 ... 5
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
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
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
    func testAnimatedUpdatePublishesNewRenderContextsBeforeAnimationStarts() async {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 2),
            yScale: LinearScale(domain: 0 ... 20)
        )
        store.canvasSize = CGSize(width: 100, height: 100)
        store.layoutCoalescingIntervalNanoseconds = 0

        let seriesID = UUID()
        let oldData = [
            Point2D(x: 0, y: 2),
            Point2D(x: 1, y: 4),
            Point2D(x: 2, y: 6)
        ]
        let newData = [
            Point2D(x: 0, y: 10),
            Point2D(x: 1, y: 12),
            Point2D(x: 2, y: 14)
        ]

        let oldSeries = LineSeries(
            data: oldData,
            id: seriesID,
            color: .green
        ).eraseToAnyChartSeries()
        store.queueUpdate(
            series: [oldSeries],
            in: store.canvasSize,
            animate: false,
            coalesce: false
        )

        let newSeries = LineSeries(
            data: newData,
            id: seriesID,
            color: .green,
            animation: .draw(.linear(duration: 0.2))
        ).eraseToAnyChartSeries()
        store.queueUpdate(
            series: [newSeries],
            in: store.canvasSize,
            animate: true,
            coalesce: false
        )

        XCTAssertEqual(store.animationProgress, 0, accuracy: 0.0001)
        XCTAssertTrue(store.isAnimationActive)
        XCTAssertEqual(store.renderSeriesContexts.first?.map(\.originalPoint.y), newData.map(\.y))

        try? await Task.sleep(nanoseconds: 8_000_000)

        XCTAssertEqual(store.animationPhase, 1)
        XCTAssertEqual(store.oldRenderSeriesContexts.first?.map(\.originalPoint.y), oldData.map(\.y))
        XCTAssertEqual(store.renderSeriesContexts.first?.map(\.originalPoint.y), newData.map(\.y))
    }

    @MainActor
    func testViewportCanUpdateLogScaleDomains() {
        let store = ChartStore<Point2D, LogScale, LogScale>(
            xScale: LogScale(domain: 1 ... 100),
            yScale: LogScale(domain: 1 ... 100)
        )
        store.activeXScale.range = 0 ... 100
        store.viewport.visibleXDomain = 10 ... 100

        store.applyViewportToScales()

        XCTAssertEqual(store.activeXScale.domain.lowerBound, 10, accuracy: 0.0001)
        XCTAssertEqual(store.activeXScale.domain.upperBound, 100, accuracy: 0.0001)
    }

    @MainActor
    func testStoreAppliesExternalViewportState() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 24),
            yScale: LinearScale(domain: 0 ... 100)
        )

        store.applyViewportState(
            ChartViewportState(visibleXDomain: 4 ... 12, visibleYDomain: 20 ... 60)
        )

        XCTAssertEqual(store.activeXScale.domain.lowerBound, 4, accuracy: 0.0001)
        XCTAssertEqual(store.activeXScale.domain.upperBound, 12, accuracy: 0.0001)
        XCTAssertEqual(store.activeYScale.domain.lowerBound, 20, accuracy: 0.0001)
        XCTAssertEqual(store.activeYScale.domain.upperBound, 60, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain, 4 ... 12)
    }

    @MainActor
    func testStoreProgrammaticZoomUpdatesViewportState() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 24),
            yScale: LinearScale(domain: 0 ... 100)
        )
        store.applyViewportState(ChartViewportState(visibleXDomain: 0 ... 24))

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
            xScale: LinearScale(domain: 0 ... 24),
            yScale: LinearScale(domain: 0 ... 100)
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
    func testLiveTrackingPausesAfterUserScrollsBackAndPreservesViewportOnNewData() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 100),
            yScale: LinearScale(domain: 0 ... 100)
        )
        store.canvasSize = CGSize(width: 100, height: 100)

        let initialSeries = LineSeries(
            data: [Point2D(x: 80, y: 40), Point2D(x: 100, y: 70)],
            color: .blue
        ).eraseToAnyChartSeries()

        store.handleDataChange(
            series: [initialSeries],
            isLiveTrackingEnabled: true,
            liveTrackingMode: .followLatest(),
            initialViewport: .xWindow(length: 20, anchor: .trailing)
        )

        store.handleGestureEvent(
            .panChanged(translation: CGSize(width: 50, height: 0)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: false,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: false,
            minZoomScale: 0.1,
            hitboxRadius: 20,
            liveTrackingMode: .followLatest(),
            series: [initialSeries]
        )
        store.handleGestureEvent(
            .panEnded,
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: false,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: false,
            minZoomScale: 0.1,
            hitboxRadius: 20,
            liveTrackingMode: .followLatest(),
            series: [initialSeries]
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 70, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 90, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.liveTrackingStatus, .pausedByUser)

        store.updateBaseScales(
            xScale: LinearScale(domain: 0 ... 120),
            yScale: LinearScale(domain: 0 ... 100)
        )

        let nextSeries = LineSeries(
            data: [Point2D(x: 80, y: 42), Point2D(x: 120, y: 74)],
            color: .green
        ).eraseToAnyChartSeries()

        store.handleDataChange(
            series: [nextSeries],
            isLiveTrackingEnabled: true,
            liveTrackingMode: .followLatest(),
            initialViewport: .xWindow(length: 20, anchor: .trailing)
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 70, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 90, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.liveTrackingStatus, .pausedByUser)
    }

    @MainActor
    func testJumpToLatestViewportCommandResumesLiveTracking() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 120),
            yScale: LinearScale(domain: 0 ... 100)
        )
        store.applyViewportState(
            ChartViewportState(
                visibleXDomain: 70 ... 90,
                liveTrackingStatus: .pausedByUser
            )
        )

        store.applyViewportState(.jumpToLatest)

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 120, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.liveTrackingStatus, .followingLatest)
    }

    @MainActor
    func testExternalViewportStatePausesLiveTrackingWhenSetAwayFromLatest() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 120),
            yScale: LinearScale(domain: 0 ... 100)
        )

        store.applyViewportState(
            ChartViewportState(visibleXDomain: 40 ... 60),
            liveTrackingMode: .followLatest()
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 40, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 60, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.liveTrackingStatus, .pausedByUser)
    }

    @MainActor
    func testPausedLiveTrackingCanPreserveTrailingOffsetOnNewData() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 100),
            yScale: LinearScale(domain: 0 ... 100)
        )
        store.canvasSize = CGSize(width: 100, height: 100)

        let initialSeries = LineSeries(
            data: [Point2D(x: 80, y: 40), Point2D(x: 100, y: 70)],
            color: .blue
        ).eraseToAnyChartSeries()

        let mode = ChartLiveTrackingMode.followLatest(pausedBehavior: .preserveTrailingOffset)

        store.handleDataChange(
            series: [initialSeries],
            isLiveTrackingEnabled: true,
            liveTrackingMode: mode,
            initialViewport: .xWindow(length: 20, anchor: .trailing)
        )

        store.handleGestureEvent(
            .panChanged(translation: CGSize(width: 50, height: 0)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: false,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: false,
            minZoomScale: 0.1,
            hitboxRadius: 20,
            liveTrackingMode: mode,
            series: [initialSeries]
        )
        store.handleGestureEvent(
            .panEnded,
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: false,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: false,
            minZoomScale: 0.1,
            hitboxRadius: 20,
            liveTrackingMode: mode,
            series: [initialSeries]
        )

        store.updateBaseScales(
            xScale: LinearScale(domain: 0 ... 120),
            yScale: LinearScale(domain: 0 ... 100)
        )

        let nextSeries = LineSeries(
            data: [Point2D(x: 80, y: 42), Point2D(x: 120, y: 74)],
            color: .green
        ).eraseToAnyChartSeries()

        store.handleDataChange(
            series: [nextSeries],
            isLiveTrackingEnabled: true,
            liveTrackingMode: mode,
            initialViewport: .xWindow(length: 20, anchor: .trailing)
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 90, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 110, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.liveTrackingStatus, .pausedByUser)
    }

    @MainActor
    func testTrimmedLiveDataClampsPausedViewportWithoutJumpingToLatest() {
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 100),
            yScale: LinearScale(domain: 0 ... 100)
        )
        store.applyViewportState(
            ChartViewportState(
                visibleXDomain: 10 ... 30,
                liveTrackingStatus: .pausedByUser
            )
        )

        store.updateBaseScales(
            xScale: LinearScale(domain: 20 ... 120),
            yScale: LinearScale(domain: 0 ... 100)
        )

        let nextSeries = LineSeries(
            data: [Point2D(x: 20, y: 40), Point2D(x: 120, y: 70)],
            color: .green
        ).eraseToAnyChartSeries()

        store.handleDataChange(
            series: [nextSeries],
            isLiveTrackingEnabled: true,
            liveTrackingMode: .followLatest(),
            initialViewport: .xWindow(length: 20, anchor: .trailing)
        )

        XCTAssertEqual(store.viewportState.visibleXDomain?.lowerBound ?? -1, 20, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.visibleXDomain?.upperBound ?? -1, 40, accuracy: 0.0001)
        XCTAssertEqual(store.viewportState.liveTrackingStatus, .pausedByUser)
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
    func testSelectionStateIncludesSelectedPointPayloads() {
        let firstPointID = UUID()
        let secondPointID = UUID()
        let firstSeries = LineSeries(
            data: [
                Point2D(id: firstPointID, x: 5, y: 5)
            ],
            color: .blue,
            zIndex: 0
        ).eraseToAnyChartSeries()
        let secondSeries = LineSeries(
            data: [
                Point2D(id: secondPointID, x: 5, y: 7)
            ],
            color: .green,
            zIndex: 1
        ).eraseToAnyChartSeries()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        )
        store.queueUpdate(
            series: [firstSeries, secondSeries],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        store.applySelectionState(ChartSelectionState(selectedX: 5))

        let state = store.selectionState
        XCTAssertEqual(state.selectedX, 5)
        XCTAssertEqual(state.selectedPoints.count, 2)
        XCTAssertEqual(state.selectedPoints.map(\.pointID), [firstPointID, secondPointID])
        XCTAssertEqual(state.selectedPoints.map(\.seriesID), [firstSeries.id, secondSeries.id])
        XCTAssertEqual(state.selectedPoints.map(\.seriesIndex), [0, 1])
    }

    @MainActor
    func testSelectionStateRestoresSelectionByPointIDs() {
        let pointID = UUID()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        )
        let series = LineSeries(
            data: [
                Point2D(id: pointID, x: 4, y: 6),
                Point2D(x: 7, y: 2)
            ],
            color: .blue
        ).eraseToAnyChartSeries()
        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        store.applySelectionState(
            ChartSelectionState(
                selectedPoints: [
                    ChartSelectedPoint(pointID: pointID, seriesID: series.id, seriesIndex: 0, x: 4, y: 6)
                ]
            )
        )

        XCTAssertEqual(store.highlightedPoints.count, 1)
        XCTAssertEqual(store.highlightedPoints.first?.originalPoint.id, pointID)
        XCTAssertEqual(store.selectionState.selectedPoints.first?.y, 6)
    }

    @MainActor
    func testBarSelectionUsesElementPayloadBeforePointSelection() {
        let pointID = UUID()
        let series = BarSeries(
            data: [Point2D(id: pointID, x: 5, y: 6)],
            color: .blue,
            label: "Height",
            barWidth: 20
        ).eraseToAnyChartSeries()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        )
        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        store.handleGestureEvent(
            .highlight(location: CGPoint(x: 50, y: 70)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: 1,
            selectionMode: .none,
            series: [series]
        )

        XCTAssertTrue(store.highlightedPoints.isEmpty)
        XCTAssertEqual(store.selectedElements.count, 1)
        XCTAssertEqual(store.selectedElementContexts.count, 1)
        XCTAssertEqual(store.selectedElements.first?.kind, .bar)
        XCTAssertEqual(store.selectedElements.first?.pointID, pointID)
        XCTAssertEqual(store.selectedElements.first?.value, 6)
        XCTAssertEqual(store.selectionState.selectedElements.first?.label, "Height")
    }

    @MainActor
    func testDonutSelectionUsesSegmentHitShape() {
        let firstID = UUID()
        let secondID = UUID()
        let series = DonutSeries(
            data: [
                Point2D(id: firstID, x: 0, y: 50),
                Point2D(id: secondID, x: 1, y: 50)
            ],
            colors: [.blue, .green],
            segmentLabelMapper: { point in point.id == firstID ? "Basic" : "Bonus" },
            thickness: 20,
            gapAngle: .degrees(0),
            startAngle: .degrees(0)
        ).eraseToAnyChartSeries()
        let store = ChartStore<Point2D, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 1),
            yScale: LinearScale(domain: 0 ... 100)
        )
        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        let selected = store.selectElements(near: CGPoint(x: 50, y: 88))

        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.first?.kind, .donutSegment)
        XCTAssertEqual(selected.first?.pointID, firstID)
        XCTAssertEqual(selected.first?.label, "Basic")
        XCTAssertEqual(selected.first?.value, 50)
    }

    @MainActor
    func testStackedBarSelectionCanRestoreByElementID() {
        let firstID = UUID()
        let secondID = UUID()
        let series = StackedBarSeries(
            data: [
                GroupedPoint2D(id: firstID, x: 20, y: 1, group: StackGroup.star1),
                GroupedPoint2D(id: secondID, x: 30, y: 1, group: StackGroup.star2)
            ],
            stackOrder: [.star1, .star2],
            colorMapper: { _ in .blue },
            groupLabel: { group in group == .star1 ? "Star 1" : "Star 2" },
            barHeight: 20,
            segmentGap: 0
        ).eraseToAnyChartSeries()
        let store = ChartStore<GroupedPoint2D<StackGroup>, LinearScale, LinearScale>(
            xScale: LinearScale(domain: 0 ... 100),
            yScale: LinearScale(domain: 0 ... 2)
        )
        store.queueUpdate(
            series: [series],
            in: CGSize(width: 100, height: 100),
            animate: false,
            coalesce: false
        )

        let selected = store.selectElements(near: CGPoint(x: 30, y: 50))

        XCTAssertEqual(selected.count, 1)
        XCTAssertEqual(selected.first?.kind, .stackedBarSegment)
        XCTAssertEqual(selected.first?.pointID, secondID)
        XCTAssertEqual(selected.first?.label, "Star 2")

        store.applySelectionState(ChartSelectionState(selectedElements: selected))

        XCTAssertEqual(store.selectedElements.first?.pointID, secondID)
        XCTAssertEqual(store.selectedElementContexts.first?.payload.pointID, secondID)
        XCTAssertTrue(store.highlightedPoints.isEmpty)
    }

    @MainActor
    func testEmptyDataClearsStaleInteractiveState() {
        let store = selectionStore()
        store.applySelectionState(ChartSelectionState(selectedX: 5))
        XCTAssertFalse(store.seriesContexts.isEmpty)
        XCTAssertFalse(store.highlightedPoints.isEmpty)

        store.handleDataChange(
            series: [],
            isLiveTrackingEnabled: false
        )

        XCTAssertTrue(store.seriesContexts.isEmpty)
        XCTAssertTrue(store.oldSeriesContexts.isEmpty)
        XCTAssertTrue(store.highlightedPoints.isEmpty)
        XCTAssertTrue(store.violinBackgrounds.isEmpty)
        XCTAssertEqual(store.animationProgress, 1)
        XCTAssertFalse(store.isAnimationActive)
        XCTAssertEqual(store.selectionState, .none)
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
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
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
