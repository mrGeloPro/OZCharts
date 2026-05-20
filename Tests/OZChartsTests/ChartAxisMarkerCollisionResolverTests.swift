//
//  ChartAxisMarkerCollisionResolverTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import XCTest

final class ChartAxisMarkerCollisionResolverTests: XCTestCase {
    func testAllowOverlapKeepsBothMarkersVisible() {
        let results = resolve([
            candidate(id: stableID(1), strategy: .allowOverlap),
            candidate(id: stableID(2), strategy: .allowOverlap)
        ])

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy(\.isVisible))
    }

    func testHideLowerPrioritySuppressesLowerPriorityMarker() {
        let high = candidate(id: stableID(1), priority: 10, strategy: .hideLowerPriority)
        let low = candidate(id: stableID(2), priority: 0, strategy: .hideLowerPriority)
        let results = resolve([low, high])

        XCTAssertTrue(result(id: stableID(1), in: results).isVisible)
        XCTAssertFalse(result(id: stableID(2), in: results).isVisible)
    }

    func testHideLabelUsesCompactContentWhenFullContentCollides() {
        let first = candidate(id: stableID(1), strategy: .allowOverlap)
        let second = candidate(
            id: stableID(2),
            compactSize: CGSize(width: 10, height: 10),
            strategy: .hideLabel
        )
        let results = resolve([first, second])

        let compactResult = result(id: stableID(2), in: results)
        XCTAssertTrue(compactResult.isVisible)
        XCTAssertTrue(compactResult.usesCompactContent)
        XCTAssertEqual(compactResult.frame.size.width, 10)
    }

    func testShiftMovesCollidingMarkerWithinBounds() {
        let first = candidate(id: stableID(1), strategy: .allowOverlap)
        let second = candidate(id: stableID(2), strategy: .shift(maxOffset: 64))
        let results = resolve([first, second])

        let shifted = result(id: stableID(2), in: results)
        XCTAssertTrue(shifted.isVisible)
        XCTAssertNotEqual(shifted.position.x, second.position.x)
    }

    func testStackMovesCollidingMarkerAwayFromAxis() {
        let first = candidate(id: stableID(1), strategy: .allowOverlap)
        let second = candidate(id: stableID(2), strategy: .stack(spacing: 4))
        let results = resolve([first, second])

        let stacked = result(id: stableID(2), in: results)
        XCTAssertTrue(stacked.isVisible)
        XCTAssertGreaterThan(stacked.position.y, second.position.y)
    }

    func testAutomaticHidesWhenNoResolutionFits() {
        let first = candidate(
            id: stableID(1),
            size: CGSize(width: 80, height: 80),
            strategy: .allowOverlap
        )
        let second = candidate(
            id: stableID(2),
            size: CGSize(width: 80, height: 80),
            strategy: .automatic
        )
        let results = ChartAxisMarkerCollisionResolver.resolve(
            [first, second],
            bounds: CGRect(x: 60, y: 60, width: 80, height: 80)
        )

        XCTAssertFalse(result(id: stableID(2), in: results).isVisible)
    }

    private func resolve(
        _ candidates: [ChartAxisMarkerLayoutCandidate]
    ) -> [ChartAxisMarkerLayoutResult] {
        ChartAxisMarkerCollisionResolver.resolve(
            candidates,
            bounds: CGRect(x: 0, y: 0, width: 240, height: 240)
        )
    }

    private func candidate(
        id: UUID,
        position: CGPoint = CGPoint(x: 100, y: 100),
        size: CGSize = CGSize(width: 40, height: 24),
        compactSize: CGSize? = nil,
        priority: Double = 0,
        strategy: ChartAxisMarkerCollisionStrategy
    ) -> ChartAxisMarkerLayoutCandidate {
        ChartAxisMarkerLayoutCandidate(
            id: id,
            axis: .x,
            placement: .bottom,
            anchor: position,
            position: position,
            size: size,
            compactSize: compactSize,
            priority: priority,
            collisionStrategy: strategy,
            originalIndex: Int(id.uuid.0)
        )
    }

    private func result(
        id: UUID,
        in results: [ChartAxisMarkerLayoutResult]
    ) -> ChartAxisMarkerLayoutResult {
        guard let result = results.first(where: { $0.id == id }) else {
            XCTFail("Missing result \(id)")
            return results[0]
        }
        return result
    }

    private func stableID(_ value: UInt8) -> UUID {
        UUID(uuid: (value, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
