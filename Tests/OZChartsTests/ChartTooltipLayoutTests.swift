//
//  ChartTooltipLayoutTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartTooltipLayoutTests: XCTestCase {
    func testAnchorUsesAveragePointPosition() {
        let points = [
            ChartPointContext(
                originalPoint: Point2D(x: 1, y: 1),
                position: CGPoint(x: 20, y: 40)
            ),
            ChartPointContext(
                originalPoint: Point2D(x: 2, y: 2),
                position: CGPoint(x: 60, y: 80)
            )
        ]

        let anchor = ChartTooltipLayout.anchor(for: points)

        XCTAssertEqual(anchor?.x, 40)
        XCTAssertEqual(anchor?.y, 60)
    }

    func testAutomaticPlacementPrefersTopWhenThereIsRoom() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 100, y: 100),
            tooltipSize: CGSize(width: 40, height: 20),
            canvasSize: CGSize(width: 200, height: 200),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.position.x, 100)
        XCTAssertEqual(result.position.y, 90)
        XCTAssertEqual(result.attachment, .top)
        XCTAssertFalse(result.wasClamped)
    }

    func testAutomaticPlacementPrefersBottomForUpperHalfAnchors() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 100, y: 56),
            tooltipSize: CGSize(width: 80, height: 40),
            canvasSize: CGSize(width: 240, height: 200),
            placement: .automatic,
            offset: CGPoint(x: 0, y: -12),
            padding: 8
        )

        XCTAssertEqual(result.attachment, .bottom)
        XCTAssertEqual(result.position.y, 88)
        XCTAssertFalse(result.wasClamped)
    }

    func testAutomaticPlacementPrefersTopForLowerHalfAnchors() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 100, y: 144),
            tooltipSize: CGSize(width: 80, height: 40),
            canvasSize: CGSize(width: 240, height: 200),
            placement: .automatic,
            offset: CGPoint(x: 0, y: -12),
            padding: 8
        )

        XCTAssertEqual(result.attachment, .top)
        XCTAssertEqual(result.position.y, 112)
        XCTAssertFalse(result.wasClamped)
    }

    func testAutomaticPlacementUsesTrailingSideNearLeadingEdgeWhenVerticalSidesDoNotFit() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 32, y: 100),
            tooltipSize: CGSize(width: 80, height: 180),
            canvasSize: CGSize(width: 240, height: 200),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .trailing)
    }

    func testAutomaticPlacementUsesLeadingSideNearTrailingEdgeWhenVerticalSidesDoNotFit() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 208, y: 100),
            tooltipSize: CGSize(width: 80, height: 180),
            canvasSize: CGSize(width: 240, height: 200),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .leading)
    }

    func testAutomaticVerticalPlacementClampsCardOnlyWhenLeadingEdgeWouldOverflow() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 40, y: 120),
            tooltipSize: CGSize(width: 100, height: 40),
            canvasSize: CGSize(width: 200, height: 240),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .top)
        XCTAssertGreaterThan(result.position.x, 40)
        XCTAssertEqual(result.position.x, 58, accuracy: 0.001)
        XCTAssertTrue(result.wasClamped)
    }

    func testAutomaticVerticalPlacementClampsCardOnlyWhenTrailingEdgeWouldOverflow() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 160, y: 120),
            tooltipSize: CGSize(width: 100, height: 40),
            canvasSize: CGSize(width: 200, height: 240),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .top)
        XCTAssertLessThan(result.position.x, 160)
        XCTAssertEqual(result.position.x, 142, accuracy: 0.001)
        XCTAssertTrue(result.wasClamped)
    }

    func testPlacementClampsTooltipIntoCanvas() {
        let position = ChartTooltipLayout.position(
            anchor: CGPoint(x: 2, y: 2),
            tooltipSize: CGSize(width: 80, height: 40),
            canvasSize: CGSize(width: 100, height: 100),
            placement: .top,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(position.x, 48)
        XCTAssertEqual(position.y, 28)
    }

    func testPlacementCanAllowHorizontalOverflowOutsidePlotArea() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 20, y: 100),
            tooltipSize: CGSize(width: 200, height: 60),
            canvasSize: CGSize(width: 240, height: 180),
            placement: .top,
            offset: .zero,
            padding: 8,
            overflowAllowance: CGSize(width: 100, height: 0)
        )

        XCTAssertEqual(result.position.x, 20)
        XCTAssertEqual(result.position.y, 70)
        XCTAssertFalse(result.wasClamped)
    }

    func testPlacementCanKeepElementTooltipAnchoredNearRightEdgeWithOverflowAllowance() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 220, y: 100),
            tooltipSize: CGSize(width: 200, height: 60),
            canvasSize: CGSize(width: 240, height: 180),
            placement: .top,
            offset: .zero,
            padding: 8,
            overflowAllowance: CGSize(width: 100, height: 0)
        )

        XCTAssertEqual(result.position.x, 220)
        XCTAssertEqual(result.position.y, 70)
        XCTAssertFalse(result.wasClamped)
    }

    func testResolvedMaxWidthFallsBackToVisibleCanvasWidth() {
        let maxWidth = ChartTooltipLayout.resolvedMaxWidth(
            configuredMaxWidth: nil,
            canvasWidth: 240,
            padding: 8
        )

        XCTAssertEqual(maxWidth, 224)
    }

    func testResolvedMaxWidthCapsConfiguredWidthToVisibleCanvasWidth() {
        let maxWidth = ChartTooltipLayout.resolvedMaxWidth(
            configuredMaxWidth: 300,
            canvasWidth: 240,
            padding: 8
        )

        XCTAssertEqual(maxWidth, 224)
    }

    func testAutomaticPlacementCanMoveHorizontallyWithOverflowAllowance() {
        let leadingResult = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 24, y: 120),
            tooltipSize: CGSize(width: 200, height: 70),
            canvasSize: CGSize(width: 260, height: 220),
            placement: .automatic,
            offset: CGPoint(x: 0, y: -18),
            padding: 8,
            overflowAllowance: CGSize(width: 100, height: 0)
        )
        let trailingResult = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 118, y: 120),
            tooltipSize: CGSize(width: 200, height: 70),
            canvasSize: CGSize(width: 260, height: 220),
            placement: .automatic,
            offset: CGPoint(x: 0, y: -18),
            padding: 8,
            overflowAllowance: CGSize(width: 100, height: 0)
        )

        XCTAssertEqual(leadingResult.attachment, .top)
        XCTAssertEqual(trailingResult.attachment, .top)
        XCTAssertGreaterThan(trailingResult.position.x, leadingResult.position.x)
        XCTAssertEqual(leadingResult.position.x, 24, accuracy: 0.001)
        XCTAssertEqual(trailingResult.position.x, 118, accuracy: 0.001)
        XCTAssertFalse(leadingResult.wasClamped)
        XCTAssertFalse(trailingResult.wasClamped)
    }

    func testAutomaticPlacementPrefersBottomWhenTopHasNoRoom() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 100, y: 12),
            tooltipSize: CGSize(width: 70, height: 50),
            canvasSize: CGSize(width: 200, height: 100),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .bottom)
        XCTAssertFalse(result.wasClamped)
    }

    func testAutomaticPlacementCanShiftVerticalCandidateIntoCanvasNearCorner() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 180, y: 12),
            tooltipSize: CGSize(width: 70, height: 50),
            canvasSize: CGSize(width: 200, height: 100),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .bottom)
        XCTAssertTrue(result.wasClamped)
    }

    func testFixedPlacementCanKeepWideTooltipInsideCanvas() {
        let position = ChartTooltipLayout.position(
            anchor: CGPoint(x: 0, y: 0),
            tooltipSize: CGSize(width: 188, height: 92),
            canvasSize: CGSize(width: 260, height: 240),
            placement: .fixed(CGPoint(x: 142, y: 100)),
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(position.x, 142)
        XCTAssertEqual(position.y, 100)
    }
}
