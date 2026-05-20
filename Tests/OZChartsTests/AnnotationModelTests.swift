//
//  AnnotationModelTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import SwiftUI
import XCTest
@testable import OZCharts

final class AnnotationModelTests: XCTestCase {
    func testXRangeAnnotationStoresTimeBand() {
        let annotation = XRangeAnnotation(
            xRange: 10...20,
            label: "Night window",
            color: .gray,
            opacity: 0.18
        )

        XCTAssertEqual(annotation.xRange, 10...20)
        XCTAssertEqual(annotation.label, "Night window")
        XCTAssertEqual(annotation.opacity, 0.18)
    }

    func testXYRangeAnnotationStoresPlotRegion() {
        let annotation = XYRangeAnnotation(
            xRange: 10...20,
            yRange: 250...400,
            label: "Risk window",
            color: .yellow,
            opacity: 0.08
        )

        XCTAssertEqual(annotation.xRange, 10...20)
        XCTAssertEqual(annotation.yRange, 250...400)
        XCTAssertEqual(annotation.label, "Risk window")
        XCTAssertEqual(annotation.opacity, 0.08)
    }

    func testVerticalAnnotationStoresThresholdLine() {
        let annotation = VerticalAnnotation(
            xValue: 12,
            label: "Deploy",
            color: .purple,
            lineWidth: 1.5,
            dash: [3, 4]
        )

        XCTAssertEqual(annotation.xValue, 12)
        XCTAssertEqual(annotation.label, "Deploy")
        XCTAssertEqual(annotation.lineWidth, 1.5)
        XCTAssertEqual(annotation.dash, [3, 4])
    }

    func testRangeAnnotationStoresTargetBand() {
        let annotation = RangeAnnotation(
            yRange: 70...180,
            label: "Target",
            color: .green,
            opacity: 0.14,
            labelColor: .yellow,
            showsLabel: true,
            labelXPosition: 0.78,
            labelAnchor: .leading,
            labelYOffset: -12
        )

        XCTAssertEqual(annotation.yRange, 70...180)
        XCTAssertEqual(annotation.label, "Target")
        XCTAssertEqual(annotation.opacity, 0.14)
        XCTAssertTrue(annotation.showsLabel)
        XCTAssertEqual(annotation.labelXPosition, 0.78)
        XCTAssertEqual(annotation.labelAnchor, .leading)
        XCTAssertEqual(annotation.labelYOffset, -12)
    }

    func testRangeAnnotationLabelAnchorMapsAnchorPointToTextCenter() {
        let size = CGSize(width: 80, height: 20)
        let anchorPoint = CGPoint(x: 120, y: 40)

        let leadingCenter = AnnotationLabelLayout.center(
            forAnchorPoint: anchorPoint,
            size: size,
            anchor: .leading
        )
        let trailingCenter = AnnotationLabelLayout.center(
            forAnchorPoint: anchorPoint,
            size: size,
            anchor: .trailing
        )

        XCTAssertEqual(leadingCenter, CGPoint(x: 160, y: 40))
        XCTAssertEqual(trailingCenter, CGPoint(x: 80, y: 40))
    }

    func testEventMarkerCreatesSelectablePointAnnotation() {
        let id = UUID()
        let marker = ChartEventMarker(
            id: id,
            x: 12,
            y: 88,
            label: "Insulin",
            shape: .diamond,
            color: .orange,
            size: 18,
            strokeColor: .white,
            strokeWidth: 2,
            hitboxRadius: 28
        )

        let annotation = marker.pointAnnotation

        XCTAssertEqual(annotation.id, id)
        XCTAssertEqual(annotation.x, 12)
        XCTAssertEqual(annotation.y, 88)
        XCTAssertEqual(annotation.label, "Insulin")
        XCTAssertEqual(annotation.shape, .diamond)
        XCTAssertEqual(annotation.size, 18)
        XCTAssertEqual(annotation.strokeWidth, 2)
        XCTAssertTrue(annotation.isSelectable)
        XCTAssertEqual(annotation.hitboxRadius, 28)
    }

    func testCustomViewAnnotationAcceptsStableID() {
        let id = UUID()
        let annotation = CustomViewAnnotation(
            id: id,
            x: 3.0,
            y: 7.0,
            label: "Peak",
            isSelectable: true
        ) {
            Text("Peak")
        }

        XCTAssertEqual(annotation.id, id)
        XCTAssertEqual(annotation.x, 3)
        XCTAssertEqual(annotation.y, 7)
        XCTAssertEqual(annotation.label, "Peak")
        XCTAssertTrue(annotation.isSelectable)
    }

    func testAxisMarkerStoresAxisValuePlacementAndContent() {
        let id = UUID()
        let marker = ChartAxisMarker.x(
            id: id,
            value: 12,
            placement: .top,
            offset: CGSize(width: 3, height: -4),
            priority: 3,
            collisionStrategy: .hideLabel,
            hitboxRadius: 18,
            accessibilityLabel: "Time change"
        ) {
            Image(systemName: "clock.arrow.circlepath")
        }

        XCTAssertEqual(marker.id, id)
        XCTAssertEqual(marker.axis, .x)
        XCTAssertEqual(marker.value, 12)
        XCTAssertEqual(marker.placement, .top)
        XCTAssertEqual(marker.offset, CGSize(width: 3, height: -4))
        XCTAssertEqual(marker.priority, 3)
        XCTAssertEqual(marker.collisionStrategy, .hideLabel)
        XCTAssertEqual(marker.hitboxRadius, 18)
        XCTAssertEqual(marker.accessibilityLabel, "Time change")
        XCTAssertNil(marker.compactContent)
    }

    func testAxisMarkerCanStoreCompactContentForCollisions() {
        let marker = ChartAxisMarker.y(
            value: 120,
            collisionStrategy: .automatic,
            compactContent: {
                Circle().frame(width: 8, height: 8)
            },
            content: {
                Text("Target 120")
            }
        )

        XCTAssertEqual(marker.axis, .y)
        XCTAssertEqual(marker.collisionStrategy, .automatic)
        XCTAssertNotNil(marker.compactContent)
    }
}
