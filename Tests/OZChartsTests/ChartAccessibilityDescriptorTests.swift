//
//  ChartAccessibilityDescriptorTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import XCTest
@testable import OZCharts

final class ChartAccessibilityDescriptorTests: XCTestCase {
    func testDescriptorUsesSummaryWhenNothingIsSelected() {
        let descriptor = ChartAccessibilityDescriptor<Point2D>(
            label: "Revenue chart",
            summary: "Revenue by month"
        )

        XCTAssertEqual(descriptor.value(for: []), "Revenue by month")
    }

    func testDescriptorUsesSelectedValueFormatter() {
        let point = Point2D(x: 2, y: 42)
        let descriptor = ChartAccessibilityDescriptor<Point2D>(
            label: "Revenue chart",
            selectedValueFormatter: { points in
                points.first.map { "Value \(Int($0.originalPoint.y))" }
            }
        )

        let value = descriptor.value(
            for: [
                ChartPointContext(originalPoint: point, position: .zero)
            ]
        )

        XCTAssertEqual(value, "Value 42")
    }
}
