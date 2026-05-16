//
//  PolarCoordinatorTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import XCTest
@testable import OZCharts

final class PolarCoordinatorTests: XCTestCase {
    func testDonutSegmentsUseConfiguredStartAngleAndFractions() {
        let segments = PolarCoordinator().calculateDonutSegments(
            from: [25, 75],
            in: CGSize(width: 100, height: 100),
            options: PolarDonutLayoutOptions(
                thickness: 20,
                gapAngle: .degrees(0),
                startAngle: .degrees(0),
                contentInset: 0
            )
        )

        XCTAssertEqual(segments.count, 2)
        XCTAssertEqual(segments[0].fraction, 0.25, accuracy: 0.0001)
        XCTAssertEqual(segments[0].startAngle, 0, accuracy: 0.0001)
        XCTAssertEqual(segments[0].endAngle, Double.pi / 2, accuracy: 0.0001)
        XCTAssertEqual(segments[1].fraction, 0.75, accuracy: 0.0001)
        XCTAssertEqual(segments[1].startAngle, Double.pi / 2, accuracy: 0.0001)
        XCTAssertEqual(segments[1].endAngle, 2 * Double.pi, accuracy: 0.0001)
    }

    func testDonutSegmentsReserveSpaceForExplodedOffsetsAndShadows() {
        let segments = PolarCoordinator().calculateDonutSegments(
            from: [1],
            in: CGSize(width: 100, height: 100),
            options: PolarDonutLayoutOptions(
                thickness: 20,
                gapAngle: .degrees(0),
                startAngle: .degrees(0),
                contentInset: 0,
                explodedOffsets: [10],
                shadowRadii: [5]
            )
        )

        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].center.x, 40, accuracy: 0.0001)
        XCTAssertEqual(segments[0].center.y, 50, accuracy: 0.0001)
        XCTAssertEqual(segments[0].outerRadius, 35, accuracy: 0.0001)
        XCTAssertEqual(segments[0].radius, 25, accuracy: 0.0001)
        XCTAssertEqual(segments[0].innerRadius, 15, accuracy: 0.0001)
    }

    func testDonutSegmentsRejectImpossibleGapConfiguration() {
        let segments = PolarCoordinator().calculateDonutSegments(
            from: [1, 1],
            in: CGSize(width: 100, height: 100),
            options: PolarDonutLayoutOptions(
                thickness: 20,
                gapAngle: .degrees(180),
                contentInset: 0
            )
        )

        XCTAssertTrue(segments.isEmpty)
    }
}
