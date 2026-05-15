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
}

private extension [ChartDiagnostic] {
    func containsDiagnostic(code: String, severity: ChartDiagnosticSeverity) -> Bool {
        contains { diagnostic in
            diagnostic.code == code && diagnostic.severity == severity
        }
    }
}
