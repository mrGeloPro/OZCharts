//
//  LinearScaleTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class LinearScaleTests: XCTestCase {
    func testScaleAndInvertMapBetweenDomainAndRange() {
        let scale = LinearScale(domain: 0...10, range: 0...100)

        XCTAssertEqual(scale.scale(0), 0, accuracy: 0.0001)
        XCTAssertEqual(scale.scale(5), 50, accuracy: 0.0001)
        XCTAssertEqual(scale.scale(10), 100, accuracy: 0.0001)
        XCTAssertEqual(scale.invert(75), 7.5, accuracy: 0.0001)
    }

    func testReversedScaleFlipsProjection() {
        let scale = LinearScale(domain: 0...10, range: 0...100, isReversed: true)

        XCTAssertEqual(scale.scale(0), 100, accuracy: 0.0001)
        XCTAssertEqual(scale.scale(10), 0, accuracy: 0.0001)
        XCTAssertEqual(scale.invert(25), 7.5, accuracy: 0.0001)
    }

    func testZeroWidthDomainExpandsToAvoidDivisionByZero() {
        let scale = LinearScale(domain: 5...5)

        XCTAssertEqual(scale.domain.lowerBound, 5, accuracy: 0.0001)
        XCTAssertEqual(scale.domain.upperBound, 6, accuracy: 0.0001)
    }

    func testTicksUseCountAndFormatter() {
        let scale = LinearScale(domain: 0...10, range: 0...100)
        let ticks = scale.ticks(count: 3) { "v:\(Int($0))" }

        XCTAssertEqual(ticks.map(\.value), [0, 5, 10])
        XCTAssertEqual(ticks.map(\.position), [0, 50, 100])
        XCTAssertEqual(ticks.map(\.label), ["v:0", "v:5", "v:10"])
    }

    func testTimeFactoryUsesDateTimeIntervals() {
        let start = Date(timeIntervalSince1970: 100)
        let end = Date(timeIntervalSince1970: 200)

        let scale = LinearScale.time(domain: start...end, range: 0...100)

        XCTAssertEqual(scale.scale(150), 50, accuracy: 0.0001)
    }

    func testLogScaleMapsAndInvertsLogarithmicValues() {
        let scale = LogScale(domain: 1...100, range: 0...100)

        XCTAssertEqual(scale.scale(1), 0, accuracy: 0.0001)
        XCTAssertEqual(scale.scale(10), 50, accuracy: 0.0001)
        XCTAssertEqual(scale.invert(100), 100, accuracy: 0.0001)
    }

    func testBandScaleMapsCategoriesToBandCenters() {
        let scale = BandScale(categories: ["A", "B", "C"], range: 0...300, padding: 0)

        XCTAssertEqual(scale.scale("A"), 50, accuracy: 0.0001)
        XCTAssertEqual(scale.scale("B"), 150, accuracy: 0.0001)
        XCTAssertEqual(scale.invert(260), "C")
    }
}
