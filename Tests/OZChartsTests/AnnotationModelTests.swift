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
}
