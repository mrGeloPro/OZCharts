//
//  ViolinSeriesTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import SwiftUI
import XCTest
@testable import OZCharts

final class ViolinSeriesTests: XCTestCase {
    private enum Group: Hashable {
        case value
    }

    func testSilvermanBandwidthFallsBackForSingletonOrConstantData() {
        let series = makeSeries()

        XCTAssertEqual(series.silvermanBandwidth([42]), 1, accuracy: 0.0001)
        XCTAssertEqual(series.silvermanBandwidth([5, 5, 5]), 1, accuracy: 0.0001)
    }

    func testSilvermanBandwidthIsPositiveForDistributedData() {
        let series = makeSeries()

        XCTAssertGreaterThan(series.silvermanBandwidth([10, 20, 30, 40]), 0)
    }

    func testKDEDensityIsHigherNearClusterThanFarAway() {
        let series = makeSeries()
        let data = [10.0, 11.0, 12.0, 13.0]
        let bandwidth = series.silvermanBandwidth(data)

        XCTAssertGreaterThan(
            series.kdeDensity(11.5, data: data, h: bandwidth),
            series.kdeDensity(100, data: data, h: bandwidth)
        )
    }

    func testKDEDensityReturnsZeroForInvalidInput() {
        let series = makeSeries()

        XCTAssertEqual(series.kdeDensity(10, data: [], h: 1), 0, accuracy: 0.0001)
        XCTAssertEqual(series.kdeDensity(10, data: [10], h: 0), 0, accuracy: 0.0001)
    }

    func testDeterministicJitterStaysInUnitRangeForSameID() {
        let series = makeSeries()
        let id = UUID()

        let first = series.deterministicJitter(for: id)
        let second = series.deterministicJitter(for: id)

        XCTAssertEqual(first, second, accuracy: 0.0001)
        XCTAssertGreaterThanOrEqual(first, 0)
        XCTAssertLessThan(first, 1)
    }

    func testDeterministicJitterIsStableForKnownID() {
        let series = makeSeries()
        let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

        XCTAssertEqual(series.deterministicJitter(for: id), 0.010, accuracy: 0.0001)
    }

    func testInterpolatedDensityUsesNearestSamples() {
        let series = makeSeries()
        let samples = [
            (y: 0.0, density: 0.2),
            (y: 10.0, density: 0.8),
            (y: 20.0, density: 0.4)
        ]

        XCTAssertEqual(series.interpolatedDensity(at: -2, samples: samples), 0.2, accuracy: 0.0001)
        XCTAssertEqual(series.interpolatedDensity(at: 5, samples: samples), 0.5, accuracy: 0.0001)
        XCTAssertEqual(series.interpolatedDensity(at: 20, samples: samples), 0.4, accuracy: 0.0001)
    }

    private func makeSeries() -> ViolinSeries<GroupedPoint2D<Group>> {
        ViolinSeries(
            data: [],
            centerX: 0,
            sideMapper: { _ in .both },
            colorMapper: { _ in .blue }
        )
    }
}
