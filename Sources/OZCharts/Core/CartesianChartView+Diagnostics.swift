//
//  CartesianChartView+Diagnostics.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension CartesianChartView {
    func publishDiagnostics(
        plotAreaSize: CGSize? = nil,
        layoutInsets: ChartInsets? = nil
    ) {
        let canvasSize = totalCanvasSize(plotAreaSize: plotAreaSize, layoutInsets: layoutInsets)
        let diagnostics = ChartDiagnostics.validate(
            series: series,
            canvasSize: canvasSize,
            plotAreaSize: plotAreaSize,
            layoutInsets: layoutInsets,
            xDomain: store.baseXScale.domain,
            yDomain: store.baseYScale.domain,
            allowsEmptySeries: emptyState != nil
        ) + runtimeDiagnostics
        if diagnostics != lastReportedDiagnostics {
            ChartDiagnostics.reportDebugDiagnostics(diagnostics)
            lastReportedDiagnostics = diagnostics
        }
        onDiagnosticsChanged(diagnostics)
    }

    func publishRuntimeDiagnostics(_ diagnostics: [ChartDiagnostic]) {
        runtimeDiagnostics = diagnostics
        publishDiagnostics(plotAreaSize: store.canvasSize)
    }

    func publishTooltipDiagnostics(_ diagnostics: [ChartDiagnostic]) {
        let nonTooltipDiagnostics = runtimeDiagnostics.filter {
            $0.code != ChartDiagnosticCode.tooltipClamped
        }
        runtimeDiagnostics = nonTooltipDiagnostics + diagnostics
        publishDiagnostics(plotAreaSize: store.canvasSize)
    }

    func clearRuntimeDiagnostics(codes: Set<String>) {
        let filtered = runtimeDiagnostics.filter { !codes.contains($0.code) }
        guard filtered != runtimeDiagnostics else { return }

        runtimeDiagnostics = filtered
        publishDiagnostics(plotAreaSize: store.canvasSize)
    }
}
