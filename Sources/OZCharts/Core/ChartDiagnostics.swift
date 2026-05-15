//
//  ChartDiagnostics.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public enum ChartDiagnosticSeverity: String, Equatable {
    case warning
    case error
}

public struct ChartDiagnostic: Identifiable, Equatable {
    public var id: String {
        code
    }

    public let code: String
    public let severity: ChartDiagnosticSeverity
    public let message: String

    public init(
        code: String,
        severity: ChartDiagnosticSeverity,
        message: String
    ) {
        self.code = code
        self.severity = severity
        self.message = message
    }
}

public enum ChartDiagnostics {
    public static func validate<Point: ChartDataPoint>(
        series: [AnyChartSeries<Point>],
        canvasSize: CGSize? = nil,
        minimumCanvasSize: CGSize = CGSize(width: 2, height: 2),
        allowsEmptySeries: Bool = false
    ) -> [ChartDiagnostic] where Point.XValue == Double, Point.YValue == Double {
        var diagnostics: [ChartDiagnostic] = []

        if series.isEmpty, !allowsEmptySeries {
            diagnostics.append(
                ChartDiagnostic(
                    code: "empty-series-list",
                    severity: .warning,
                    message: "No chart series were provided."
                )
            )
        }

        let duplicateSeriesIDs = duplicateIDs(series.map(\.id))
        if !duplicateSeriesIDs.isEmpty {
            diagnostics.append(
                ChartDiagnostic(
                    code: "duplicate-series-ids",
                    severity: .warning,
                    message: "Multiple chart series share the same id. Stable unique series ids improve selection, animation, and diffing."
                )
            )
        }

        var nonFinitePointCount = 0
        var emptySeriesCount = 0
        var seriesWithDuplicatePointIDs = 0

        for chartSeries in series {
            if chartSeries.data.isEmpty {
                emptySeriesCount += 1
            }

            let duplicatePointIDs = duplicateIDs(chartSeries.data.map(\.id))
            if !duplicatePointIDs.isEmpty {
                seriesWithDuplicatePointIDs += 1
            }

            for point in chartSeries.data {
                if !point.x.isFinite || !point.y.isFinite {
                    nonFinitePointCount += 1
                }
            }
        }

        if emptySeriesCount > 0, !allowsEmptySeries {
            diagnostics.append(
                ChartDiagnostic(
                    code: "empty-series",
                    severity: .warning,
                    message: "\(emptySeriesCount) chart series contain no data points."
                )
            )
        }

        if nonFinitePointCount > 0 {
            diagnostics.append(
                ChartDiagnostic(
                    code: "non-finite-points",
                    severity: .error,
                    message: "\(nonFinitePointCount) chart data points contain non-finite x or y values."
                )
            )
        }

        if seriesWithDuplicatePointIDs > 0 {
            diagnostics.append(
                ChartDiagnostic(
                    code: "duplicate-point-ids",
                    severity: .warning,
                    message: "\(seriesWithDuplicatePointIDs) chart series contain duplicate point ids. Unique point ids within each series keep selection and animation stable."
                )
            )
        }

        if let canvasSize,
           canvasSize.width > 0,
           canvasSize.height > 0,
           canvasSize.width < minimumCanvasSize.width ||
           canvasSize.height < minimumCanvasSize.height {
            diagnostics.append(
                ChartDiagnostic(
                    code: "small-canvas",
                    severity: .warning,
                    message: "The chart canvas is too small to render reliably."
                )
            )
        }

        return diagnostics
    }

    static func reportDebugDiagnostics<Point: ChartDataPoint>(
        series: [AnyChartSeries<Point>],
        canvasSize: CGSize? = nil
    ) where Point.XValue == Double, Point.YValue == Double {
        reportDebugDiagnostics(validate(series: series, canvasSize: canvasSize))
    }

    static func reportDebugDiagnostics(_ diagnostics: [ChartDiagnostic]) {
        #if DEBUG
        for diagnostic in diagnostics where diagnostic.code != "small-canvas" {
            debugPrint("[OZCharts][\(diagnostic.severity.rawValue)] \(diagnostic.code): \(diagnostic.message)")
        }
        #endif
    }

    private static func duplicateIDs(_ ids: [UUID]) -> Set<UUID> {
        var seen: Set<UUID> = []
        var duplicates: Set<UUID> = []

        for id in ids {
            if seen.contains(id) {
                duplicates.insert(id)
            } else {
                seen.insert(id)
            }
        }

        return duplicates
    }
}
