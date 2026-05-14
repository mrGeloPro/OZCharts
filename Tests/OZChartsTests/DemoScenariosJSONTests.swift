//
//  DemoScenariosJSONTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import XCTest

final class DemoScenariosJSONTests: XCTestCase {
    func testDemoScenariosDecodeAsDomainEvents() throws {
        let catalog = try loadCatalog()

        XCTAssertEqual(catalog.version, 1)
        XCTAssertGreaterThanOrEqual(catalog.scenarios.count, 4)

        for scenario in catalog.scenarios {
            XCTAssertFalse(scenario.id.isEmpty)
            XCTAssertFalse(scenario.title.isEmpty)
            XCTAssertFalse(scenario.series.isEmpty)
            XCTAssertFalse(scenario.events.isEmpty)
            XCTAssertLessThan(scenario.xAxis.startDate, scenario.xAxis.endDate)
            XCTAssertLessThan(scenario.yAxis.min, scenario.yAxis.max)

            if let targetMin = scenario.yAxis.targetMin,
               let targetMax = scenario.yAxis.targetMax {
                XCTAssertLessThan(targetMin, targetMax)
            }

            let seriesIDs = Set(scenario.series.map(\.id))
            let measurements = scenario.events.filter { $0.series != nil }
            let domainEvents = scenario.events.filter { $0.series == nil }

            XCTAssertFalse(measurements.isEmpty, "\(scenario.id) should contain measured values.")
            XCTAssertFalse(domainEvents.isEmpty, "\(scenario.id) should contain domain events.")

            for event in scenario.events {
                XCTAssertGreaterThanOrEqual(event.date, scenario.xAxis.startDate)
                XCTAssertLessThanOrEqual(event.date, scenario.xAxis.endDate)

                if let series = event.series {
                    XCTAssertTrue(seriesIDs.contains(series), "\(scenario.id) references unknown series \(series).")
                    XCTAssertNotNil(event.value, "\(scenario.id) series event \(event.label) needs a value.")
                }

                if let value = event.value, event.series != nil {
                    XCTAssertGreaterThanOrEqual(value, scenario.yAxis.min)
                    XCTAssertLessThanOrEqual(value, scenario.yAxis.max)
                }
            }
        }
    }

    private func loadCatalog() throws -> DemoCatalogFixture {
        let root = try packageRoot()
        let url = root.appendingPathComponent("DemoApp/DemoApp/DemoScenarios.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(DemoCatalogFixture.self, from: data)
    }

    private func packageRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("Package.swift").path) {
                return url
            }
        }
        throw XCTSkip("Could not locate package root.")
    }
}

private struct DemoCatalogFixture: Decodable {
    let version: Int
    let scenarios: [DemoScenarioFixture]
}

private struct DemoScenarioFixture: Decodable {
    let id: String
    let title: String
    let xAxis: DemoXAxisFixture
    let yAxis: DemoYAxisFixture
    let series: [DemoSeriesFixture]
    let events: [DemoEventFixture]
}

private struct DemoXAxisFixture: Decodable {
    let start: String
    let end: String

    var startDate: Date {
        DemoScenarioDateFixtureParser.date(from: start)
    }

    var endDate: Date {
        DemoScenarioDateFixtureParser.date(from: end)
    }
}

private struct DemoYAxisFixture: Decodable {
    let min: Double
    let max: Double
    let targetMin: Double?
    let targetMax: Double?
}

private struct DemoSeriesFixture: Decodable {
    let id: String
}

private struct DemoEventFixture: Decodable {
    let timestamp: String
    let series: String?
    let value: Double?
    let label: String

    var date: Date {
        DemoScenarioDateFixtureParser.date(from: timestamp)
    }
}

private enum DemoScenarioDateFixtureParser {
    static func date(from value: String) -> Date {
        formatter.date(from: value) ?? Date(timeIntervalSince1970: 0)
    }

    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
