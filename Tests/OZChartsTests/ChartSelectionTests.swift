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

    func testSelectedElementTooltipInteractionAnchorClampsToElementBounds() {
        let element = ChartSelectedElement(
            elementID: UUID(),
            kind: .stackedBarSegment,
            position: CGPoint(x: 25, y: 20),
            interactionPosition: CGPoint(x: 90, y: -10),
            bounds: CGRect(x: 10, y: 12, width: 30, height: 16)
        )

        XCTAssertEqual(element.tooltipInteractionAnchor.x, 40)
        XCTAssertEqual(element.tooltipInteractionAnchor.y, 12)
    }

    func testTransientElementSelectionClearsAtGestureEnd() {
        XCTAssertEqual(ChartSelectionOptions.transientElement.mode, .none)
        XCTAssertEqual(ChartSelectionOptions.transientElement.behavior, .tap)
        XCTAssertEqual(ChartSelectionOptions.transientElement.overlappingSelectionMode, .all)
        XCTAssertEqual(ChartSelectionOptions.transientElement.hitboxRadius, 24)
        XCTAssertTrue(ChartSelectionOptions.transientElement.dismissalPolicy.contains(.gestureEnd))
    }

    func testSemanticSelectionPresetsDescribeCommonProductBehaviors() {
        XCTAssertTrue(ChartSelectionOptions.transientElement.dismissalPolicy.contains(.gestureEnd))
        XCTAssertEqual(ChartSelectionOptions.persistentElement.dismissalPolicy, .tapOutside)
        XCTAssertEqual(ChartSelectionOptions.pinnedElement.dismissalPolicy, .pinned)
        XCTAssertEqual(ChartSelectionOptions.eventThenNearestPoint, .nearestX)
        XCTAssertEqual(ChartSelectionOptions.scrollSafeNearestX.mode, .nearestX)
        XCTAssertEqual(ChartSelectionOptions.scrollSafeNearestX.behavior, .tapAndDrag)
        XCTAssertEqual(ChartSelectionOptions.scrollSafeNearestX.activation, .onTapEnd)
        XCTAssertEqual(ChartSelectionOptions.scrollSafeNearestX.nearestSelectionPolicy, .withinHitbox)

        XCTAssertEqual(ChartSelectionOptions.eventOnly.mode, .none)
        XCTAssertEqual(ChartSelectionOptions.eventOnly.behavior, .tap)
        XCTAssertEqual(ChartSelectionOptions.eventOnly.overlappingSelectionMode, .cycle)
        XCTAssertEqual(ChartSelectionOptions.eventOnly.hitboxRadius, 32)
        XCTAssertTrue(ChartSelectionOptions.eventOnly.dismissalPolicy.contains(.gestureEnd))
    }
}
