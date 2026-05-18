//
//  ChartViewportTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartViewportTests: XCTestCase {
    func testInitializeVisibleDomainsDoesNotStartDragging() {
        var viewport = ChartViewport()

        viewport.initializeVisibleDomains(
            globalXDomain: 10...30,
            globalYDomain: 0...100,
            initialViewport: nil,
            scrollX: true,
            scrollY: true
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 10, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 30, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.upperBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertNil(viewport.dragStartXDomain)
        XCTAssertNil(viewport.dragStartYDomain)
        XCTAssertFalse(viewport.isDragging)
    }

    func testInitialViewportUsesExplicitRangeAndClampsToGlobalDomain() {
        var viewport = ChartViewport()

        viewport.initializeVisibleDomains(
            globalXDomain: 0...24,
            globalYDomain: 0...100,
            initialViewport: ChartInitialViewport(x: 20...32),
            scrollX: true,
            scrollY: true
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 12, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 24, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.upperBound ?? -1, 100, accuracy: 0.0001)
    }

    func testInitialViewportWindowResolvesFromAnchor() {
        var leadingViewport = ChartViewport()
        var trailingViewport = ChartViewport()
        var centeredViewport = ChartViewport()

        leadingViewport.initializeVisibleDomains(
            globalXDomain: 0...24,
            globalYDomain: 0...100,
            initialViewport: .xWindow(length: 8, anchor: .leading),
            scrollX: true,
            scrollY: true
        )
        trailingViewport.initializeVisibleDomains(
            globalXDomain: 0...24,
            globalYDomain: 0...100,
            initialViewport: .xWindow(length: 8, anchor: .trailing),
            scrollX: true,
            scrollY: true
        )
        centeredViewport.initializeVisibleDomains(
            globalXDomain: 0...24,
            globalYDomain: 0...100,
            initialViewport: .xWindow(length: 8, anchor: .value(6)),
            scrollX: true,
            scrollY: true
        )

        XCTAssertEqual(leadingViewport.visibleXDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(leadingViewport.visibleXDomain?.upperBound ?? -1, 8, accuracy: 0.0001)
        XCTAssertEqual(trailingViewport.visibleXDomain?.lowerBound ?? -1, 16, accuracy: 0.0001)
        XCTAssertEqual(trailingViewport.visibleXDomain?.upperBound ?? -1, 24, accuracy: 0.0001)
        XCTAssertEqual(centeredViewport.visibleXDomain?.lowerBound ?? -1, 2, accuracy: 0.0001)
        XCTAssertEqual(centeredViewport.visibleXDomain?.upperBound ?? -1, 10, accuracy: 0.0001)
    }

    func testInitialViewportAppliesExplicitRangeWhenScrollingIsDisabled() {
        var viewport = ChartViewport()

        viewport.initializeVisibleDomains(
            globalXDomain: 0...24,
            globalYDomain: 0...100,
            initialViewport: ChartInitialViewport(x: 0...8),
            scrollX: false,
            scrollY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 8, accuracy: 0.0001)
        XCTAssertNil(viewport.visibleYDomain)
    }

    func testPanMovesVisibleDomainAndClearsDragStateOnEnd() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 20...60

        let didPan = viewport.applyPan(
            translationWidth: -25,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )

        XCTAssertTrue(didPan)
        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 30, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 70, accuracy: 0.0001)

        viewport.endPan()

        XCTAssertNil(viewport.dragStartXDomain)
        XCTAssertFalse(viewport.isDragging)
    }

    func testPanAtFullDomainIsNoOp() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 0...24
        viewport.visibleYDomain = 50...250

        let didPan = viewport.applyPan(
            translationWidth: 30,
            translationHeight: -40,
            canvasSize: CGSize(width: 300, height: 220),
            globalXDomain: 0...24,
            globalYDomain: 50...250,
            scrollX: true,
            scrollY: true
        )

        XCTAssertFalse(didPan)
        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 24, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.lowerBound ?? -1, 50, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.upperBound ?? -1, 250, accuracy: 0.0001)
        XCTAssertNil(viewport.dragStartXDomain)
        XCTAssertNil(viewport.dragStartYDomain)
    }

    func testPanOnlyMovesZoomedAxisWhenOtherAxisIsAtFullDomain() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 0...24
        viewport.visibleYDomain = 90...180

        let didPan = viewport.applyPan(
            translationWidth: 30,
            translationHeight: -22,
            canvasSize: CGSize(width: 300, height: 220),
            globalXDomain: 0...24,
            globalYDomain: 50...250,
            scrollX: true,
            scrollY: true
        )

        XCTAssertTrue(didPan)
        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 24, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.lowerBound ?? -1, 81, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.upperBound ?? -1, 171, accuracy: 0.0001)
        XCTAssertNil(viewport.dragStartXDomain)
        XCTAssertNotNil(viewport.dragStartYDomain)
    }

    func testPanClampsToGlobalDomain() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 10...50

        viewport.applyPan(
            translationWidth: 100,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 40, accuracy: 0.0001)
    }

    func testZoomNarrowsAroundDomainCenter() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 20...80

        viewport.applyZoom(
            magnification: 2,
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 35, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 65, accuracy: 0.0001)
    }

    func testPanIsIgnoredWhileZoomingAndResumesAfterZoomEnds() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 20...80

        viewport.applyZoom(
            magnification: 2,
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: false
        )

        let zoomedDomain = viewport.visibleXDomain
        XCTAssertTrue(viewport.isZooming)

        viewport.applyPan(
            translationWidth: -25,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, zoomedDomain?.lowerBound ?? -2, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, zoomedDomain?.upperBound ?? -2, accuracy: 0.0001)

        viewport.endZoom()

        viewport.applyPan(
            translationWidth: -25,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )

        XCTAssertGreaterThan(viewport.visibleXDomain?.lowerBound ?? -1, zoomedDomain?.lowerBound ?? 100)
        XCTAssertFalse(viewport.isZooming)
    }

    func testZoomHonorsMinimumScale() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 40...60

        viewport.applyZoom(
            magnification: 100,
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            minZoomScale: 0.2,
            zoomX: true,
            zoomY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 40, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 60, accuracy: 0.0001)
    }

    func testZoomIgnoresInvalidMagnification() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 20...80

        viewport.applyZoom(
            magnification: 0,
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 20, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 80, accuracy: 0.0001)
    }

    func testProgrammaticZoomNarrowsVisibleDomain() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 0...24

        viewport.applyProgrammaticZoom(
            magnification: 3,
            globalXDomain: 0...24,
            globalYDomain: 0...100,
            minZoomScale: 0.1,
            zoomX: true,
            zoomY: false
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 8, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 16, accuracy: 0.0001)
        XCTAssertFalse(viewport.isDragging)
        XCTAssertFalse(viewport.isZooming)
    }

    func testApplyViewportStateClampsDomains() {
        var viewport = ChartViewport()

        viewport.applyState(
            ChartViewportState(visibleXDomain: 20...40, visibleYDomain: -50...50),
            globalXDomain: 0...24,
            globalYDomain: 0...100
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 4, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 24, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleYDomain?.upperBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertEqual(viewport.state.visibleXDomain, viewport.visibleXDomain)
        XCTAssertEqual(viewport.state.visibleYDomain, viewport.visibleYDomain)
    }

    func testLiveTrackingKeepsWindowPinnedUnlessDragging() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 80...100

        viewport.applyLiveTracking(
            mode: .followLatest(),
            newGlobalMax: 120,
            currentWindowWidth: 20,
            globalXDomain: 0...120
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 120, accuracy: 0.0001)

        viewport.isDragging = true
        viewport.applyLiveTracking(
            mode: .followLatest(),
            newGlobalMax: 140,
            currentWindowWidth: 20,
            globalXDomain: 0...140
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 120, accuracy: 0.0001)
    }

    func testLiveTrackingClampsWindowToGlobalDomain() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 0...50

        viewport.applyLiveTracking(
            mode: .followLatest(),
            newGlobalMax: 30,
            currentWindowWidth: 50,
            globalXDomain: 0...30
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 30, accuracy: 0.0001)
    }

    func testLiveTrackingPausesAfterUserScrollsAwayFromLatest() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 80...100

        viewport.applyPan(
            translationWidth: 50,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )
        viewport.endPan(liveTrackingMode: .followLatest(), globalXDomain: 0...100)

        XCTAssertEqual(viewport.liveTrackingStatus, .pausedByUser)
        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 70, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 90, accuracy: 0.0001)

        viewport.applyLiveTracking(
            mode: .followLatest(),
            newGlobalMax: 120,
            currentWindowWidth: 20,
            globalXDomain: 0...120
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 70, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 90, accuracy: 0.0001)
        XCTAssertEqual(viewport.liveTrackingStatus, .pausedByUser)
    }

    func testLiveTrackingContinuesWhenUserEndsAtTrailingEdge() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 80...100

        viewport.applyPan(
            translationWidth: -50,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )
        viewport.endPan(liveTrackingMode: .followLatest(), globalXDomain: 0...100)

        XCTAssertEqual(viewport.liveTrackingStatus, .followingLatest)

        viewport.applyLiveTracking(
            mode: .followLatest(),
            newGlobalMax: 120,
            currentWindowWidth: 20,
            globalXDomain: 0...120
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 120, accuracy: 0.0001)
    }

    func testJumpToLatestResumesPausedLiveTracking() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 30...50
        viewport.liveTrackingStatus = .pausedByUser

        viewport.jumpToLatest(
            currentWindowWidth: 20,
            globalXDomain: 0...120
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 100, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 120, accuracy: 0.0001)
        XCTAssertEqual(viewport.liveTrackingStatus, .followingLatest)
    }

    func testPausedLiveTrackingCanPreserveTrailingOffset() {
        var viewport = ChartViewport()
        viewport.visibleXDomain = 80...100

        viewport.applyPan(
            translationWidth: 50,
            translationHeight: 0,
            canvasSize: CGSize(width: 100, height: 100),
            globalXDomain: 0...100,
            globalYDomain: 0...100,
            scrollX: true,
            scrollY: false
        )
        viewport.endPan(
            liveTrackingMode: .followLatest(pausedBehavior: .preserveTrailingOffset),
            globalXDomain: 0...100
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 70, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 90, accuracy: 0.0001)
        XCTAssertEqual(viewport.liveTrackingStatus, .pausedByUser)

        viewport.applyLiveTracking(
            mode: .followLatest(pausedBehavior: .preserveTrailingOffset),
            newGlobalMax: 120,
            currentWindowWidth: 20,
            globalXDomain: 0...120
        )

        XCTAssertEqual(viewport.visibleXDomain?.lowerBound ?? -1, 90, accuracy: 0.0001)
        XCTAssertEqual(viewport.visibleXDomain?.upperBound ?? -1, 110, accuracy: 0.0001)
        XCTAssertEqual(viewport.liveTrackingStatus, .pausedByUser)
    }
}
