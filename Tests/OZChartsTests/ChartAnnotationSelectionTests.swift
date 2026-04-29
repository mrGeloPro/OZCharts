//
//  ChartAnnotationSelectionTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartAnnotationSelectionTests: XCTestCase {
    func testSelectsAnnotationsWithinRadius() {
        var cycle = ChartAnnotationSelectionCycle()
        let annotations = [
            ChartAnnotationContext(
                id: UUID(),
                kind: .point,
                x: 1,
                y: 2,
                position: CGPoint(x: 10, y: 10),
                label: "Near"
            ),
            ChartAnnotationContext(
                id: UUID(),
                kind: .customView,
                x: 3,
                y: 4,
                position: CGPoint(x: 100, y: 100),
                label: "Far"
            )
        ]

        let selected = ChartAnnotationSelectionResolver.select(
            near: CGPoint(x: 12, y: 12),
            contexts: annotations,
            defaultRadius: 8,
            overlappingMode: .all,
            cycle: &cycle
        )

        XCTAssertEqual(selected.map(\.label), ["Near"])
    }

    func testPerAnnotationHitboxOverridesDefaultRadius() {
        var cycle = ChartAnnotationSelectionCycle()
        let annotation = ChartAnnotationContext(
            id: UUID(),
            kind: .point,
            x: 1,
            y: 2,
            position: CGPoint(x: 10, y: 10),
            label: "Wide",
            hitboxRadius: 40
        )

        let selected = ChartAnnotationSelectionResolver.select(
            near: CGPoint(x: 35, y: 10),
            contexts: [annotation],
            defaultRadius: 8,
            overlappingMode: .all,
            cycle: &cycle
        )

        XCTAssertEqual(selected.first?.label, "Wide")
    }

    func testOverlappingAnnotationSelectionCyclesOneItemAtATime() {
        var cycle = ChartAnnotationSelectionCycle()
        let annotations = [
            ChartAnnotationContext(
                id: UUID(),
                kind: .point,
                x: 1,
                y: 2,
                position: CGPoint(x: 10, y: 10),
                label: "First"
            ),
            ChartAnnotationContext(
                id: UUID(),
                kind: .customView,
                x: 1,
                y: 2,
                position: CGPoint(x: 10, y: 10),
                label: "Second"
            )
        ]

        let first = ChartAnnotationSelectionResolver.select(
            near: CGPoint(x: 10, y: 10),
            contexts: annotations,
            defaultRadius: 8,
            overlappingMode: .cycle,
            cycle: &cycle
        )
        let second = ChartAnnotationSelectionResolver.select(
            near: CGPoint(x: 10, y: 10),
            contexts: annotations,
            defaultRadius: 8,
            overlappingMode: .cycle,
            cycle: &cycle
        )

        XCTAssertEqual(first.first?.label, "First")
        XCTAssertEqual(second.first?.label, "Second")
    }
}
