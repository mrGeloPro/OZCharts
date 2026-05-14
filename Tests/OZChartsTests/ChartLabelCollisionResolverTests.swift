//
//  ChartLabelCollisionResolverTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartLabelCollisionResolverTests: XCTestCase {
    func testClampsLabelIntoCanvas() {
        let center = ChartLabelCollisionResolver.clampCenter(
            CGPoint(x: 2, y: 2),
            size: CGSize(width: 40, height: 20),
            canvasSize: CGSize(width: 100, height: 80),
            padding: 8
        )

        XCTAssertEqual(center.x, 28)
        XCTAssertEqual(center.y, 18)
    }

    func testAutomaticPlacementAvoidsExistingLabels() throws {
        let firstID = UUID()
        let secondID = UUID()
        let resolved = ChartLabelCollisionResolver.resolve(
            candidates: [
                ChartLabelCandidate(
                    id: firstID,
                    anchor: CGPoint(x: 80, y: 80),
                    size: CGSize(width: 60, height: 30),
                    priority: 10
                ),
                ChartLabelCandidate(
                    id: secondID,
                    anchor: CGPoint(x: 80, y: 80),
                    size: CGSize(width: 60, height: 30),
                    priority: 1
                )
            ],
            canvasSize: CGSize(width: 220, height: 180)
        )

        let first = try XCTUnwrap(resolved.first { $0.id == firstID })
        let second = try XCTUnwrap(resolved.first { $0.id == secondID })
        XCTAssertTrue(first.isVisible)
        XCTAssertTrue(second.isVisible)
        XCTAssertFalse(first.bounds.intersects(second.bounds))
    }

    func testLowerPriorityLabelCanBeHiddenWhenNoSpaceRemains() throws {
        let firstID = UUID()
        let secondID = UUID()
        let resolved = ChartLabelCollisionResolver.resolve(
            candidates: [
                ChartLabelCandidate(
                    id: firstID,
                    anchor: CGPoint(x: 50, y: 50),
                    size: CGSize(width: 90, height: 90),
                    priority: 10,
                    preferredPlacements: [.center]
                ),
                ChartLabelCandidate(
                    id: secondID,
                    anchor: CGPoint(x: 50, y: 50),
                    size: CGSize(width: 90, height: 90),
                    priority: 1,
                    preferredPlacements: [.center],
                    canHide: true
                )
            ],
            canvasSize: CGSize(width: 110, height: 110)
        )

        XCTAssertTrue(try XCTUnwrap(resolved.first { $0.id == firstID }).isVisible)
        XCTAssertFalse(try XCTUnwrap(resolved.first { $0.id == secondID }).isVisible)
    }
}
