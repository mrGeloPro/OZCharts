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
    var onEmptyTap: (CGPoint) -> Void = { _ in }
    var onDiagnosticsChanged: ([ChartDiagnostic]) -> Void = { _ in }

    // MARK: - State

    @StateObject private var store: ChartStore<Point, XScale, YScale>
    @State private var highlightedAnnotations: [ChartAnnotationContext] = []
    @State private var lastGestureLocation: CGPoint?
    @State private var annotationSelectionCycle = ChartAnnotationSelectionCycle()
    @State private var customAnnotationSizes: [UUID: CGSize] = [:]
    @State private var lastReportedDiagnostics: [ChartDiagnostic] = []
    @State private var handledSeriesChangeSignature: [ChartSeriesChangeSignature]?

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

                chartWithLegend(topH: insets.top, bottomH: insets.bottom)
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

    @ViewBuilder
    private var legendView: some View {
        let items = series.flatMap(\.legendItems)
        if !items.isEmpty {
            if let customLegendContent {
                customLegendContent(items)
            } else {
                ChartLegendView(items: items, options: legendOptions)
            }
        }
    }

    @ViewBuilder
    private func chartWithLegend(topH: CGFloat, bottomH: CGFloat) -> some View {
        switch legendPosition {
        case .hidden:
            chartContent(topH: topH, bottomH: bottomH)

        case .top:
            VStack(alignment: .leading, spacing: legendSpacing) {
                legendView
                chartContent(topH: topH, bottomH: bottomH)
            }

        case .bottom:
            VStack(alignment: .leading, spacing: legendSpacing) {
                chartContent(topH: topH, bottomH: bottomH)
                legendView
            }

        case .leading:
            HStack(alignment: .top, spacing: legendSpacing) {
                legendView
                chartContent(topH: topH, bottomH: bottomH)
            }

        case .trailing:
            HStack(alignment: .top, spacing: legendSpacing) {
                chartContent(topH: topH, bottomH: bottomH)
                legendView
            }
        }
    }

    private func chartContent(topH: CGFloat, bottomH: CGFloat) -> some View {
        HStack(spacing: 0) {
            // Leading Y axes
            HStack(spacing: 0) {
                ForEach(yAxes.indices, id: \.self) { i in
                    if yAxes[i].position == .leading {
                        YAxisView(scale: store.activeYScale, config: yAxes[i])
                            .frame(width: yAxes[i].width)
                    }
                }
            }
            .padding(.top, topH).padding(.bottom, bottomH)

            VStack(spacing: 0) {
                // Top X axes
                ForEach(xAxes.indices, id: \.self) { i in
                    if xAxes[i].position == .top {
                        XAxisView(scale: store.activeXScale, config: xAxes[i])
                            .frame(height: xAxes[i].height)
                    }
                }

                // Canvas + gestures
                GeometryReader { geometry in
                    ZStack {
                        ChartCanvasView(
                            series: series.sorted { $0.zIndex < $1.zIndex },
                            seriesContexts: store.seriesContexts,
                            renderSeriesContexts: store.renderSeriesContexts,
                            oldSeriesContexts: store.oldSeriesContexts,
                            oldRenderSeriesContexts: store.oldRenderSeriesContexts,
                            animationProgress: store.animationProgress,
                            animationPhase: store.animationPhase,
                            isAnimationActive: store.isAnimationActive,
                            animationStyle: series.first?.animation ?? .none,
                            activeXScale: store.activeXScale,
                            activeYScale: store.activeYScale,
                            xAxes: xAxes,
                            yAxes: yAxes,
                            canvasRenderOrder: canvasRenderOrder,
                            xRangeAnnotations: xRangeAnnotations,
                            xyRangeAnnotations: xyRangeAnnotations,
                            rangeAnnotations: rangeAnnotations,
                            verticalAnnotations: verticalAnnotations,
                            horizontalAnnotations: horizontalAnnotations,
                            visiblePointAnnotations: visiblePointAnnotations,
                            violinBackgrounds: store.violinBackgrounds,
                            violinColorMapper: nil,
                            highlightedPoints: store.highlightedPoints,
                            selectedElementContexts: store.selectedElementContexts,
                            selectedElementStyle: selectedElementStyle,
                            crosshairStyle: crosshairStyle,
                            tooltipPlacement: tooltipPlacement,
                            tooltipAnchorPoint: resolvedTooltipAnchorPoint,
                            tooltipOffset: tooltipOffset,
                            tooltipPadding: tooltipPadding,
                            tooltipMaxWidth: tooltipMaxWidth,
                            tooltipContent: tooltipContent
                        )

                        ChartGestureHandler(
                            config: ChartGestureConfig(
                                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                                isVerticalScrollEnabled: isVerticalScrollEnabled,
                                isHorizontalZoomEnabled: isHorizontalZoomEnabled,
                                isVerticalZoomEnabled: isVerticalZoomEnabled,
                                hitboxRadius: hitboxRadius,
                                selectionBehavior: selectionBehavior,
                                selectionDismissalPolicy: selectionDismissalPolicy
                            ),
                            onEvent: { handleGestureEvent($0) }
                        )

                        let resolvedAnnotations = resolvedCustomViewAnnotations(in: geometry.size)
                        ForEach(visibleCustomViewAnnotations) { annotation in
                            if let resolved = resolvedAnnotations[annotation.id], resolved.isVisible {
                                annotation.content
                                    .fixedSize()
                                    .readSize { customAnnotationSizes[annotation.id] = $0 }
                                    .position(resolved.position)
                            } else {
                                annotation.content
                                    .fixedSize()
                                    .hidden()
                                    .readSize { customAnnotationSizes[annotation.id] = $0 }
                            }
                        }

                        if !highlightedAnnotations.isEmpty {
                            ChartAnnotationTooltipOverlay(
                                annotations: highlightedAnnotations,
                                canvasSize: geometry.size,
                                placement: tooltipPlacement,
                                anchorOverride: resolvedAnnotationTooltipAnchorPoint,
                                offset: tooltipOffset,
                                padding: tooltipPadding,
                                maxWidth: tooltipMaxWidth,
                                content: annotationTooltipContent
                            )
                            .allowsHitTesting(false)
                        }

                        if !store.selectedElements.isEmpty {
                            ChartElementTooltipOverlay(
                                elements: store.selectedElements,
                                canvasSize: geometry.size,
                                placement: tooltipPlacement,
                                anchorOverride: resolvedTooltipAnchorPoint,
                                offset: tooltipOffset,
                                padding: tooltipPadding,
                                maxWidth: tooltipMaxWidth,
                                content: elementTooltipContent
                            )
                            .allowsHitTesting(false)
                        }

                        if showsZoomControls {
                            ChartViewportControls(
                                onZoomIn: { applyProgrammaticZoom(magnification: zoomControlStep) },
                                onZoomOut: { applyProgrammaticZoom(magnification: 1 / zoomControlStep) },
                                onReset: { resetViewportFromControls() }
                            )
                            .padding(8)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .topTrailing
                            )
                        }
                    }
                    .onAppear {
                        syncBaseScales()
                        store.canvasSize = geometry.size
                        publishDiagnostics(canvasSize: geometry.size)
                        restoreBoundViewportOrInitialize()
                        publishViewportState()
                        handledSeriesChangeSignature = seriesChangeSignature
                        store.queueUpdate(
                            series: series,
                            in: geometry.size,
                            animate: false,
                            coalesce: false
                        )
                        applyBoundSelectionState(boundSelectionState)
                    }
                    .onChange(of: geometry.size) { newSize in
                        store.canvasSize = newSize
                        publishDiagnostics(canvasSize: newSize)
                        store.queueUpdate(
                            series: series,
                            in: newSize,
                            animate: false,
                            coalesce: false
                        )
                        applyBoundSelectionState(boundSelectionState)
                    }
                }

                // Bottom X axes
                ForEach(xAxes.indices, id: \.self) { i in
                    if xAxes[i].position == .bottom {
                        XAxisView(scale: store.activeXScale, config: xAxes[i])
                            .frame(height: xAxes[i].height)
                    }
                }
            }

            // Trailing Y axes
            HStack(spacing: 0) {
                ForEach(yAxes.indices, id: \.self) { i in
                    if yAxes[i].position == .trailing {
                        YAxisView(scale: store.activeYScale, config: yAxes[i])
                            .frame(width: yAxes[i].width)
                    }
                }
            }
            .padding(.top, topH).padding(.bottom, bottomH)
        }
    }

    // MARK: - Gesture handling

    private func handleGestureEvent(_ event: ChartGestureEvent) {
        syncBaseScales()

        switch event {
        case let .highlight(location):
            lastGestureLocation = location
        case .highlightCleared, .panChanged, .zoomChanged:
            lastGestureLocation = nil
        case .panEnded, .zoomEnded:
            break
        }

        switch selectionPriority {
        case .annotationsFirst:
            if handleAnnotationGestureEvent(event) {
                notifyEmptyTapIfNeeded(for: event)
                publishSelectionState()
                publishViewportState()
                return
            }
            handlePointGestureEvent(event)

        case .seriesFirst:
            applyPointGestureEvent(event)
            if case .highlight = event {
                if store.highlightedPoints.isEmpty,
                   store.selectedElements.isEmpty {
                    _ = handleAnnotationGestureEvent(event, fallbackToPointSelection: false)
                } else {
                    clearAnnotationSelection()
                }
            }
            notifySelectionChange(for: event)

        case .annotationsOnly:
            if case .highlight = event {
                _ = handleAnnotationGestureEvent(event, fallbackToPointSelection: false)
            } else {
                _ = handleAnnotationGestureEvent(event, fallbackToPointSelection: false)
                handlePointGestureEvent(event)
            }

        case .seriesOnly:
            if case .highlight = event {
                clearAnnotationSelection()
            }
            handlePointGestureEvent(event)
        }

        notifyEmptyTapIfNeeded(for: event)
        publishSelectionState()
        publishViewportState()
    }

    private func handlePointGestureEvent(_ event: ChartGestureEvent) {
        applyPointGestureEvent(event)
        notifySelectionChange(for: event)
    }

    private func applyPointGestureEvent(_ event: ChartGestureEvent) {
        store.handleGestureEvent(
            event,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            minZoomScale: minZoomScale,
            hitboxRadius: hitboxRadius,
            liveTrackingMode: liveTrackingMode,
            selectionMode: selectionMode,
            overlappingSelectionMode: overlappingSelectionMode,
            selectionDismissalPolicy: selectionDismissalPolicy,
            series: series
        )
    }

    private func notifySelectionChange(for event: ChartGestureEvent) {
        switch event {
        case .highlight, .highlightCleared, .panChanged, .zoomChanged:
            onSelectionChanged(store.highlightedPoints)
            onElementSelectionChanged(store.selectedElements)
            onChartSelectionChanged(currentSelection)
        case .panEnded, .zoomEnded:
            break
        }
    }

    private func notifyEmptyTapIfNeeded(for event: ChartGestureEvent) {
        guard case let .highlight(location) = event,
              store.highlightedPoints.isEmpty,
              store.selectedElements.isEmpty,
              highlightedAnnotations.isEmpty else { return }

        onEmptyTap(location)
    }

    private func clearAnnotationSelection() {
        guard !highlightedAnnotations.isEmpty else { return }

        highlightedAnnotations = []
        annotationSelectionCycle.reset()
        onAnnotationSelectionChanged([])
        onChartSelectionChanged(currentSelection)
    }

    private func publishDiagnostics(canvasSize: CGSize? = nil) {
        let diagnostics = ChartDiagnostics.validate(
            series: series,
            canvasSize: canvasSize,
            allowsEmptySeries: emptyState != nil
        )
        if diagnostics != lastReportedDiagnostics {
            ChartDiagnostics.reportDebugDiagnostics(diagnostics)
            lastReportedDiagnostics = diagnostics
        }
        onDiagnosticsChanged(diagnostics)
    }

    private func handleAnnotationGestureEvent(
        _ event: ChartGestureEvent,
        fallbackToPointSelection: Bool? = nil
    ) -> Bool {
        switch event {
        case let .highlight(location):
            guard isAnnotationSelectionEnabled else { return false }
            let shouldFallbackToPointSelection = fallbackToPointSelection ?? annotationFallbackToPointSelection

            var cycle = annotationSelectionCycle
            let selected = ChartAnnotationSelectionResolver.select(
                near: location,
                contexts: selectableAnnotationContexts,
                defaultRadius: annotationHitboxRadius,
                overlappingMode: annotationOverlappingSelectionMode,
                cycle: &cycle
            )
            annotationSelectionCycle = cycle

            highlightedAnnotations = selected
            onAnnotationSelectionChanged(selected)

            if !selected.isEmpty {
                store.highlightedPoints = []
                store.selectedElements = []
                store.selectedElementContexts = []
                onSelectionChanged([])
                onElementSelectionChanged([])
                onChartSelectionChanged(currentSelection)
                return true
            }

            guard shouldFallbackToPointSelection else {
                store.highlightedPoints = []
                store.selectedElements = []
                store.selectedElementContexts = []
                onSelectionChanged([])
                onElementSelectionChanged([])
                onChartSelectionChanged(currentSelection)
                return true
            }

            return false

        case .highlightCleared:
            if !highlightedAnnotations.isEmpty {
                highlightedAnnotations = []
                onAnnotationSelectionChanged([])
                onChartSelectionChanged(currentSelection)
            }
            return false

        case .panChanged, .zoomChanged:
            annotationSelectionCycle.reset()
            if !highlightedAnnotations.isEmpty {
                highlightedAnnotations = []
                onAnnotationSelectionChanged([])
                onChartSelectionChanged(currentSelection)
            }
            return false

        case .panEnded, .zoomEnded:
            return false
        }
    }

    // MARK: - Scale sync

    private func handleSeriesChange() {
        syncBaseScales()
        publishDiagnostics(canvasSize: store.canvasSize)
        store.handleDataChange(
            series: series,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            liveTrackingMode: liveTrackingMode,
            initialViewport: initialViewport,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled
        )
    }

    private func syncBaseScales() {
        store.updateBaseScales(xScale: baseXScale, yScale: baseYScale)
    }

    private func handleScaleDomainChange() {
        syncBaseScales()
        if liveTrackingMode.isEnabled {
            store.handleDataChange(
                series: series,
                isLiveTrackingEnabled: isLiveTrackingEnabled,
                liveTrackingMode: liveTrackingMode,
                initialViewport: initialViewport,
                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                isVerticalScrollEnabled: isVerticalScrollEnabled
            )
        } else {
            store.resetViewport()
            initializeViewportIfNeeded()
            store.queueUpdate(series: series, in: store.canvasSize, animate: false)
        }
        publishViewportState()
    }

    private func initializeViewportIfNeeded() {
        store.initializeViewport(
            initialViewport: initialViewport,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled
        )
    }

    private func restoreBoundViewportOrInitialize() {
        if let state = boundViewportState,
           state.visibleXDomain != nil ||
           state.visibleYDomain != nil ||
           state.command != nil {
            store.applyViewportState(state, liveTrackingMode: liveTrackingMode)
        } else {
            initializeViewportIfNeeded()
        }
    }

    private var boundViewportState: ChartViewportState? {
        viewportBinding?.wrappedValue
    }

    private var boundSelectionState: ChartSelectionState? {
        selectionStateBinding?.wrappedValue
    }

    private func applyBoundViewportState(_ state: ChartViewportState?) {
        guard let state, state != store.viewportState else { return }
        syncBaseScales()
        store.applyViewportState(
            state,
            liveTrackingMode: liveTrackingMode,
            selectionDismissalPolicy: selectionDismissalPolicy
        )
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
        publishViewportState()
    }

    private func publishViewportState() {
        let state = store.viewportState
        if viewportBinding?.wrappedValue != state {
            viewportBinding?.wrappedValue = state
        }
    }

    private func applyBoundSelectionState(_ state: ChartSelectionState?) {
        guard let state, state != store.selectionState else { return }
        store.applySelectionState(state)
        highlightedAnnotations = []
        onAnnotationSelectionChanged([])
        onSelectionChanged(store.highlightedPoints)
        onElementSelectionChanged(store.selectedElements)
        onChartSelectionChanged(currentSelection)
    }

    private func publishSelectionState() {
        let state = store.selectionState
        if selectionStateBinding?.wrappedValue != state {
            selectionStateBinding?.wrappedValue = state
        }
    }

    private var currentSelection: ChartSelection<Point> {
        ChartSelection(
            points: store.highlightedPoints,
            elements: store.selectedElements,
            annotations: highlightedAnnotations,
            state: store.selectionState
        )
    }

    private var resolvedTooltipAnchorPoint: CGPoint? {
        guard !store.highlightedPoints.isEmpty || !store.selectedElements.isEmpty else { return nil }

        switch tooltipAnchor {
        case .selectedValue:
            return nil
        case .tapLocation:
            return lastGestureLocation
        case .elementCenter:
            guard !store.selectedElements.isEmpty else { return nil }
            return ChartTooltipLayout.anchor(for: store.selectedElements.map {
                CGPoint(x: $0.bounds.midX, y: $0.bounds.midY)
            })
        case .hitPoint:
            guard !store.selectedElements.isEmpty else { return nil }
            return ChartTooltipLayout.anchor(for: store.selectedElements.map {
                $0.tooltipInteractionAnchor
            })
        }
    }

    private var resolvedAnnotationTooltipAnchorPoint: CGPoint? {
        guard !highlightedAnnotations.isEmpty else { return nil }

        switch tooltipAnchor {
        case .tapLocation, .hitPoint:
            return lastGestureLocation
        case .selectedValue, .elementCenter:
            return nil
        }
    }

    private func applyProgrammaticZoom(magnification: Double) {
        syncBaseScales()
        store.applyProgrammaticZoom(
            magnification: magnification,
            minZoomScale: minZoomScale,
            zoomX: isHorizontalZoomEnabled,
            zoomY: isVerticalZoomEnabled,
            selectionDismissalPolicy: selectionDismissalPolicy
        )
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
        publishViewportState()
    }

    private func resetViewportFromControls() {
        syncBaseScales()
        store.clearSelectionForViewportChange(selectionDismissalPolicy)
        store.resetViewport()
        initializeViewportIfNeeded()
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
        publishViewportState()
    }

    // MARK: - Off-screen culling

    private var visiblePointAnnotations: [PointAnnotation<Double, Double>] {
        let domain = store.activeXScale.domain
        let buffer = (domain.upperBound - domain.lowerBound) * 0.1
        return pointAnnotations.filter {
            $0.x >= (domain.lowerBound - buffer) && $0.x <= (domain.upperBound + buffer)
        }
    }

    private var visibleCustomViewAnnotations: [CustomViewAnnotation<Double, Double>] {
        let xDomain = store.activeXScale.domain
        let yDomain = store.activeYScale.domain
        return customViewAnnotations.filter {
            $0.x >= xDomain.lowerBound &&
                $0.x <= xDomain.upperBound &&
                $0.y >= yDomain.lowerBound &&
                $0.y <= yDomain.upperBound
        }
    }

    private func resolvedCustomViewAnnotations(
        in canvasSize: CGSize
    ) -> [UUID: ChartResolvedLabel] {
        let candidates = visibleCustomViewAnnotations.compactMap { annotation -> ChartLabelCandidate? in
            let anchor = annotationPosition(x: annotation.x, y: annotation.y)
            guard isValidCanvasPosition(anchor) else { return nil }
            let measuredSize = customAnnotationSizes[annotation.id] ?? CGSize(width: 1, height: 1)
            return ChartLabelCandidate(
                id: annotation.id,
                anchor: anchor,
                size: measuredSize,
                priority: annotation.collisionPriority,
                preferredPlacements: [annotation.placement],
                padding: annotation.padding,
                spacing: 6,
                canHide: annotation.avoidsCollisions
            )
        }

        let resolved = ChartLabelCollisionResolver.resolve(
            candidates: candidates,
            canvasSize: canvasSize
        )
        return Dictionary(uniqueKeysWithValues: resolved.map { ($0.id, $0) })
    }

    private var selectableAnnotationContexts: [ChartAnnotationContext] {
        pointAnnotationContexts + customViewAnnotationContexts
    }

    private var pointAnnotationContexts: [ChartAnnotationContext] {
        visiblePointAnnotations.compactMap { annotation in
            guard annotation.isSelectable else { return nil }
            let position = annotationPosition(x: annotation.x, y: annotation.y)
            guard isValidCanvasPosition(position) else { return nil }
            return ChartAnnotationContext(
                id: annotation.id,
                kind: .point,
                x: annotation.x,
                y: annotation.y,
                position: position,
                label: annotation.label,
                hitboxRadius: annotation.hitboxRadius ?? max(annotation.size / 2, annotationHitboxRadius)
            )
        }
    }

    private var customViewAnnotationContexts: [ChartAnnotationContext] {
        visibleCustomViewAnnotations.compactMap { annotation in
            guard annotation.isSelectable else { return nil }
            let position = annotationPosition(x: annotation.x, y: annotation.y)
            guard isValidCanvasPosition(position) else { return nil }
            return ChartAnnotationContext(
                id: annotation.id,
                kind: .customView,
                x: annotation.x,
                y: annotation.y,
                position: position,
                label: annotation.label,
                hitboxRadius: annotation.hitboxRadius
            )
        }
    }

    private func annotationPosition(x: Double, y: Double) -> CGPoint {
        CGPoint(
            x: store.activeXScale.scale(x),
            y: store.canvasSize.height - store.activeYScale.scale(y)
        )
    }

    private func isValidCanvasPosition(_ position: CGPoint) -> Bool {
        store.canvasSize.width > 0 &&
            store.canvasSize.height > 0 &&
            position.x.isFinite &&
            position.y.isFinite &&
            position.x >= 0 &&
            position.x <= store.canvasSize.width &&
            position.y >= 0 &&
            position.y <= store.canvasSize.height
    }
}

