//
//  ChartStoreSelectionDismissalTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import SwiftUI
import XCTest

final class ChartStoreSelectionDismissalTests: XCTestCase {
    @MainActor
    func testPinnedElementSelectionSurvivesEmptyTap() {
        let pointID = UUID()
        let (store, series) = makeSelectableBarStore(pointID: pointID)

        selectBar(in: store, series: series, policy: .pinned)
        store.handleGestureEvent(
            .highlight(location: CGPoint(x: 5, y: 5)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: 1,
            selectionMode: .none,
            selectionDismissalPolicy: .pinned,
            series: [series]
        )

        XCTAssertEqual(store.selectedElements.first?.pointID, pointID)
    }

    @MainActor
    func testDragDismissalClearsSelectionOnPanButNotZoom() {
        let pointID = UUID()
        let (store, series) = makeSelectableBarStore(pointID: pointID)

        selectBar(in: store, series: series, policy: .drag)
        store.handleGestureEvent(
            .zoomChanged(magnification: 1.2),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: 1,
            selectionMode: .none,
            selectionDismissalPolicy: .drag,
            series: [series]
        )

        XCTAssertEqual(store.selectedElements.first?.pointID, pointID)

        store.handleGestureEvent(
            .panChanged(translation: CGSize(width: 12, height: 0)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: 1,
            selectionMode: .none,
            selectionDismissalPolicy: .drag,
            series: [series]
        )

        XCTAssertTrue(store.selectedElements.isEmpty)
    }

    @MainActor
    func testViewportChangeDismissalClearsSelectionOnProgrammaticViewportChange() {
        let pointID = UUID()
        let (store, series) = makeSelectableBarStore(pointID: pointID)

        selectBar(in: store, series: series, policy: .drag)
        store.applyProgrammaticZoom(
            magnification: 1.2,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: true,
            selectionDismissalPolicy: .drag
        )

        XCTAssertEqual(store.selectedElements.first?.pointID, pointID)

        store.applyProgrammaticZoom(
            magnification: 1.2,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: true,
            selectionDismissalPolicy: .viewportChange
        )

        XCTAssertTrue(store.selectedElements.isEmpty)
    }

    @MainActor
    func testScrollSafeNearestSelectionClearsOnPan() {
        let series = LineSeries(
            data: [
                Point2D(x: 0, y: 0),
                Point2D(x: 5, y: 5),
                Point2D(x: 10, y: 10)
            ],
            color: .blue
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
        let options = ChartSelectionOptions.scrollSafeNearestX

        store.handleGestureEvent(
            .highlight(location: CGPoint(x: 50, y: 50)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: options.hitboxRadius,
            selectionMode: options.mode,
            selectionDismissalPolicy: options.dismissalPolicy,
            nearestSelectionPolicy: options.nearestSelectionPolicy,
            series: [series]
        )

        XCTAssertFalse(store.highlightedPoints.isEmpty)

        store.handleGestureEvent(
            .panChanged(translation: CGSize(width: 16, height: 0)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: options.hitboxRadius,
            selectionMode: options.mode,
            selectionDismissalPolicy: options.dismissalPolicy,
            nearestSelectionPolicy: options.nearestSelectionPolicy,
            series: [series]
        )

        XCTAssertTrue(store.highlightedPoints.isEmpty)
        XCTAssertTrue(store.selectedElements.isEmpty)
    }

    @MainActor
    private func makeSelectableBarStore(
        pointID: UUID
    ) -> (ChartStore<Point2D, LinearScale, LinearScale>, AnyChartSeries<Point2D>) {
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
        return (store, series)
    }

    @MainActor
    private func selectBar(
        in store: ChartStore<Point2D, LinearScale, LinearScale>,
        series: AnyChartSeries<Point2D>,
        policy: ChartSelectionDismissalPolicy
    ) {
        store.handleGestureEvent(
            .highlight(location: CGPoint(x: 50, y: 70)),
            isHorizontalScrollEnabled: true,
            isVerticalScrollEnabled: true,
            isHorizontalZoomEnabled: true,
            isVerticalZoomEnabled: true,
            minZoomScale: 0.1,
            hitboxRadius: 1,
            selectionMode: .none,
            selectionDismissalPolicy: policy,
            series: [series]
        )
    }
}
