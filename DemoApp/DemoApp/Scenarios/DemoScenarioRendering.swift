//
//  DemoScenarioRendering.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import SwiftUI
import OZCharts

extension DemoScenario {
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

extension DemoInterpolation {
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

extension DemoEventKind {

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

extension DemoColorToken {
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
