//
//  DemoScenarioData.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import SwiftUI
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

    func points(for definition: DemoSeriesDefinition) -> [Point2D] {
        events
            .filter { $0.series == definition.id && $0.value != nil }
            .sorted { $0.date < $1.date }
            .map { Point2D(x: $0.date.timeIntervalSince1970, y: $0.value ?? 0) }
    }

    func chartSeries(useSmoothLines: Bool = true) -> [AnyChartSeries<Point2D>] {
        series.enumerated().map { index, definition in
            let data = points(for: definition)
            let color = definition.color.color
            let interpolation: LineInterpolation = useSmoothLines ? definition.interpolation.lineInterpolation : .linear
            switch definition.kind {
            case .area:
                return AreaSeries(
                    data: data,
                    color: color,
                    fillColor: color,
                    fillOpacity: 0.18,
                    baseline: yAxis.min,
                    label: definition.name,
                    lineWidth: 3,
                    interpolation: interpolation,
                    zIndex: index
                ).eraseToAnyChartSeries()
            case .bar:
                return BarSeries(
                    data: data,
                    color: color.opacity(0.62),
                    label: definition.name,
                    barWidth: 9,
                    cornerRadius: 2,
                    zIndex: index
                ).eraseToAnyChartSeries()
            case .line:
                return LineSeries(
                    data: data,
                    color: color,
                    label: definition.name,
                    lineWidth: 3,
                    interpolation: interpolation,
                    zIndex: index
                ).eraseToAnyChartSeries()
            }
        }
    }

    func eventMarkers() -> [ChartEventMarker] {
        notableEvents.compactMap { event in
            guard xDomain.contains(event.date.timeIntervalSince1970) else { return nil }
            let y = event.value ?? nearestPrimaryValue(to: event.date) ?? yAxis.max
            return ChartEventMarker(
                x: event.date.timeIntervalSince1970,
                y: min(max(y, yAxis.min), yAxis.max),
                label: event.tooltipTitle,
                shape: event.kind.symbolShape,
                color: event.kind.colorToken.color,
                size: event.kind.annotationSize,
                strokeColor: .white.opacity(0.88),
                strokeWidth: 1.4,
                isSelectable: true,
                hitboxRadius: 32
            )
        }
    }

    func horizontalAnnotations() -> [HorizontalAnnotation] {
        var annotations: [HorizontalAnnotation] = []
        if yAxis.targetMin == nil, let targetMax = yAxis.targetMax {
            annotations.append(
                HorizontalAnnotation(
                    yValue: targetMax,
                    label: "Target",
                    color: DemoColors.orange.opacity(0.75),
                    lineWidth: 1.5,
                    dash: [5, 5]
                )
            )
        }
        return annotations
    }

    func rangeAnnotations() -> [RangeAnnotation] {
        guard let targetMin = yAxis.targetMin,
              let targetMax = yAxis.targetMax else { return [] }

        return [
            RangeAnnotation(
                yRange: targetMin...targetMax,
                label: "Target range",
                color: tint.color,
                opacity: 0.10
            )
        ]
    }

    func legendItems() -> [(String, Color)] {
        series.map { ($0.name, $0.color.color) } +
        Array(Set(notableEvents.map(\.kind))).sorted { $0.rawValue < $1.rawValue }.map {
            ($0.displayName, $0.colorToken.color)
        }
    }

    func xAxisLabel(_ value: Double) -> String {
        let date = Date(timeIntervalSince1970: value)
        switch xAxis.labelFormat {
        case .minute:
            let minutes = Int(date.timeIntervalSince(xAxis.startDate) / 60)
            return "\(minutes)m"
        case .hour:
            return date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))
        }
    }

    func valueText(_ value: Double) -> String {
        let valueString: String
        if value.rounded() == value {
            valueString = "\(Int(value))"
        } else {
            valueString = String(format: "%.1f", value)
        }
        return "\(valueString) \(yAxis.unit)"
    }

    private func nearestPrimaryValue(to date: Date) -> Double? {
        guard let primarySeries else { return nil }
        return points(for: primarySeries)
            .min { lhs, rhs in
                abs(lhs.x - date.timeIntervalSince1970) < abs(rhs.x - date.timeIntervalSince1970)
            }?
            .y
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

    var lineInterpolation: LineInterpolation {
        switch self {
        case .linear:
            return .linear
        case .step:
            return .step
        case .monotone:
            return .monotone
        }
    }
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

    var displayName: String {
        switch self {
        case .deploy:
            return "Deploy"
        case .exercise:
            return "Exercise"
        case .incident:
            return "Incident"
        case .insulin:
            return "Insulin"
        case .intervalStart:
            return "Interval"
        case .manualCheck:
            return "Manual check"
        case .meal:
            return "Meal"
        case .measurement:
            return "Measurement"
        case .mitigation:
            return "Mitigation"
        case .news:
            return "News"
        case .rebalance:
            return "Rebalance"
        case .recovery:
            return "Recovery"
        }
    }

    var colorToken: DemoColorToken {
        switch self {
        case .deploy, .rebalance:
            return .cyan
        case .exercise, .mitigation, .recovery:
            return .green
        case .incident, .intervalStart:
            return .pink
        case .insulin, .meal:
            return .orange
        case .manualCheck, .news:
            return .purple
        case .measurement:
            return .green
        }
    }

    var symbolShape: ChartSymbolShape {
        switch self {
        case .incident, .intervalStart:
            return .star
        case .insulin, .rebalance:
            return .diamond
        case .meal, .news:
            return .triangle
        case .deploy, .manualCheck, .mitigation:
            return .square
        case .exercise, .recovery, .measurement:
            return .circle
        }
    }

    var annotationSize: CGFloat {
        switch self {
        case .incident, .intervalStart:
            return 20
        default:
            return 16
        }
    }
}

enum DemoColorToken: String, Decodable {
    case cyan
    case green
    case orange
    case pink
    case purple

    var color: Color {
        switch self {
        case .cyan:
            return DemoColors.cyan
        case .green:
            return DemoColors.green
        case .orange:
            return DemoColors.orange
        case .pink:
            return DemoColors.pink
        case .purple:
            return DemoColors.purple
        }
    }
}

enum DemoScenarioStore {
    static let scenarios: [DemoScenario] = loadScenarios()

    private static func loadScenarios() -> [DemoScenario] {
        guard let url = Bundle.main.url(forResource: "DemoScenarios", withExtension: "json") else {
            assertionFailure("DemoScenarios.json is missing from the app bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(DemoScenarioCatalog.self, from: data).scenarios
        } catch {
            assertionFailure("Failed to decode DemoScenarios.json: \(error)")
            return []
        }
    }
}

private enum DemoScenarioDateParser {
    static func date(from value: String) -> Date {
        if let date = formatter.date(from: value) {
            return date
        }
        assertionFailure("Invalid scenario date: \(value)")
        return Date(timeIntervalSince1970: 0)
    }

    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
