//
//  OZChart.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct OZChart<Point: ChartDataPoint, TooltipContent: View>: View
    where Point.XValue == Double, Point.YValue == Double {
    var sourceData: [Point]
    var series: [AnyChartSeries<Point>]
    var xDomain: ChartDomain
    var yDomain: ChartDomain
    var theme: ChartTheme
    var xAxes: [XAxisConfig]?
    var yAxes: [YAxisConfig]?
    var xRangeAnnotations: [XRangeAnnotation]
    var xyRangeAnnotations: [XYRangeAnnotation]
    var rangeAnnotations: [RangeAnnotation]
    var verticalAnnotations: [VerticalAnnotation]
    var horizontalAnnotations: [HorizontalAnnotation]
    var pointAnnotations: [PointAnnotation<Double, Double>]
    var eventMarkers: [ChartEventMarker]
    var customViewAnnotations: [CustomViewAnnotation<Double, Double>]
    var axisMarkers: [ChartAxisMarker]
    var axisMarkerSelectionOptions: ChartAxisMarkerSelectionOptions
    var interactionOptions: ChartInteractionOptions
    var selectionOptions: ChartSelectionOptions
    var selectionPriority: ChartSelectionPriority
    var isAnnotationSelectionEnabled: Bool
    var annotationHitboxRadius: CGFloat?
    var annotationOverlappingSelectionMode: ChartOverlappingSelectionMode?
    var annotationFallbackToPointSelection: Bool?
    var tooltipOptions: ChartTooltipOptions
    var viewportOptions: ChartViewportOptions
    var renderOptions: ChartRenderOptions
    var contentInsets: ChartInsets
    var plotInsets: ChartInsets
    var emptyState: (() -> AnyView)?
    var diagnosticsHandler: ([ChartDiagnostic]) -> Void
    var onSelectionChanged: ([ChartPointContext<Point>]) -> Void
    var onElementSelectionChanged: ([ChartSelectedElement]) -> Void
    var onChartSelectionChanged: (ChartSelection<Point>) -> Void
    var elementTooltipContent: ((ChartElementTooltipContext) -> AnyView)?
    var onAnnotationSelectionChanged: ([ChartAnnotationContext]) -> Void
    var onAxisMarkerSelectionChanged: ([ChartAxisMarkerContext]) -> Void
    var onEmptyTap: (CGPoint) -> Void
    var viewportBinding: Binding<ChartViewportState>?
    var selectionStateBinding: Binding<ChartSelectionState>?
    var tooltipContent: ([ChartPointContext<Point>]) -> TooltipContent

    var seriesIDs: [UUID] {
        series.map(\.id)
    }

    public init(
        _ data: [Point],
        xDomain: ChartDomain = .auto(),
        yDomain: ChartDomain = .auto(padding: 0.12),
        theme: ChartTheme = .default,
        @ViewBuilder tooltip: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) {
        self.sourceData = data
        self.series = []
        self.xDomain = xDomain
        self.yDomain = yDomain
        self.theme = theme
        self.xAxes = nil
        self.yAxes = nil
        self.xRangeAnnotations = []
        self.xyRangeAnnotations = []
        self.rangeAnnotations = []
        self.verticalAnnotations = []
        self.horizontalAnnotations = []
        self.pointAnnotations = []
        self.eventMarkers = []
        self.customViewAnnotations = []
        self.axisMarkers = []
        self.axisMarkerSelectionOptions = .disabled
        self.interactionOptions = .automatic
        self.selectionOptions = ChartSelectionOptions()
        self.selectionPriority = .annotationsFirst
        self.isAnnotationSelectionEnabled = false
        self.annotationHitboxRadius = nil
        self.annotationOverlappingSelectionMode = nil
        self.annotationFallbackToPointSelection = nil
        self.tooltipOptions = .automatic
        self.viewportOptions = .automatic
        self.renderOptions = .automatic
        self.contentInsets = .zero
        self.plotInsets = .zero
        self.emptyState = nil
        self.diagnosticsHandler = { _ in }
        self.onSelectionChanged = { _ in }
        self.onElementSelectionChanged = { _ in }
        self.onChartSelectionChanged = { _ in }
        self.elementTooltipContent = nil
        self.onAnnotationSelectionChanged = { _ in }
        self.onAxisMarkerSelectionChanged = { _ in }
        self.onEmptyTap = { _ in }
        self.viewportBinding = nil
        self.selectionStateBinding = nil
        self.tooltipContent = tooltip
    }

    public var body: some View {
        CartesianChartView(
            series: series,
            xDomain: xDomain,
            yDomain: yDomain,
            theme: theme,
            xAxes: xAxes,
            yAxes: yAxes,
            xRangeAnnotations: xRangeAnnotations,
            xyRangeAnnotations: xyRangeAnnotations,
            rangeAnnotations: rangeAnnotations,
            verticalAnnotations: verticalAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            axisMarkers: axisMarkers,
            viewport: viewportBinding,
            selectionState: selectionStateBinding,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            onChartSelectionChanged: onChartSelectionChanged,
            emptyState: emptyState,
            tooltipContent: tooltipContent
        )
        .chartInteractionOptions(interactionOptions)
        .chartSelectionOptions(selectionOptions)
        .chartAnnotationSelection(
            isAnnotationSelectionEnabled,
            hitboxRadius: annotationHitboxRadius,
            overlapping: annotationOverlappingSelectionMode,
            fallbackToPointSelection: annotationFallbackToPointSelection,
            onChange: onAnnotationSelectionChanged
        )
        .chartAxisMarkerSelection(
            axisMarkerSelectionOptions.isEnabled,
            hitboxRadius: axisMarkerSelectionOptions.hitboxRadius,
            overlapping: axisMarkerSelectionOptions.overlappingMode,
            onChange: onAxisMarkerSelectionChanged
        )
        .chartSelectionPriority(selectionPriority)
        .chartTooltipOptions(tooltipOptions)
        .chartElementTooltipIfNeeded(elementTooltipContent)
        .chartViewportOptions(viewportOptions)
        .chartRenderOptions(renderOptions)
        .chartContentInsets(contentInsets)
        .chartPlotInsets(plotInsets)
        .chartEmptyTap(onEmptyTap)
        .chartDiagnostics(onChange: diagnosticsHandler)
    }

}
