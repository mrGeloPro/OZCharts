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
    private var sourceData: [Point]
    private var series: [AnyChartSeries<Point>]
    private var xDomain: ChartDomain
    private var yDomain: ChartDomain
    private var theme: ChartTheme
    private var xAxes: [XAxisConfig]?
    private var yAxes: [YAxisConfig]?
    private var rangeAnnotations: [RangeAnnotation]
    private var horizontalAnnotations: [HorizontalAnnotation]
    private var pointAnnotations: [PointAnnotation<Double, Double>]
    private var eventMarkers: [ChartEventMarker]
    private var customViewAnnotations: [CustomViewAnnotation<Double, Double>]
    private var interactionOptions: ChartInteractionOptions
    private var selectionOptions: ChartSelectionOptions
    private var tooltipOptions: ChartTooltipOptions
    private var viewportOptions: ChartViewportOptions
    private var renderOptions: ChartRenderOptions
    private var emptyState: (() -> AnyView)?
    private var diagnosticsHandler: ([ChartDiagnostic]) -> Void
    private var onSelectionChanged: ([ChartPointContext<Point>]) -> Void
    private var onElementSelectionChanged: ([ChartSelectedElement]) -> Void
    private var viewportBinding: Binding<ChartViewportState>?
    private var selectionStateBinding: Binding<ChartSelectionState>?
    private var tooltipContent: ([ChartPointContext<Point>]) -> TooltipContent

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
        self.rangeAnnotations = []
        self.horizontalAnnotations = []
        self.pointAnnotations = []
        self.eventMarkers = []
        self.customViewAnnotations = []
        self.interactionOptions = .automatic
        self.selectionOptions = ChartSelectionOptions()
        self.tooltipOptions = .automatic
        self.viewportOptions = .automatic
        self.renderOptions = .automatic
        self.emptyState = nil
        self.diagnosticsHandler = { _ in }
        self.onSelectionChanged = { _ in }
        self.onElementSelectionChanged = { _ in }
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
            rangeAnnotations: rangeAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            viewport: viewportBinding,
            selectionState: selectionStateBinding,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            emptyState: emptyState,
            tooltipContent: tooltipContent
        )
        .chartInteractionOptions(interactionOptions)
        .chartSelectionOptions(selectionOptions)
        .chartTooltipOptions(tooltipOptions)
        .chartViewportOptions(viewportOptions)
        .chartRenderOptions(renderOptions)
        .chartDiagnostics(onChange: diagnosticsHandler)
    }

    public func line(
        id: UUID? = nil,
        color: Color,
        label: String? = nil,
        lineWidth: CGFloat = 2,
        interpolation: LineInterpolation = .linear,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            LineSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .line),
                color: color,
                label: label,
                lineWidth: lineWidth,
                interpolation: interpolation,
                downsampling: downsampling,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    public func area(
        id: UUID? = nil,
        color: Color,
        fillColor: Color? = nil,
        label: String? = nil,
        fillOpacity: Double = 0.2,
        interpolation: LineInterpolation = .linear,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            AreaSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .area),
                color: color,
                fillColor: fillColor ?? color,
                fillOpacity: fillOpacity,
                label: label,
                interpolation: interpolation,
                downsampling: downsampling,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    public func bar(
        id: UUID? = nil,
        color: Color,
        label: String? = nil,
        barWidth: CGFloat = 10,
        cornerRadius: CGFloat = 2,
        baseline: Double = 0,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            BarSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .bar),
                color: color,
                label: label,
                barWidth: barWidth,
                cornerRadius: cornerRadius,
                baseline: baseline,
                zIndex: zIndex
            )
        )
    }

    public func scatter(
        id: UUID? = nil,
        color: Color,
        label: String? = nil,
        pointSize: CGFloat = 6,
        symbol: ChartSymbolShape = .circle,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            ScatterSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .scatter),
                color: color,
                label: label,
                pointSize: pointSize,
                symbol: symbol,
                zIndex: zIndex
            )
        )
    }

    public func domain(
        x: ChartDomain? = nil,
        y: ChartDomain? = nil
    ) -> Self {
        var copy = self
        if let x {
            copy.xDomain = x
        }
        if let y {
            copy.yDomain = y
        }
        return copy
    }

    public func axes(
        x: [XAxisConfig]? = nil,
        y: [YAxisConfig]? = nil
    ) -> Self {
        var copy = self
        copy.xAxes = x
        copy.yAxes = y
        return copy
    }

    public func annotations(
        ranges: [RangeAnnotation] = [],
        horizontal: [HorizontalAnnotation] = [],
        points: [PointAnnotation<Double, Double>] = [],
        events: [ChartEventMarker] = [],
        customViews: [CustomViewAnnotation<Double, Double>] = []
    ) -> Self {
        var copy = self
        copy.rangeAnnotations = ranges
        copy.horizontalAnnotations = horizontal
        copy.pointAnnotations = points
        copy.eventMarkers = events
        copy.customViewAnnotations = customViews
        return copy
    }

    public func interaction(_ options: ChartInteractionOptions) -> Self {
        var copy = self
        copy.interactionOptions = options
        return copy
    }

    public func selection(_ options: ChartSelectionOptions) -> Self {
        var copy = self
        copy.selectionOptions = options
        return copy
    }

    public func tooltipOptions(_ options: ChartTooltipOptions) -> Self {
        var copy = self
        copy.tooltipOptions = options
        return copy
    }

    public func viewport(_ options: ChartViewportOptions) -> Self {
        var copy = self
        copy.viewportOptions = options
        return copy
    }

    public func rendering(_ options: ChartRenderOptions) -> Self {
        var copy = self
        copy.renderOptions = options
        return copy
    }

    public func viewportState(_ viewport: Binding<ChartViewportState>) -> Self {
        var copy = self
        copy.viewportBinding = viewport
        return copy
    }

    public func selectionState(_ selectionState: Binding<ChartSelectionState>) -> Self {
        var copy = self
        copy.selectionStateBinding = selectionState
        return copy
    }

    public func onSelectionChanged(
        _ handler: @escaping ([ChartPointContext<Point>]) -> Void
    ) -> Self {
        var copy = self
        copy.onSelectionChanged = handler
        return copy
    }

    public func onElementSelectionChanged(
        _ handler: @escaping ([ChartSelectedElement]) -> Void
    ) -> Self {
        var copy = self
        copy.onElementSelectionChanged = handler
        return copy
    }

    public func emptyState(
        @ViewBuilder _ content: @escaping () -> some View
    ) -> Self {
        var copy = self
        copy.emptyState = { AnyView(content()) }
        return copy
    }

    public func diagnostics(
        onChange: @escaping ([ChartDiagnostic]) -> Void
    ) -> Self {
        var copy = self
        copy.diagnosticsHandler = onChange
        return copy
    }

    public func tooltip<Content: View>(
        @ViewBuilder _ content: @escaping ([ChartPointContext<Point>]) -> Content
    ) -> OZChart<Point, Content> {
        var copy = OZChart<Point, Content>(
            sourceData,
            xDomain: xDomain,
            yDomain: yDomain,
            theme: theme,
            tooltip: content
        )
        copy.series = series
        copy.xAxes = xAxes
        copy.yAxes = yAxes
        copy.rangeAnnotations = rangeAnnotations
        copy.horizontalAnnotations = horizontalAnnotations
        copy.pointAnnotations = pointAnnotations
        copy.eventMarkers = eventMarkers
        copy.customViewAnnotations = customViewAnnotations
        copy.interactionOptions = interactionOptions
        copy.selectionOptions = selectionOptions
        copy.tooltipOptions = tooltipOptions
        copy.viewportOptions = viewportOptions
        copy.renderOptions = renderOptions
        copy.emptyState = emptyState
        copy.diagnosticsHandler = diagnosticsHandler
        copy.onSelectionChanged = onSelectionChanged
        copy.onElementSelectionChanged = onElementSelectionChanged
        copy.viewportBinding = viewportBinding
        copy.selectionStateBinding = selectionStateBinding
        return copy
    }

    private func addingSeries<S: ChartSeriesProtocol>(_ chartSeries: S) -> Self where S.Point == Point {
        var copy = self
        copy.series.append(chartSeries.eraseToAnyChartSeries())
        return copy
    }

    private func defaultSeriesID(kind: OZChartSeriesKind) -> UUID {
        stableSeriesID(kind: kind, index: series.count)
    }

    private func stableSeriesID(kind: OZChartSeriesKind, index: Int) -> UUID {
        let value = UInt64(index)
        return UUID(
            uuid: (
                0x4F, 0x5A, 0x43, 0x68,
                0x61, 0x72,
                kind.rawValue,
                0x00,
                UInt8((value >> 56) & 0xFF),
                UInt8((value >> 48) & 0xFF),
                UInt8((value >> 40) & 0xFF),
                UInt8((value >> 32) & 0xFF),
                UInt8((value >> 24) & 0xFF),
                UInt8((value >> 16) & 0xFF),
                UInt8((value >> 8) & 0xFF),
                UInt8(value & 0xFF)
            )
        )
    }
}

private enum OZChartSeriesKind: UInt8 {
    case line = 0x01
    case area = 0x02
    case bar = 0x03
    case scatter = 0x04
}

public extension OZChart where TooltipContent == EmptyView {
    init(
        _ data: [Point],
        xDomain: ChartDomain = .auto(),
        yDomain: ChartDomain = .auto(padding: 0.12),
        theme: ChartTheme = .default
    ) {
        self.init(
            data,
            xDomain: xDomain,
            yDomain: yDomain,
            theme: theme
        ) { _ in
            EmptyView()
        }
    }
}
