//
//  CartesianChartView.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct CartesianChartView<
    Point: ChartDataPoint,
    XScale: Scale,
    YScale: Scale,
    TooltipContent: View
>: View
    where XScale.InputType == Point.XValue, XScale.OutputType == CGFloat,
    YScale.InputType == Point.YValue, YScale.OutputType == CGFloat,
    Point.XValue == Double, Point.YValue == Double {
    // MARK: - Inputs

    let series: [AnyChartSeries<Point>]

    var xAxes: [XAxisConfig]
    var yAxes: [YAxisConfig]
    let xRangeAnnotations: [XRangeAnnotation]
    let xyRangeAnnotations: [XYRangeAnnotation]
    let rangeAnnotations: [RangeAnnotation]
    let verticalAnnotations: [VerticalAnnotation]
    let horizontalAnnotations: [HorizontalAnnotation]
    let pointAnnotations: [PointAnnotation<Double, Double>]
    let customViewAnnotations: [CustomViewAnnotation<Double, Double>]
    var axisMarkers: [ChartAxisMarker]

    var baseXScale: XScale
    var baseYScale: YScale

    // MARK: - Options

    public var isHorizontalScrollEnabled: Bool = true
    public var isVerticalScrollEnabled: Bool = true
    public var isHorizontalZoomEnabled: Bool = true
    public var isVerticalZoomEnabled: Bool = true
    public var isLiveTrackingEnabled: Bool = false
    public var liveTrackingMode: ChartLiveTrackingMode = .disabled
    public var initialViewport: ChartInitialViewport?
    var viewportBinding: Binding<ChartViewportState>?
    var selectionStateBinding: Binding<ChartSelectionState>?

    public var hitboxRadius: CGFloat = 20
    public var selectionMode: ChartSelectionMode = .pointsInRadius
    public var selectionBehavior: ChartSelectionBehavior = .tap
    public var selectionActivation: ChartSelectionActivation = .immediate
    public var nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded
    public var overlappingSelectionMode: ChartOverlappingSelectionMode = .all
    public var selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient
    public var isAnnotationSelectionEnabled: Bool = false
    public var annotationHitboxRadius: CGFloat = 24
    public var annotationOverlappingSelectionMode: ChartOverlappingSelectionMode = .cycle
    public var annotationFallbackToPointSelection: Bool = true
    public var selectionPriority: ChartSelectionPriority = .annotationsFirst
    public var crosshairStyle: ChartCrosshairStyle = .hidden
    public var tooltipPlacement: ChartTooltipPlacement = .automatic
    public var tooltipAnchor: ChartTooltipAnchor = .selectedValue
    public var tooltipOffset: CGPoint = CGPoint(x: 0, y: -20)
    public var tooltipPadding: CGFloat = 8
    public var tooltipMaxWidth: CGFloat?
    public var minZoomScale: Double = 0.05
    public var showsZoomControls: Bool = false
    public var zoomControlStep: Double = 2
    public var legendOptions: ChartLegendOptions = .hidden
    public var legendPosition: ChartLegendPosition {
        get { legendOptions.position }
        set { legendOptions.position = newValue }
    }
    public var legendSpacing: CGFloat {
        get { legendOptions.itemSpacing }
        set { legendOptions.itemSpacing = newValue }
    }
    public var selectedElementStyle: ChartSelectedElementStyle = .product
    public var canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart]
    public var plotBorderStyle: ChartPlotBorderStyle = .hidden
    public var contentInsets: ChartInsets = .zero
    public var plotInsets: ChartInsets = .zero
    public var axisMarkerSelectionOptions: ChartAxisMarkerSelectionOptions = .disabled
    public var emptyState: (() -> AnyView)?
    var customLegendContent: (([ChartLegendItem]) -> AnyView)?
    var accessibilityDescriptor: ChartAccessibilityDescriptor<Point>?

    let tooltipContent: ([ChartPointContext<Point>]) -> TooltipContent
    var onSelectionChanged: ([ChartPointContext<Point>]) -> Void
    var onElementSelectionChanged: ([ChartSelectedElement]) -> Void = { _ in }
    var onChartSelectionChanged: (ChartSelection<Point>) -> Void = { _ in }
    var elementTooltipContent: ((ChartElementTooltipContext) -> AnyView)?
    var annotationTooltipContent: (([ChartAnnotationContext]) -> AnyView)?
    var onAnnotationSelectionChanged: ([ChartAnnotationContext]) -> Void = { _ in }
    var onAxisMarkerSelectionChanged: ([ChartAxisMarkerContext]) -> Void = { _ in }
    var onEmptyTap: (CGPoint) -> Void = { _ in }
    var onDiagnosticsChanged: ([ChartDiagnostic]) -> Void = { _ in }

    // MARK: - State

    @StateObject var store: ChartStore<Point, XScale, YScale>
    @State var highlightedAnnotations: [ChartAnnotationContext] = []
    @State var highlightedAxisMarkers: [ChartAxisMarkerContext] = []
    @State var lastGestureLocation: CGPoint?
    @State var annotationSelectionCycle = ChartAnnotationSelectionCycle()
    @State var axisMarkerSelectionCycle = ChartAxisMarkerSelectionCycle()
    @State var customAnnotationSizes: [UUID: CGSize] = [:]
    @State var axisMarkerSizes: [UUID: CGSize] = [:]
    @State var axisMarkerCompactSizes: [UUID: CGSize] = [:]
    @State var lastReportedDiagnostics: [ChartDiagnostic] = []
    @State var runtimeDiagnostics: [ChartDiagnostic] = []
    @State var handledSeriesChangeSignature: [ChartSeriesChangeSignature]?

    var seriesChangeSignature: [ChartSeriesChangeSignature] {
        series.map { series in
            ChartSeriesChangeSignature(
                seriesID: series.id,
                zIndex: series.zIndex,
                layoutSignature: series.layoutSignature,
                renderSignature: series.renderSignature,
                points: series.data.map { ChartPointValueSignature(x: $0.x, y: $0.y) }
            )
        }
    }

    // MARK: - Init

    public init(
        series: [AnyChartSeries<Point>],
        xScale: XScale,
        yScale: YScale,
        xAxes: [XAxisConfig] = [.init(position: .bottom)],
        yAxes: [YAxisConfig] = [.init(position: .leading)],
        xRangeAnnotations: [XRangeAnnotation] = [],
        xyRangeAnnotations: [XYRangeAnnotation] = [],
        rangeAnnotations: [RangeAnnotation] = [],
        verticalAnnotations: [VerticalAnnotation] = [],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Double, Double>] = [],
        eventMarkers: [ChartEventMarker] = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        axisMarkers: [ChartAxisMarker] = [],
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        liveTrackingMode: ChartLiveTrackingMode? = nil,
        initialViewport: ChartInitialViewport? = nil,
        viewport: Binding<ChartViewportState>? = nil,
        selectionState: Binding<ChartSelectionState>? = nil,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior = .tap,
        selectionActivation: ChartSelectionActivation = .immediate,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient,
        crosshairStyle: ChartCrosshairStyle = .hidden,
        tooltipPlacement: ChartTooltipPlacement = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        onChartSelectionChanged: @escaping (ChartSelection<Point>) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)? = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) {
        self.series = series
        self.baseXScale = xScale
        self.baseYScale = yScale
        self._store = StateObject(wrappedValue: ChartStore(xScale: xScale, yScale: yScale))
        self.xAxes = xAxes
        self.yAxes = yAxes
        self.xRangeAnnotations = xRangeAnnotations
        self.xyRangeAnnotations = xyRangeAnnotations
        self.rangeAnnotations = rangeAnnotations
        self.verticalAnnotations = verticalAnnotations
        self.horizontalAnnotations = horizontalAnnotations
        self.pointAnnotations = pointAnnotations + eventMarkers.map(\.pointAnnotation)
        self.customViewAnnotations = customViewAnnotations
        self.axisMarkers = axisMarkers
        self.isHorizontalScrollEnabled = isHorizontalScrollEnabled
        self.isHorizontalZoomEnabled = isHorizontalZoomEnabled
        self.isVerticalScrollEnabled = isVerticalScrollEnabled
        self.isVerticalZoomEnabled = isVerticalZoomEnabled
        let resolvedLiveTrackingMode = liveTrackingMode ??
            (isLiveTrackingEnabled ? .followLatest() : .disabled)
        self.isLiveTrackingEnabled = resolvedLiveTrackingMode.isEnabled
        self.liveTrackingMode = resolvedLiveTrackingMode
        self.initialViewport = initialViewport
        self.viewportBinding = viewport
        self.selectionStateBinding = selectionState
        self.selectionMode = selectionMode
        self.selectionBehavior = selectionBehavior
        self.selectionActivation = selectionActivation
        self.nearestSelectionPolicy = nearestSelectionPolicy
        self.overlappingSelectionMode = overlappingSelectionMode
        self.selectionDismissalPolicy = selectionDismissalPolicy
        self.crosshairStyle = crosshairStyle
        self.tooltipPlacement = tooltipPlacement
        self.onSelectionChanged = onSelectionChanged
        self.onElementSelectionChanged = onElementSelectionChanged
        self.onChartSelectionChanged = onChartSelectionChanged
        self.canvasRenderOrder = canvasRenderOrder
        self.emptyState = emptyState
        self.tooltipContent = tooltipContent
    }

    public init<S: ChartSeriesProtocol>(
        series: [S],
        xScale: XScale,
        yScale: YScale,
        xAxes: [XAxisConfig] = [.init(position: .bottom)],
        yAxes: [YAxisConfig] = [.init(position: .leading)],
        xRangeAnnotations: [XRangeAnnotation] = [],
        xyRangeAnnotations: [XYRangeAnnotation] = [],
        rangeAnnotations: [RangeAnnotation] = [],
        verticalAnnotations: [VerticalAnnotation] = [],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Double, Double>] = [],
        eventMarkers: [ChartEventMarker] = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        axisMarkers: [ChartAxisMarker] = [],
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        liveTrackingMode: ChartLiveTrackingMode? = nil,
        initialViewport: ChartInitialViewport? = nil,
        viewport: Binding<ChartViewportState>? = nil,
        selectionState: Binding<ChartSelectionState>? = nil,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior = .tap,
        selectionActivation: ChartSelectionActivation = .immediate,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient,
        crosshairStyle: ChartCrosshairStyle = .hidden,
        tooltipPlacement: ChartTooltipPlacement = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        onChartSelectionChanged: @escaping (ChartSelection<Point>) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)? = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) where S.Point == Point {
        self.init(
            series: series.map(AnyChartSeries.init),
            xScale: xScale,
            yScale: yScale,
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
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            liveTrackingMode: liveTrackingMode,
            initialViewport: initialViewport,
            viewport: viewport,
            selectionState: selectionState,
            selectionMode: selectionMode,
            selectionBehavior: selectionBehavior,
            selectionActivation: selectionActivation,
            nearestSelectionPolicy: nearestSelectionPolicy,
            overlappingSelectionMode: overlappingSelectionMode,
            selectionDismissalPolicy: selectionDismissalPolicy,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            onChartSelectionChanged: onChartSelectionChanged,
            canvasRenderOrder: canvasRenderOrder,
            emptyState: emptyState,
            tooltipContent: tooltipContent
        )
    }

    // MARK: - Body

    public var body: some View {
        let allData = series.flatMap(\.data)

        Group {
            if allData.isEmpty, let emptyView = emptyState?() {
                emptyView.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let insets = ChartLayoutEngine.measuredInsets(xAxes: xAxes, yAxes: yAxes)

                chartWithLegend(layoutInsets: insets)
            }
        }
        .task(id: seriesChangeSignature) {
            await MainActor.run {
                guard handledSeriesChangeSignature != seriesChangeSignature else { return }
                handledSeriesChangeSignature = seriesChangeSignature
                handleSeriesChange()
            }
        }
        .onChange(of: baseXScale.domain) { _ in
            handleScaleDomainChange()
        }
        .onChange(of: baseYScale.domain) { _ in
            handleScaleDomainChange()
        }
        .onChange(of: boundViewportState) { newState in
            applyBoundViewportState(newState)
        }
        .onChange(of: boundSelectionState) { newState in
            applyBoundSelectionState(newState)
        }
        .accessibilityElement(children: accessibilityDescriptor == nil ? .contain : .ignore)
        .accessibilityLabel(accessibilityDescriptor?.label ?? "")
        .accessibilityValue(accessibilityDescriptor?.value(
            for: store.highlightedPoints,
            selectedElements: store.selectedElements
        ) ?? "")
    }
}