struct ChartSeriesChangeSignature: Equatable {
    let seriesID: UUID
    let zIndex: Int
    let layoutSignature: ChartSeriesSignature
    let renderSignature: ChartSeriesSignature
    let points: [ChartPointValueSignature]
}

struct ChartPointValueSignature: Equatable {
    let x: Double
    let y: Double
}

private struct ChartAnnotationTooltipOverlay: View {
    let annotations: [ChartAnnotationContext]
    let canvasSize: CGSize
    let placement: ChartTooltipPlacement
    let anchorOverride: CGPoint?
    let offset: CGPoint
    let padding: CGFloat
    let maxWidth: CGFloat?
    let content: (([ChartAnnotationContext]) -> AnyView)?

    @State private var tooltipSize: CGSize = .zero

    var body: some View {
        if let anchor = anchorOverride ?? ChartTooltipLayout.anchor(for: annotations.map(\.position)) {
            let layoutSize = measuredTooltipSize
            resolvedContent
                .frame(maxWidth: maxWidth, alignment: .center)
                .fixedSize(horizontal: maxWidth == nil, vertical: true)
                .readSize { tooltipSize = $0 }
                .position(
                    ChartTooltipLayout.resolve(
                        anchor: anchor,
                        tooltipSize: layoutSize,
                        canvasSize: canvasSize,
                        placement: placement,
                        offset: offset,
                        padding: padding
                    ).position
                )
        }
    }

