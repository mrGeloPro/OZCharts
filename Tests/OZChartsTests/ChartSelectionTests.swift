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
        XCTAssertEqual(selection.primaryAnchor?.kind, .element)
        XCTAssertEqual(selection.primaryAnchor?.bounds, element.bounds)
        XCTAssertEqual(selection.primaryPosition, element.position)
    }

    func testSelectionAnchorFallsBackToPointPayload() {
        let seriesID = UUID()
        let point = ChartPointContext(
            originalPoint: Point2D(x: 4, y: 12),
            position: CGPoint(x: 44, y: 88)
        )
        let selection = ChartSelection(
            points: [point],
            state: ChartSelectionState(
                selectedPoints: [
                    ChartSelectedPoint(
                        pointID: point.id,
                        seriesID: seriesID,
                        seriesIndex: 2,
                        x: 4,
                        y: 12
                    )
                ]
            )
        )

        XCTAssertEqual(selection.primaryAnchor?.kind, .point)
        XCTAssertEqual(selection.primaryAnchor?.seriesID, seriesID)
        XCTAssertEqual(selection.primaryAnchor?.seriesIndex, 2)
        XCTAssertEqual(selection.primaryAnchor?.position, CGPoint(x: 44, y: 88))
        XCTAssertEqual(selection.primaryAnchor?.value, 12)
    }

    func testSelectionAnchorFallsBackToAnnotationBounds() {
        let annotation = ChartAnnotationContext(
            id: UUID(),
            kind: .point,
            x: 1,
            y: 2,
            position: CGPoint(x: 20, y: 30),
            label: "Dose",
            hitboxRadius: 8
        )
        let selection = ChartSelection<Point2D>(annotations: [annotation])

        XCTAssertEqual(selection.primaryAnchor?.kind, .annotation)
        XCTAssertEqual(selection.primaryAnchor?.label, "Dose")
        XCTAssertEqual(selection.primaryBounds, CGRect(x: 12, y: 22, width: 16, height: 16))
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
        XCTAssertTrue(ChartSelectionOptions.scrollSafeNearestX.dismissalPolicy.contains(.tapOutside))
        XCTAssertTrue(ChartSelectionOptions.scrollSafeNearestX.dismissalPolicy.contains(.drag))
        XCTAssertTrue(ChartSelectionOptions.scrollSafeNearestX.dismissalPolicy.contains(.viewportChange))
        XCTAssertEqual(ChartSelectionOptions.scrollSafeNearestX.activation, .onTapEnd)
        XCTAssertEqual(ChartSelectionOptions.scrollSafeNearestX.nearestSelectionPolicy, .withinHitbox)

        XCTAssertEqual(ChartSelectionOptions.eventOnly.mode, .none)
        XCTAssertEqual(ChartSelectionOptions.eventOnly.behavior, .tap)
        XCTAssertEqual(ChartSelectionOptions.eventOnly.overlappingSelectionMode, .cycle)
        XCTAssertEqual(ChartSelectionOptions.eventOnly.hitboxRadius, 32)
        XCTAssertTrue(ChartSelectionOptions.eventOnly.dismissalPolicy.contains(.gestureEnd))
    }
}
