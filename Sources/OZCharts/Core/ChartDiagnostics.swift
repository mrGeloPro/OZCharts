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

public enum ChartDiagnosticCode {
    public static let emptySeriesList = "empty-series-list"
    public static let duplicateSeriesIDs = "duplicate-series-ids"
    public static let emptySeries = "empty-series"
    public static let nonFinitePoints = "non-finite-points"
    public static let duplicatePointIDs = "duplicate-point-ids"
    public static let smallCanvas = "small-canvas"
    public static let axisLayoutWarning = "axis-layout-warning"
    public static let plotAreaTooSmall = "plot-area-too-small"
    public static let selectionMissedHitbox = "selection-missed-hitbox"
    public static let tooltipClamped = "tooltip-clamped"
    public static let domainEmptyOrInvalid = "domain-empty-or-invalid"
    public static let seriesOutsideDomain = "series-outside-domain"
}

public enum ChartDiagnostics {
    public static func validate<Point: ChartDataPoint>(
        series: [AnyChartSeries<Point>],
        canvasSize: CGSize? = nil,
        minimumCanvasSize: CGSize = CGSize(width: 2, height: 2),
        plotAreaSize: CGSize? = nil,
        minimumPlotAreaSize: CGSize = CGSize(width: 24, height: 24),
        layoutInsets: ChartInsets? = nil,
        xDomain: ClosedRange<Double>? = nil,
        yDomain: ClosedRange<Double>? = nil,
        allowsEmptySeries: Bool = false
    ) -> [ChartDiagnostic] where Point.XValue == Double, Point.YValue == Double {
        var diagnostics: [ChartDiagnostic] = []

        if series.isEmpty, !allowsEmptySeries {
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.emptySeriesList,
                    severity: .warning,
                    message: "No chart series were provided."
                )
            )
        }

        let duplicateSeriesIDs = duplicateIDs(series.map(\.id))
        if !duplicateSeriesIDs.isEmpty {
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.duplicateSeriesIDs,
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
                    code: ChartDiagnosticCode.emptySeries,
                    severity: .warning,
                    message: "\(emptySeriesCount) chart series contain no data points."
                )
            )
        }

        if nonFinitePointCount > 0 {
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.nonFinitePoints,
                    severity: .error,
                    message: "\(nonFinitePointCount) chart data points contain non-finite x or y values."
                )
            )
        }

        if seriesWithDuplicatePointIDs > 0 {
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.duplicatePointIDs,
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
                    code: ChartDiagnosticCode.smallCanvas,
                    severity: .warning,
                    message: "The chart canvas is too small to render reliably."
                )
            )
        }

        if let plotAreaSize,
           plotAreaSize.width > 0,
           plotAreaSize.height > 0,
           plotAreaSize.width < minimumPlotAreaSize.width ||
           plotAreaSize.height < minimumPlotAreaSize.height {
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.plotAreaTooSmall,
                    severity: .warning,
                    message: "The plot area is too small after axes, legends, and layout insets are applied."
                )
            )
        }

        let invalidDomains = [
            xDomain.map { ("x", $0) },
            yDomain.map { ("y", $0) }
        ]
        .compactMap { $0 }
        .filter { !isValidDomain($0.1) }

        if !invalidDomains.isEmpty {
            let axes = invalidDomains.map(\.0).joined(separator: ", ")
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.domainEmptyOrInvalid,
                    severity: .error,
                    message: "The \(axes) domain is empty, inverted, or contains non-finite values."
                )
            )
        }

        if invalidDomains.isEmpty,
           xDomain != nil || yDomain != nil {
            let outsideCount = countPointsOutsideDomain(
                series: series,
                xDomain: xDomain,
                yDomain: yDomain
            )
            if outsideCount > 0 {
                diagnostics.append(
                    ChartDiagnostic(
                        code: ChartDiagnosticCode.seriesOutsideDomain,
                        severity: .warning,
                        message: "\(outsideCount) chart data points fall outside the active x/y domains and may be clipped."
                    )
                )
            }
        }

        if let layoutInsets,
           let plotAreaSize,
           hasAxisLayoutRisk(insets: layoutInsets, plotAreaSize: plotAreaSize) {
            diagnostics.append(
                ChartDiagnostic(
                    code: ChartDiagnosticCode.axisLayoutWarning,
                    severity: .warning,
                    message: "Axis layout consumes a large share of the available chart area. Consider smaller labels, labelInsets, reserved sizes, or plot insets."
                )
            )
        }

        return diagnostics
    }

    public static func selectionMissedHitbox(
        location: CGPoint,
        hitboxRadius: CGFloat
    ) -> ChartDiagnostic {
        ChartDiagnostic(
            code: ChartDiagnosticCode.selectionMissedHitbox,
            severity: .warning,
            message: "Selection did not find a point, element, or annotation near (\(rounded(location.x)), \(rounded(location.y)) within a \(rounded(hitboxRadius)) pt hitbox."
        )
    }

    public static func tooltipClamped(
        anchor: CGPoint,
        position: CGPoint
    ) -> ChartDiagnostic {
        ChartDiagnostic(
            code: ChartDiagnosticCode.tooltipClamped,
            severity: .warning,
            message: "Tooltip was clamped to remain visible. Anchor: (\(rounded(anchor.x)), \(rounded(anchor.y))), position: (\(rounded(position.x)), \(rounded(position.y)))."
        )
    }

    static func reportDebugDiagnostics<Point: ChartDataPoint>(
        series: [AnyChartSeries<Point>],
        canvasSize: CGSize? = nil
    ) where Point.XValue == Double, Point.YValue == Double {
        reportDebugDiagnostics(validate(series: series, canvasSize: canvasSize))
    }

    static func reportDebugDiagnostics(_ diagnostics: [ChartDiagnostic]) {
        #if DEBUG
        for diagnostic in diagnostics where isDebugPrintable(diagnostic) {
            debugPrint("[OZCharts][\(diagnostic.severity.rawValue)] \(diagnostic.code): \(diagnostic.message)")
        }
        #endif
    }

    private static func isDebugPrintable(_ diagnostic: ChartDiagnostic) -> Bool {
        switch diagnostic.code {
        case ChartDiagnosticCode.smallCanvas,
             ChartDiagnosticCode.seriesOutsideDomain,
             ChartDiagnosticCode.selectionMissedHitbox,
             ChartDiagnosticCode.tooltipClamped:
            false
        default:
            true
        }
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

    private static func isValidDomain(_ domain: ClosedRange<Double>) -> Bool {
        domain.lowerBound.isFinite &&
            domain.upperBound.isFinite &&
            domain.lowerBound < domain.upperBound
    }

    private static func countPointsOutsideDomain<Point: ChartDataPoint>(
        series: [AnyChartSeries<Point>],
        xDomain: ClosedRange<Double>?,
        yDomain: ClosedRange<Double>?
    ) -> Int where Point.XValue == Double, Point.YValue == Double {
        series.reduce(0) { count, chartSeries in
            count + chartSeries.data.filter { point in
                let isOutsideX = xDomain.map {
                    point.x.isFinite && (point.x < $0.lowerBound || point.x > $0.upperBound)
                } ?? false
                let isOutsideY = yDomain.map {
                    point.y.isFinite && (point.y < $0.lowerBound || point.y > $0.upperBound)
                } ?? false
                return isOutsideX || isOutsideY
            }.count
        }
    }

    private static func hasAxisLayoutRisk(
        insets: ChartInsets,
        plotAreaSize: CGSize
    ) -> Bool {
        guard plotAreaSize.width > 0, plotAreaSize.height > 0 else { return false }

        let horizontalAxisWidth = max(0, insets.leading) + max(0, insets.trailing)
        let verticalAxisHeight = max(0, insets.top) + max(0, insets.bottom)
        return horizontalAxisWidth > plotAreaSize.width * 0.75 ||
            verticalAxisHeight > plotAreaSize.height * 0.75
    }

    private static func rounded(_ value: CGFloat) -> String {
        String(format: "%.1f", Double(value))
    }
}
