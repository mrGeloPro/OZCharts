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
    private var xRangeAnnotations: [XRangeAnnotation]
    private var xyRangeAnnotations: [XYRangeAnnotation]
    private var rangeAnnotations: [RangeAnnotation]
    private var verticalAnnotations: [VerticalAnnotation]
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
        self.xRangeAnnotations = []
        self.xyRangeAnnotations = []
        self.rangeAnnotations = []
        self.verticalAnnotations = []
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
            xRangeAnnotations: xRangeAnnotations,
            xyRangeAnnotations: xyRangeAnnotations,
            rangeAnnotations: rangeAnnotations,
            verticalAnnotations: verticalAnnotations,
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

    public func donut(
        id: UUID? = nil,
        colors: [Color],
        segmentStyles: [DonutSegmentStyle] = [],
        label: String? = nil,
        segmentLabelMapper: ((Point) -> String?)? = nil,
        thickness: CGFloat = 40,
        gapAngle: Angle = .degrees(6),
        startAngle: Angle = .degrees(-90),
        lineCap: CGLineCap = .butt,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        var copy = addingSeries(
            DonutSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .donut),
                colors: colors,
                segmentStyles: segmentStyles,
                label: label,
                segmentLabelMapper: segmentLabelMapper,
                thickness: thickness,
                gapAngle: gapAngle,
                startAngle: startAngle,
                lineCap: lineCap,
                animation: animation,
                zIndex: zIndex
            )
        )
        if copy.xAxes == nil, copy.yAxes == nil {
            copy = copy.hiddenAxes()
        }
        copy.interactionOptions = .static
        return copy
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
        xRanges: [XRangeAnnotation] = [],
        xyRanges: [XYRangeAnnotation] = [],
        ranges: [RangeAnnotation] = [],
        vertical: [VerticalAnnotation] = [],
        horizontal: [HorizontalAnnotation] = [],
        points: [PointAnnotation<Double, Double>] = [],
        events: [ChartEventMarker] = [],
        customViews: [CustomViewAnnotation<Double, Double>] = []
    ) -> Self {
        var copy = self
        copy.xRangeAnnotations = xRanges
        copy.xyRangeAnnotations = xyRanges
        copy.rangeAnnotations = ranges
        copy.verticalAnnotations = vertical
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

    public func legend(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12
    ) -> Self {
        var copy = self
        copy.renderOptions.legendPosition = position
        copy.renderOptions.legendSpacing = spacing
        return copy
    }

    public func staticChart() -> Self {
        var copy = self
        copy.interactionOptions = .static
        copy.selectionOptions = .disabled
        copy.viewportOptions.showsZoomControls = false
        return copy
    }

    public func hiddenAxes() -> Self {
        var copy = self
        copy.xAxes = [.hidden()]
        copy.yAxes = [.hidden()]
        return copy
    }

    public func compactAxes(
        xTickCount: Int = 4,
        yTickCount: Int = 4,
        xPosition: XAxisPosition = .bottom,
        yPosition: YAxisPosition = .leading
    ) -> Self {
        var copy = self
        copy.xAxes = [.compact(position: xPosition, tickCount: xTickCount)]
        copy.yAxes = [.compact(position: yPosition, tickCount: yTickCount)]
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
        copy.xRangeAnnotations = xRangeAnnotations
        copy.xyRangeAnnotations = xyRangeAnnotations
        copy.rangeAnnotations = rangeAnnotations
        copy.verticalAnnotations = verticalAnnotations
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
    case donut = 0x05
    case stackedArea = 0x06
    case stackedBar = 0x07
    case violin = 0x08
}

public extension OZChart where Point: GroupedChartDataPoint {
    func stackedArea(
        id: UUID? = nil,
        stackOrder: [Point.GroupID],
        colorMapper: @escaping (Point.GroupID) -> Color,
        fillStyleMapper: ((Point.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((Point.GroupID) -> String?)? = nil,
        interpolation: LineInterpolation = .step,
        lineWidth: CGFloat = 3,
        fillOpacity: Double = 0.32,
        shadow: ChartShadowStyle? = nil,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            StackedAreaSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .stackedArea),
                stackOrder: stackOrder,
                colorMapper: colorMapper,
                fillStyleMapper: fillStyleMapper,
                groupLabel: groupLabel,
                interpolation: interpolation,
                lineWidth: lineWidth,
                fillOpacity: fillOpacity,
                shadow: shadow,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    func stackedBar(
        id: UUID? = nil,
        stackOrder: [Point.GroupID],
        colorMapper: @escaping (Point.GroupID) -> Color,
        fillStyleMapper: ((Point.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((Point.GroupID) -> String?)? = nil,
        rowLabel: ((Double) -> String?)? = nil,
        valueLabelStyle: ChartValueLabelStyle? = nil,
        barHeight: CGFloat = 28,
        cornerRadius: CGFloat = 4,
        segmentGap: CGFloat = 2,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        var copy = addingSeries(
            StackedBarSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .stackedBar),
                stackOrder: stackOrder,
                colorMapper: colorMapper,
                fillStyleMapper: fillStyleMapper,
                groupLabel: groupLabel,
                valueLabelStyle: valueLabelStyle,
                barHeight: barHeight,
                cornerRadius: cornerRadius,
                segmentGap: segmentGap,
                animation: animation,
                zIndex: zIndex
            )
        )

        if let rowLabel, copy.yAxes == nil {
            let rowValues = Array(Set(sourceData.map(\.y))).sorted()
            copy.yAxes = [.stackedBarRows(values: rowValues, rowLabel: rowLabel)]
        }
        return copy
    }

    func violin(
        id: UUID? = nil,
        centerX: Double,
        maxHalfWidth: CGFloat = 120,
        sideMapper: @escaping (Point.GroupID) -> ViolinSide,
        colorMapper: @escaping (Point.GroupID) -> Color,
        fillStyleMapper: ((Point.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((Point.GroupID) -> String?)? = nil,
        fillOpacity: Double = 0.35,
        strokeWidth: CGFloat = 1,
        showScatter: Bool = true,
        scatterSize: CGFloat = 5,
        scatterOpacity: Double = 0.9,
        shadow: ChartShadowStyle? = nil,
        bandwidth: Double? = nil,
        sampleCount: Int = 80,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            ViolinSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .violin),
                centerX: centerX,
                maxHalfWidth: maxHalfWidth,
                sideMapper: sideMapper,
                colorMapper: colorMapper,
                fillStyleMapper: fillStyleMapper,
                groupLabel: groupLabel,
                fillOpacity: fillOpacity,
                strokeWidth: strokeWidth,
                showScatter: showScatter,
                scatterSize: scatterSize,
                scatterOpacity: scatterOpacity,
                shadow: shadow,
                bandwidth: bandwidth,
                sampleCount: sampleCount,
                animation: animation,
                zIndex: zIndex
            )
        )
    }
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
