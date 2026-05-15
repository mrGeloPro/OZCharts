//
//  DemoScenarioModels.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import OZCharts

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
    let xRanges: [DemoXRange]?
    let xyRanges: [DemoXYRange]?
    let verticalLines: [DemoVerticalLine]?
    let presentation: DemoScenarioPresentation?

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
    let position: DemoXAxisPosition?
    let timeZone: String?
    let ticks: [String]?
    let tickCount: Int?

    var startDate: Date {
        DemoScenarioDateParser.date(from: start)
    }

    var endDate: Date {
        DemoScenarioDateParser.date(from: end)
    }

    var explicitValues: [Double]? {
        ticks?.map { DemoScenarioDateParser.date(from: $0).timeIntervalSince1970 }
    }

    var resolvedPosition: XAxisPosition {
        position?.axisPosition ?? .bottom
    }

    var resolvedTimeZone: TimeZone {
        timeZone.flatMap(TimeZone.init(identifier:)) ?? .current
    }
}

struct DemoYAxis: Decodable {
    let label: String
    let unit: String
    let min: Double
    let max: Double
    let position: DemoYAxisPosition?
    let targetMin: Double?
    let targetMax: Double?
    let tickCount: Int?
    let referenceLines: [DemoReferenceLine]?

    var resolvedPosition: YAxisPosition {
        position?.axisPosition ?? .leading
    }
}

struct DemoScenarioPresentation: Decodable {
    let showsEventMarkers: Bool?
    let showsZoomControls: Bool?
    let initialViewportFraction: Double?

    var resolvedShowsEventMarkers: Bool {
        showsEventMarkers ?? true
    }

    var resolvedShowsZoomControls: Bool {
        showsZoomControls ?? true
    }

    var resolvedInitialViewportFraction: Double {
        min(max(initialViewportFraction ?? 0.55, 0.05), 1)
    }
}

struct DemoSeriesDefinition: Decodable, Identifiable {
    let id: String
    let name: String
    let kind: DemoSeriesKind
    let unit: String
    let color: DemoColorToken
    let interpolation: DemoInterpolation
    let baseline: Double?
    let barWidth: Double?
}

struct DemoReferenceLine: Decodable, Identifiable {
    let value: Double
    let label: String?
    let color: DemoColorToken
    let lineWidth: Double?
    let dash: [Double]?

    var id: String {
        "\(value)-\(label ?? color.rawValue)"
    }
}

struct DemoXRange: Decodable, Identifiable {
    let start: String
    let end: String
    let label: String?
    let color: DemoColorToken
    let opacity: Double?

    var id: String {
        "\(start)-\(end)-\(label ?? color.rawValue)"
    }

    var range: ClosedRange<Double> {
        let lowerBound = DemoScenarioDateParser.date(from: start).timeIntervalSince1970
        let upperBound = DemoScenarioDateParser.date(from: end).timeIntervalSince1970
        return lowerBound...upperBound
    }
}

struct DemoXYRange: Decodable, Identifiable {
    let start: String
    let end: String
    let yMin: Double
    let yMax: Double
    let label: String?
    let color: DemoColorToken
    let opacity: Double?

    var id: String {
        "\(start)-\(end)-\(yMin)-\(yMax)-\(label ?? color.rawValue)"
    }

    var xRange: ClosedRange<Double> {
        let lowerBound = DemoScenarioDateParser.date(from: start).timeIntervalSince1970
        let upperBound = DemoScenarioDateParser.date(from: end).timeIntervalSince1970
        return lowerBound...upperBound
    }

    var yRange: ClosedRange<Double> {
        yMin...yMax
    }
}

struct DemoVerticalLine: Decodable, Identifiable {
    let timestamp: String
    let label: String
    let color: DemoColorToken
    let lineWidth: Double?
    let dash: [Double]?

    var id: String {
        "\(timestamp)-\(label)"
    }

    var xValue: Double {
        DemoScenarioDateParser.date(from: timestamp).timeIntervalSince1970
    }
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

enum DemoXAxisPosition: Decodable {
    case top
    case bottom

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self).lowercased()
        switch value {
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported X axis position: \(value)")
            )
        }
    }

    var axisPosition: XAxisPosition {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
}

enum DemoYAxisPosition: Decodable {
    case leading
    case trailing

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self).lowercased()
        switch value {
        case "leading", "left":
            self = .leading
        case "trailing", "right":
            self = .trailing
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported Y axis position: \(value)")
            )
        }
    }

    var axisPosition: YAxisPosition {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
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
    case red
    case slate
    case white
    case yellow
}
