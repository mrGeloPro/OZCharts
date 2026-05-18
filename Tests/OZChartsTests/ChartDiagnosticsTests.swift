//
//  ChartDiagnosticsTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import SwiftUI
import XCTest

final class ChartDiagnosticsTests: XCTestCase {
    func testEmptySeriesListReportsWarning() {
        let diagnostics = ChartDiagnostics.validate(
            series: [AnyChartSeries<Point2D>](),
            canvasSize: CGSize(width: 320, height: 240)
        )

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "empty-series-list", severity: .warning))
    }

    func testNonFinitePointsReportError() {
        let series = LineSeries(
            data: [
                Point2D(x: 0, y: 1),
                Point2D(x: .infinity, y: 2),
                Point2D(x: 2, y: .nan)
            ],
            color: .blue
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(series: [series])

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "non-finite-points", severity: .error))
    }

    func testDuplicateIDsReportWarnings() {
        let seriesID = UUID()
        let pointID = UUID()
        let firstSeries = LineSeries(
            data: [
                Point2D(id: pointID, x: 0, y: 1),
                Point2D(id: pointID, x: 1, y: 2)
            ],
            id: seriesID,
            color: .blue
        ).eraseToAnyChartSeries()
        let secondSeries = LineSeries(
            data: [Point2D(x: 2, y: 3)],
            id: seriesID,
            color: .green
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(series: [firstSeries, secondSeries])

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "duplicate-series-ids", severity: .warning))
        XCTAssertTrue(diagnostics.containsDiagnostic(code: "duplicate-point-ids", severity: .warning))
    }

    func testSharedPointIDsAcrossDifferentSeriesDoNotReportDuplicatePointWarning() {
        let sharedPointID = UUID()
        let data = [Point2D(id: sharedPointID, x: 0, y: 1)]
        let line = LineSeries(data: data, color: .blue).eraseToAnyChartSeries()
        let scatter = ScatterSeries(data: data, color: .green).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(series: [line, scatter])

        XCTAssertFalse(diagnostics.containsDiagnostic(code: "duplicate-point-ids", severity: .warning))
    }

    func testEmptySeriesWarningsCanBeSuppressedForIntentionalEmptyStates() {
        let series = LineSeries<Point2D>(data: [], color: .blue).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(
            series: [series],
            allowsEmptySeries: true
        )

        XCTAssertFalse(diagnostics.containsDiagnostic(code: "empty-series", severity: .warning))
    }

    func testSmallCanvasReportsWarning() {
        let series = LineSeries(
            data: [Point2D(x: 0, y: 1)],
            color: .blue
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(
            series: [series],
            canvasSize: CGSize(width: 1, height: 200)
        )

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "small-canvas", severity: .warning))
    }

    func testPlotAreaTooSmallReportsWarning() {
        let series = LineSeries(
            data: [Point2D(x: 0, y: 1)],
            color: .blue
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(
            series: [series],
            plotAreaSize: CGSize(width: 16, height: 120)
        )

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "plot-area-too-small", severity: .warning))
    }

    func testInvalidDomainReportsError() {
        let series = LineSeries(
            data: [Point2D(x: 0, y: 1)],
            color: .blue
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(
            series: [series],
            xDomain: 10 ... 10,
            yDomain: 0 ... 1
        )

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "domain-empty-or-invalid", severity: .error))
    }

    func testSeriesOutsideDomainReportsWarning() {
        let series = LineSeries(
            data: [
                Point2D(x: 0, y: 1),
                Point2D(x: 20, y: 2),
                Point2D(x: 1, y: 99)
            ],
            color: .blue
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(
            series: [series],
            xDomain: 0 ... 10,
            yDomain: 0 ... 10
        )

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "series-outside-domain", severity: .warning))
    }

    func testAxisLayoutRiskReportsWarning() {
        let series = LineSeries(
            data: [Point2D(x: 0, y: 1)],
            color: .blue
        ).eraseToAnyChartSeries()

        let diagnostics = ChartDiagnostics.validate(
            series: [series],
            plotAreaSize: CGSize(width: 100, height: 180),
            layoutInsets: ChartInsets(top: 10, leading: 90, bottom: 10, trailing: 0)
        )

        XCTAssertTrue(diagnostics.containsDiagnostic(code: "axis-layout-warning", severity: .warning))
    }

    func testRuntimeDiagnosticFactoriesUseStableCodes() {
        let missedSelection = ChartDiagnostics.selectionMissedHitbox(
            location: CGPoint(x: 12, y: 24),
            hitboxRadius: 20
        )
        let clampedTooltip = ChartDiagnostics.tooltipClamped(
            anchor: CGPoint(x: 2, y: 4),
            position: CGPoint(x: 10, y: 12)
        )

        XCTAssertEqual(missedSelection.code, "selection-missed-hitbox")
        XCTAssertEqual(clampedTooltip.code, "tooltip-clamped")
    }
}

private extension [ChartDiagnostic] {
    func containsDiagnostic(code: String, severity: ChartDiagnosticSeverity) -> Bool {
        contains { diagnostic in
            diagnostic.code == code && diagnostic.severity == severity
        }
    }
}
