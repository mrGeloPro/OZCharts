//
//  ChartSelectionTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import XCTest

final class ChartSelectionTests: XCTestCase {
    func testUnifiedSelectionReportsEmptyState() {
        let selection = ChartSelection<Point2D>.none

        XCTAssertTrue(selection.isEmpty)
        XCTAssertNil(selection.primaryPoint)
        XCTAssertNil(selection.primaryElement)
        XCTAssertNil(selection.primaryAnnotation)
        XCTAssertEqual(selection.state, .none)
    }

    func testUnifiedSelectionKeepsPrimaryValuesAcrossSelectionKinds() {
        let point = ChartPointContext(
            originalPoint: Point2D(x: 1, y: 2),
            position: CGPoint(x: 10, y: 20)
        )
        let element = ChartSelectedElement(
            elementID: UUID(),
            kind: .bar,
            value: 12,
            position: CGPoint(x: 12, y: 22),
            bounds: CGRect(x: 0, y: 0, width: 24, height: 44)
        )
        let annotation = ChartAnnotationContext(
            id: UUID(),
            kind: .point,
            x: 1,
            y: 2,
            position: CGPoint(x: 10, y: 20),
            label: "Event"
        )
        let state = ChartSelectionState(
            selectedX: 1,
            selectedPoints: [
                ChartSelectedPoint(pointID: point.id, x: 1, y: 2)
            ],
            selectedElements: [element]
        )

        let selection = ChartSelection(
            points: [point],
            elements: [element],
            annotations: [annotation],
            state: state
        )

        XCTAssertFalse(selection.isEmpty)
        XCTAssertEqual(selection.primaryPoint?.id, point.id)
        XCTAssertEqual(selection.primaryElement?.elementID, element.elementID)
        XCTAssertEqual(selection.primaryAnnotation?.id, annotation.id)
        XCTAssertEqual(selection.state, state)
    }
}
