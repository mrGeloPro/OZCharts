//
//  StackedBarSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class StackedBarSeriesTests: XCTestCase {
    private enum Group: Hashable {
        case first
        case second
    }

    func testSegmentLayoutsFollowStackOrderAndAccumulateWidths() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.second, .first],
            colorMapper: { _ in .blue },
            barHeight: 10,
            cornerRadius: 0,
            segmentGap: 2
        )
        let contexts = [
            context(x: 2, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let layouts = series.segmentLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 2)
        XCTAssertEqual(layouts[0].group, .second)
        XCTAssertEqual(layouts[0].rect.origin.x, 0, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.origin.y, 25, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.width, 28, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.height, 10, accuracy: 0.0001)

        XCTAssertEqual(layouts[1].group, .first)
        XCTAssertEqual(layouts[1].rect.origin.x, 30, accuracy: 0.0001)
        XCTAssertEqual(layouts[1].rect.width, 18, accuracy: 0.0001)
    }

    func testSegmentLayoutsSkipMissingGroupsAndZeroWidthSegments() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first, .second],
            colorMapper: { _ in .blue }
        )
        let contexts = [
            context(x: 0, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let layouts = series.segmentLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 1)
        XCTAssertEqual(layouts[0].group, .second)
    }

    func testSegmentLayoutsAggregateDuplicateGroupsInSameRow() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first, .second],
            colorMapper: { _ in .blue },
            barHeight: 10,
            cornerRadius: 0,
            segmentGap: 0
        )
        let contexts = [
            context(x: 2, y: 0, group: .first, screenY: 30),
            context(x: 4, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let layouts = series.segmentLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 2)
        XCTAssertEqual(layouts[0].group, .first)
        XCTAssertEqual(layouts[0].rect.width, 60, accuracy: 0.0001)
        XCTAssertEqual(layouts[1].rect.origin.x, 60, accuracy: 0.0001)
        XCTAssertEqual(layouts[1].rect.width, 30, accuracy: 0.0001)
    }

    func testRemainderLayoutsFillToTargetWithoutLegendGroup() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first, .second],
            colorMapper: { _ in .blue },
            remainderStyle: .target(
                8,
                fillStyle: .stripes(foreground: .white, background: .gray.opacity(0.2))
            ),
            barHeight: 10,
            cornerRadius: 0,
            segmentGap: 2
        )
        let contexts = [
            context(x: 2, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let layouts = series.remainderLayouts(contexts: contexts)

        XCTAssertEqual(layouts.count, 1)
        XCTAssertEqual(layouts[0].rect.origin.x, 52, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rect.width, 28, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].rowTotal, 5, accuracy: 0.0001)
        XCTAssertEqual(layouts[0].targetValue, 8, accuracy: 0.0001)
    }

    func testSelectionElementsIncludeRowsSegmentsAndRemainderPayloads() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000123")!,
            stackOrder: [.first, .second],
            colorMapper: { _ in .blue },
            groupLabel: { group in group == .first ? "First" : "Second" },
            rowLabel: { _ in "High\nscore" },
            remainderStyle: .target(
                8,
                fillStyle: .stripes(foreground: .white, background: .gray.opacity(0.2)),
                isSelectable: true,
                accessibilityLabel: "Remaining"
            ),
            interactionOptions: StackedBarInteractionOptions(
                selectsSegments: true,
                selectsRows: true,
                selectsRemainder: true
            ),
            rowHitboxHeight: 44,
            barHeight: 10,
            cornerRadius: 0,
            segmentGap: 2
        )
        let contexts = [
            context(x: 2, y: 0, group: .first, screenY: 30),
            context(x: 3, y: 0, group: .second, screenY: 30)
        ]

        let elements = series.selectionElements(contexts: contexts, size: CGSize(width: 120, height: 80))

        XCTAssertEqual(
            elements.map(\.payload.kind),
            [.stackedBarRow, .stackedBarSegment, .stackedBarSegment, .stackedBarRemainder]
        )
        XCTAssertEqual(elements[0].payload.rowLabel, "High\nscore")
        XCTAssertEqual(elements[0].payload.totalValue, 5)
        XCTAssertEqual(elements[1].payload.groupLabel, "First")
        XCTAssertEqual(elements[1].payload.totalValue, 5)
        XCTAssertEqual(elements[1].payload.rowLabel, "High\nscore")
        XCTAssertEqual(elements[3].payload.label, "Remaining")
        XCTAssertTrue(elements[3].payload.isSupplementary)
    }

    func testRowSelectionIDsStayStableWhenRowsAreInsertedBeforeExistingRow() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000123")!,
            stackOrder: [.first],
            colorMapper: { _ in .blue },
            interactionOptions: .rows
        )
        let existingRow = context(x: 4, y: 1, group: .first, screenY: 40)
        let insertedRow = context(x: 2, y: 0, group: .first, screenY: 20)

        let originalID = series
            .selectionElements(contexts: [existingRow], size: CGSize(width: 120, height: 80))
            .first?.payload.elementID
        let restoredID = series
            .selectionElements(contexts: [insertedRow, existingRow], size: CGSize(width: 120, height: 80))
            .first { $0.payload.y == 1 }?
            .payload.elementID

        XCTAssertEqual(restoredID, originalID)
    }

    func testLayoutSignatureTracksStaticRemainderTargetChanges() {
        let first = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first],
            colorMapper: { _ in .blue },
            remainderStyle: .target(8, fillStyle: .color(.gray))
        )
        let second = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first],
            colorMapper: { _ in .blue },
            remainderStyle: .target(10, fillStyle: .color(.gray))
        )

        XCTAssertNotEqual(first.layoutSignature, second.layoutSignature)
    }

    private func context(
        x: Double,
        y: Double,
        group: Group,
        screenY: CGFloat
    ) -> ChartPointContext<GroupedPoint2D<Group>> {
        ChartPointContext(
            originalPoint: GroupedPoint2D(x: x, y: y, group: group),
            position: CGPoint(x: x * 10, y: screenY),
            scaleX: { CGFloat($0 * 10) },
            scaleY: { CGFloat($0) }
        )
    }
}
