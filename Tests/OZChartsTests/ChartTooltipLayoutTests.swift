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

    func testAutomaticPlacementChoosesCandidateWithLeastOverflowWhenNoneFits() {
        let result = ChartTooltipLayout.resolve(
            anchor: CGPoint(x: 180, y: 12),
            tooltipSize: CGSize(width: 70, height: 50),
            canvasSize: CGSize(width: 200, height: 100),
            placement: .automatic,
            offset: .zero,
            padding: 8
        )

        XCTAssertEqual(result.attachment, .leading)
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
