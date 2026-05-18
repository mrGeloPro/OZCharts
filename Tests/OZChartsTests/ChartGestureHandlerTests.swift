//
//  ChartGestureHandlerTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

@testable import OZCharts
import XCTest

final class ChartGestureHandlerTests: XCTestCase {
    func testHorizontalOnlyPanIgnoresMostlyVerticalScroll() {
        var config = ChartGestureConfig()
        config.isHorizontalScrollEnabled = true
        config.isVerticalScrollEnabled = false

        XCTAssertTrue(config.allowsPan(for: CGSize(width: 24, height: 8)))
        XCTAssertFalse(config.allowsPan(for: CGSize(width: 8, height: 24)))
    }

    func testVerticalOnlyPanIgnoresMostlyHorizontalScroll() {
        var config = ChartGestureConfig()
        config.isHorizontalScrollEnabled = false
        config.isVerticalScrollEnabled = true

        XCTAssertFalse(config.allowsPan(for: CGSize(width: 24, height: 8)))
        XCTAssertTrue(config.allowsPan(for: CGSize(width: 8, height: 24)))
    }

    func testDisabledPanRejectsAllDirections() {
        var config = ChartGestureConfig()
        config.isHorizontalScrollEnabled = false
        config.isVerticalScrollEnabled = false

        XCTAssertFalse(config.allowsPan(for: CGSize(width: 24, height: 8)))
        XCTAssertFalse(config.allowsPan(for: CGSize(width: 8, height: 24)))
    }
}