    private var measuredTooltipSize: CGSize {
        guard tooltipSize.width > 0, tooltipSize.height > 0 else {
            return CGSize(width: maxWidth ?? 180, height: 72)
        }
        return tooltipSize
    }

    private var resolvedContent: some View {
        Group {
            if let content {
                content(annotations)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(annotations) { annotation in
                        Text(annotation.label ?? "\(annotation.x), \(annotation.y)")
                    }
                }
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.78))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
}

private struct ChartElementTooltipOverlay: View {
    let elements: [ChartSelectedElement]
    let canvasSize: CGSize
    let placement: ChartTooltipPlacement
    let anchorOverride: CGPoint?
    let offset: CGPoint
    let padding: CGFloat
    let maxWidth: CGFloat?
    let content: ((ChartElementTooltipContext) -> AnyView)?

    @State private var tooltipSize: CGSize = .zero

    var body: some View {
        if let anchor = resolvedAnchor {
            let layoutSize = measuredTooltipSize
            let layout = ChartTooltipLayout.resolve(
                anchor: anchor,
                tooltipSize: layoutSize,
                canvasSize: canvasSize,
                placement: placement,
                offset: offset,
                padding: padding,
                overflowAllowance: elementTooltipOverflowAllowance(for: layoutSize)
            )
            resolvedContent
                .frame(maxWidth: maxWidth, alignment: .center)
                .fixedSize(horizontal: maxWidth == nil, vertical: true)
                .readSize { tooltipSize = $0 }
                .position(layout.position)
        }
    }

