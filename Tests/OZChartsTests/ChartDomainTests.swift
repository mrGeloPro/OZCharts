//
//  ChartDomainTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import XCTest
@testable import OZCharts

final class ChartDomainTests: XCTestCase {
    func testFixedDomainReturnsTheProvidedRange() {
        let domain = ChartDomain.fixed(10...20)

        XCTAssertEqual(domain.resolve(values: [1, 2, 3]), 10...20)
    }

    func testAutoDomainUsesFiniteValuesAndPadding() {
        let domain = ChartDomain.auto(padding: 0.1)
        let resolved = domain.resolve(values: [10, 20, .nan, .infinity])

        XCTAssertEqual(resolved.lowerBound, 9, accuracy: 0.0001)
        XCTAssertEqual(resolved.upperBound, 21, accuracy: 0.0001)
    }

    func testAutoDomainCanIncludeZero() {
        let domain = ChartDomain.auto(padding: 0, includeZero: true)
        let resolved = domain.resolve(values: [10, 20])

        XCTAssertEqual(resolved.lowerBound, 0, accuracy: 0.0001)
        XCTAssertEqual(resolved.upperBound, 20, accuracy: 0.0001)
    }

    func testAutoDomainExpandsSingleValue() {
        let resolved = ChartDomain.auto().resolve(values: [5])

        XCTAssertLessThan(resolved.lowerBound, 5)
        XCTAssertGreaterThan(resolved.upperBound, 5)
    }

    func testAutoDomainFallsBackForEmptyValues() {
        let resolved = ChartDomain.auto(fallback: -1...1).resolve(values: [])

        XCTAssertEqual(resolved, -1...1)
    }
}
