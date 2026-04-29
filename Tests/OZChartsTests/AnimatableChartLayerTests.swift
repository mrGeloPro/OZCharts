//
//  AnimatableChartLayerTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class AnimatableChartLayerTests: XCTestCase {
    func testInterpolatedPointsClampProgressAndReuseLastPointForUnevenCounts() {
        let old = [CGPoint(x: 0, y: 0)]
        let new = [CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 30)]

        let halfway = AnimatableChartLayer.interpolatedPoints(old: old, new: new, progress: 0.5)

        XCTAssertEqual(halfway.count, 2)
        XCTAssertEqual(halfway[0].x, 5, accuracy: 0.0001)
        XCTAssertEqual(halfway[0].y, 5, accuracy: 0.0001)
        XCTAssertEqual(halfway[1].x, 10, accuracy: 0.0001)
        XCTAssertEqual(halfway[1].y, 15, accuracy: 0.0001)

        let overrun = AnimatableChartLayer.interpolatedPoints(old: old, new: new, progress: 2)
        XCTAssertEqual(overrun[0], new[0])
        XCTAssertEqual(overrun[1], new[1])
    }

    func testDrawClipMaxXClampsProgress() {
        XCTAssertEqual(
            AnimatableChartLayer.drawClipMaxX(firstX: 10, lastX: 50, progress: -1),
            10,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            AnimatableChartLayer.drawClipMaxX(firstX: 10, lastX: 50, progress: 0.25),
            20,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            AnimatableChartLayer.drawClipMaxX(firstX: 10, lastX: 50, progress: 2),
            50,
            accuracy: 0.0001
        )
    }
}
