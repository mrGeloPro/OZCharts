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

    func testDescriptorPrefersSelectedElementFormatter() {
        let descriptor = ChartAccessibilityDescriptor<Point2D>(
            label: "Score chart",
            summary: "Score summary",
            selectedValueFormatter: { _ in "Point value" },
            selectedElementFormatter: { elements in
                elements.first?.label.map { "Segment \($0)" }
            }
        )

        let value = descriptor.value(
            for: [],
            selectedElements: [
                ChartSelectedElement(
                    elementID: UUID(),
                    kind: .donutSegment,
                    label: "Basic",
                    value: 85.2,
                    position: .zero,
                    bounds: .zero
                )
            ]
        )

        XCTAssertEqual(value, "Segment Basic")
    }
}
