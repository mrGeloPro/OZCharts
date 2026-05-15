//
//  ChartAnchoredCalloutLayoutTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartAnchoredCalloutLayoutTests: XCTestCase {
    func testVerticalCalloutPlacesBoxBelowAnchorAndOffsetsArrowToTapPoint() {
        let result = ChartAnchoredCalloutLayout.vertical(
            anchor: CGPoint(x: 80, y: 40),
            calloutSize: CGSize(width: 100, height: 60),
            containerSize: CGSize(width: 240, height: 200),
            preferredSide: .below,
            padding: 8,
            arrowInset: 16,
            arrowOutset: 6,
            sideShiftRatio: 1
        )

        XCTAssertEqual(result.side, .below)
        XCTAssertEqual(result.center.x, 114)
        XCTAssertEqual(result.center.y, 76)
        XCTAssertEqual(result.arrowXOffset, -34)
        XCTAssertFalse(result.wasClamped)
    }

    func testVerticalCalloutFlipsWhenPreferredSideDoesNotFit() {
        let result = ChartAnchoredCalloutLayout.vertical(
            anchor: CGPoint(x: 120, y: 24),
            calloutSize: CGSize(width: 120, height: 64),
            containerSize: CGSize(width: 240, height: 180),
            preferredSide: .above,
            padding: 8,
            arrowInset: 18,
            arrowOutset: 6
        )

        XCTAssertEqual(result.side, .below)
        XCTAssertEqual(result.center.y, 62)
        XCTAssertFalse(result.wasClamped)
    }

    func testVerticalCalloutClampsInsideContainerWhenNoSideFits() {
        let result = ChartAnchoredCalloutLayout.vertical(
            anchor: CGPoint(x: 230, y: 90),
            calloutSize: CGSize(width: 160, height: 170),
            containerSize: CGSize(width: 240, height: 180),
            preferredSide: .below,
            padding: 8,
            arrowInset: 20,
            arrowOutset: 6
        )

        XCTAssertEqual(result.center.x, 152)
        XCTAssertEqual(result.center.y, 93)
        XCTAssertEqual(result.arrowXOffset, 60)
        XCTAssertTrue(result.wasClamped)
    }
}