    private var resolvedAnchor: CGPoint? {
        anchorOverride ?? ChartTooltipLayout.anchor(for: elements.map(\.tooltipInteractionAnchor))
    }

    private var measuredTooltipSize: CGSize {
        guard tooltipSize.width > 0, tooltipSize.height > 0 else {
            return CGSize(width: maxWidth ?? 180, height: 72)
        }
        return tooltipSize
    }

    private var resolvedContent: some View {
        Group {
            if let content {
                content(currentContext)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(elements) { element in
                        Text(element.label ?? element.groupLabel ?? formattedValue(element.value))
                    }
                }
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.78))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }

    private var currentContext: ChartElementTooltipContext {
        let anchor = anchorOverride ?? ChartTooltipLayout.anchor(for: elements.map(\.tooltipInteractionAnchor)) ?? .zero
        let layout = ChartTooltipLayout.resolve(
            anchor: anchor,
            tooltipSize: measuredTooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding,
            overflowAllowance: elementTooltipOverflowAllowance(for: measuredTooltipSize)
        )
        return ChartElementTooltipContext(
            elements: elements,
            anchor: layout.anchor,
            position: layout.position,
            arrowEdge: arrowEdge(for: layout.attachment),
            arrowXOffset: layout.anchor.x - layout.position.x,
            arrowYOffset: layout.anchor.y - layout.position.y,
            wasClamped: layout.wasClamped
        )
    }

    private func arrowEdge(for attachment: ChartTooltipAttachment) -> ChartTooltipArrowEdge {
        switch attachment {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        case .center, .fixed:
            return .none
        }
    }

    private func elementTooltipOverflowAllowance(for tooltipSize: CGSize) -> CGSize {
        CGSize(width: max(0, tooltipSize.width / 2), height: 0)
    }

    private func formattedValue(_ value: Double?) -> String {
        guard let value else { return "Selected" }
        return String(format: "%.2f", value)
    }
}

private struct ChartViewportControls: View {
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onZoomOut) {
                Image(systemName: "minus.magnifyingglass")
            }
            Button(action: onZoomIn) {
                Image(systemName: "plus.magnifyingglass")
            }
            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}
