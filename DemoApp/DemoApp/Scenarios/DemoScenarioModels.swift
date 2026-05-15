//
//  DemoScenarioModels.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation

struct DemoScenarioCatalog: Decodable {
    let version: Int
    let scenarios: [DemoScenario]
}

struct DemoScenario: Decodable, Identifiable {

    let id: String
    let domain: String
    let title: String
    let subtitle: String
    let icon: String
    let tint: DemoColorToken
    let xAxis: DemoXAxis
    let yAxis: DemoYAxis
    let series: [DemoSeriesDefinition]
    let events: [DemoEvent]

    var primarySeries: DemoSeriesDefinition? {
        series.first
    }

    var xDomain: ClosedRange<Double> {
        xAxis.startDate.timeIntervalSince1970...xAxis.endDate.timeIntervalSince1970
    }

    var yDomain: ClosedRange<Double> {
        yAxis.min...yAxis.max
    }

    var measurementCount: Int {
        events.filter { $0.series != nil && $0.value != nil }.count
    }

    var notableEvents: [DemoEvent] {
        events.filter { $0.kind != .measurement }
    }
}

struct DemoXAxis: Decodable {
    let start: String
    let end: String
    let labelFormat: DemoXAxisLabelFormat

    var startDate: Date {
        DemoScenarioDateParser.date(from: start)
    }

    var endDate: Date {
        DemoScenarioDateParser.date(from: end)
    }
}

struct DemoYAxis: Decodable {
    let label: String
    let unit: String
    let min: Double
    let max: Double
    let targetMin: Double?
    let targetMax: Double?
}

struct DemoSeriesDefinition: Decodable, Identifiable {
    let id: String
    let name: String
    let kind: DemoSeriesKind
    let unit: String
    let color: DemoColorToken
    let interpolation: DemoInterpolation
}

struct DemoEvent: Decodable, Identifiable {
    let timestamp: String
    let kind: DemoEventKind
    let series: String?
    let value: Double?
    let unit: String?
    let label: String
    let source: String?
    let severity: String?

    var id: String {
        "\(timestamp)-\(kind.rawValue)-\(label)"
    }

    var date: Date {
        DemoScenarioDateParser.date(from: timestamp)
    }

    var tooltipTitle: String {
        if let value, let unit {
            return "\(label) \(formatted(value)) \(unit)"
        }
        if let value {
            return "\(label) \(formatted(value))"
        }
        return label
    }

    private func formatted(_ value: Double) -> String {
        value.rounded() == value ? "\(Int(value))" : String(format: "%.1f", value)
    }
}

enum DemoSeriesKind: String, Decodable {
    case area
    case bar
    case line
}

enum DemoXAxisLabelFormat: String, Decodable {
    case hour
    case minute
}

enum DemoInterpolation: String, Decodable {
    case linear
    case step
    case monotone
}

enum DemoEventKind: String, Decodable, Hashable {
    case deploy
    case exercise
    case incident
    case insulin
    case intervalStart
    case manualCheck
    case meal
    case measurement
    case mitigation
    case news
    case rebalance
    case recovery
}

enum DemoColorToken: String, Decodable {
    case cyan
    case green
    case orange
    case pink
    case purple
}
