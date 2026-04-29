//
//  CartesianChartViewModifierTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class CartesianChartViewModifierTests: XCTestCase {
    func testGestureModifierUpdatesOnlyProvidedOptions() {
        let view = makeChart()
            .chartGestures(
                horizontalScroll: false,
                verticalZoom: false,
                minZoomScale: 0.25
            )

        XCTAssertFalse(view.isHorizontalScrollEnabled)
        XCTAssertTrue(view.isHorizontalZoomEnabled)
        XCTAssertTrue(view.isVerticalScrollEnabled)
        XCTAssertFalse(view.isVerticalZoomEnabled)
        XCTAssertEqual(view.minZoomScale, 0.25)
    }

    func testSelectionModifierUpdatesModeHitboxAndCallback() {
        var callbackWasCalled = false
        let view = makeChart()
            .chartSelection(
                .nearestX,
                behavior: .tapAndDrag,
                overlapping: .cycle,
                hitboxRadius: 32,
                clearsOnEnd: false
            )
            .chartAnnotationSelection(
                hitboxRadius: 40,
                overlapping: .all
            ) { _ in
                callbackWasCalled = true
            }

        XCTAssertEqual(view.selectionMode, .nearestX)
        XCTAssertEqual(view.selectionBehavior, .tapAndDrag)
        XCTAssertEqual(view.overlappingSelectionMode, .cycle)
        XCTAssertEqual(view.hitboxRadius, 32)
        XCTAssertFalse(view.clearsSelectionOnGestureEnd)
        XCTAssertTrue(view.isAnnotationSelectionEnabled)
        XCTAssertEqual(view.annotationHitboxRadius, 40)
        XCTAssertEqual(view.annotationOverlappingSelectionMode, .all)

        view.onAnnotationSelectionChanged([])
        XCTAssertTrue(callbackWasCalled)
    }

    func testAnnotationTooltipModifierInstallsBuilder() {
        let view = makeChart().chartAnnotationTooltip { annotations in
            Text("\(annotations.count)")
        }

        XCTAssertNotNil(view.annotationTooltipContent)
    }

    func testVisualModifiersUpdateChartOptions() {
        let view = makeChart()
            .chartCrosshair(.both())
            .chartTooltipOffset(x: 4, y: -12)
            .chartTooltipPlacement(.trailing, padding: 14)
            .chartLiveTracking()
            .chartInitialViewport(xWindow: 8, anchor: .trailing)
            .chartViewport(.constant(ChartViewportState(visibleXDomain: 0...8)))
            .chartSelectionState(.constant(ChartSelectionState(selectedX: 4)))
            .chartZoomControls(step: 1.5)
            .chartLegend(.trailing, spacing: 8)
            .chartCanvasRenderOrder([.coreChart, .grid])

        XCTAssertEqual(view.crosshairStyle.mode, .both)
        XCTAssertEqual(view.tooltipOffset, CGPoint(x: 4, y: -12))
        XCTAssertEqual(view.tooltipPlacement, .trailing)
        XCTAssertEqual(view.tooltipPadding, 14)
        XCTAssertTrue(view.isLiveTrackingEnabled)
        XCTAssertEqual(view.initialViewport, .xWindow(length: 8, anchor: .trailing))
        XCTAssertEqual(view.viewportBinding?.wrappedValue.visibleXDomain, 0...8)
        XCTAssertEqual(view.selectionStateBinding?.wrappedValue.selectedX, 4)
        XCTAssertTrue(view.showsZoomControls)
        XCTAssertEqual(view.zoomControlStep, 1.5)
        XCTAssertEqual(view.legendPosition, .trailing)
        XCTAssertEqual(view.legendSpacing, 8)
        XCTAssertEqual(view.canvasRenderOrder, [.coreChart, .grid])
    }

    func testCustomLegendModifierInstallsBuilder() {
        let view = makeChart().chartLegend(.bottom) { items in
            Text("\(items.count)")
        }

        XCTAssertNotNil(view.customLegendContent)
    }

    func testAccessibilityModifierInstallsDescriptor() {
        let view = makeChart().chartAccessibility(label: "Sales", summary: "Monthly sales")

        XCTAssertEqual(view.accessibilityDescriptor?.label, "Sales")
        XCTAssertEqual(view.accessibilityDescriptor?.summary, "Monthly sales")
    }

    func testEmptyStateModifierInstallsEmptyStateBuilder() {
        let view = makeChart().chartEmptyState {
            Text("No data")
        }

        XCTAssertNotNil(view.emptyState?())
    }

    private func makeChart() -> CartesianChartView<Point2D, LinearScale, LinearScale, EmptyView> {
        CartesianChartView(
            series: [
                LineSeries(data: [Point2D(x: 1, y: 2)], color: .blue)
            ],
            xScale: LinearScale(domain: 0...10),
            yScale: LinearScale(domain: 0...10)
        ) { _ in
            EmptyView()
        }
    }
}
