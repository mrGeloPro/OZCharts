//
//  ChartCrosshairStyleTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartCrosshairStyleTests: XCTestCase {
    func testHiddenStyleDisablesCrosshair() {
        XCTAssertEqual(ChartCrosshairStyle.hidden.mode, .none)
        XCTAssertFalse(ChartCrosshairStyle.hidden.isVisible)
    }

    func testFactoryStylesUseRequestedModes() {
        XCTAssertEqual(ChartCrosshairStyle.vertical().mode, .vertical)
        XCTAssertEqual(ChartCrosshairStyle.horizontal().mode, .horizontal)
        XCTAssertEqual(ChartCrosshairStyle.both().mode, .both)
    }

    func testCrosshairAnchorUsesAverageSelectedPosition() {
        let points = [
            ChartPointContext(
                originalPoint: Point2D(x: 1, y: 2),
                position: CGPoint(x: 10, y: 40)
            ),
            ChartPointContext(
                originalPoint: Point2D(x: 1, y: 4),
                position: CGPoint(x: 20, y: 20)
            )
        ]

        let anchor = AnnotationRenderer.crosshairAnchor(for: points)

        XCTAssertEqual(anchor?.x, 15)
        XCTAssertEqual(anchor?.y, 30)
    }
}
