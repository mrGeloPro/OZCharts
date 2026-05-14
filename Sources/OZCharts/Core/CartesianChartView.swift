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

    let xAxes: [XAxisConfig]
    let yAxes: [YAxisConfig]
    let rangeAnnotations: [RangeAnnotation]
    let horizontalAnnotations: [HorizontalAnnotation]
    let pointAnnotations: [PointAnnotation<Double, Double>]
    let customViewAnnotations: [CustomViewAnnotation<Double, Double>]

    var baseXScale: XScale
    var baseYScale: YScale

    // MARK: - Options

    public var isHorizontalScrollEnabled: Bool = true
    public var isVerticalScrollEnabled:   Bool = true
    public var isHorizontalZoomEnabled:   Bool = true
    public var isVerticalZoomEnabled:     Bool = true
    public var isLiveTrackingEnabled:     Bool = false
    public var initialViewport: ChartInitialViewport?
    var viewportBinding: Binding<ChartViewportState>?
    var selectionStateBinding: Binding<ChartSelectionState>?

    public var hitboxRadius:    CGFloat    = 20
    public var selectionMode:   ChartSelectionMode = .pointsInRadius
    public var selectionBehavior: ChartSelectionBehavior = .tap
    public var overlappingSelectionMode: ChartOverlappingSelectionMode = .all
    public var clearsSelectionOnGestureEnd: Bool = true
    public var isAnnotationSelectionEnabled: Bool = false
    public var annotationHitboxRadius: CGFloat = 24
    public var annotationOverlappingSelectionMode: ChartOverlappingSelectionMode = .cycle
    public var crosshairStyle:  ChartCrosshairStyle = .hidden
    public var tooltipPlacement: ChartTooltipPlacement = .automatic
    public var tooltipOffset:   CGPoint    = CGPoint(x: 0, y: -20)
    public var tooltipPadding:  CGFloat = 8
    public var tooltipMaxWidth: CGFloat?
    public var minZoomScale:    Double     = 0.01
    public var showsZoomControls: Bool = false
    public var zoomControlStep: Double = 2
    public var legendPosition:  ChartLegendPosition = .hidden
    public var legendSpacing:   CGFloat = 12
    public var canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart]
    public var emptyState: (() -> AnyView)?
    var customLegendContent: (([ChartLegendItem]) -> AnyView)?
    var accessibilityDescriptor: ChartAccessibilityDescriptor<Point>?

    let tooltipContent: ([ChartPointContext<Point>]) -> TooltipContent
    var onSelectionChanged: ([ChartPointContext<Point>]) -> Void
    var onElementSelectionChanged: ([ChartSelectedElement]) -> Void = { _ in }
    var annotationTooltipContent: (([ChartAnnotationContext]) -> AnyView)?
    var onAnnotationSelectionChanged: ([ChartAnnotationContext]) -> Void = { _ in }

    // MARK: - State

    @StateObject private var store: ChartStore<Point, XScale, YScale>
    @State private var highlightedAnnotations: [ChartAnnotationContext] = []
    @State private var annotationSelectionCycle = ChartAnnotationSelectionCycle()

    // MARK: - Init

    public init(
        series: [AnyChartSeries<Point>],
        xScale: XScale,
        yScale: YScale,
        xAxes: [XAxisConfig]                                  = [.init(position: .bottom)],
        yAxes: [YAxisConfig]                                  = [.init(position: .leading)],
        rangeAnnotations: [RangeAnnotation]                   = [],
        horizontalAnnotations: [HorizontalAnnotation]         = [],
        pointAnnotations: [PointAnnotation<Double, Double>]   = [],
        eventMarkers: [ChartEventMarker]                      = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        isHorizontalScrollEnabled: Bool                       = true,
        isHorizontalZoomEnabled: Bool                         = true,
        isVerticalScrollEnabled: Bool                         = true,
        isVerticalZoomEnabled: Bool                           = true,
        isLiveTrackingEnabled: Bool                           = false,
        initialViewport: ChartInitialViewport?                = nil,
        viewport: Binding<ChartViewportState>?                = nil,
        selectionState: Binding<ChartSelectionState>?         = nil,
        selectionMode: ChartSelectionMode                     = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior             = .tap,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        clearsSelectionOnGestureEnd: Bool                     = true,
        crosshairStyle: ChartCrosshairStyle                   = .hidden,
        tooltipPlacement: ChartTooltipPlacement               = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer]                      = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)?                          = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) {
        self.series                    = series
        self.baseXScale                = xScale
        self.baseYScale                = yScale
        self._store                    = StateObject(wrappedValue: ChartStore(xScale: xScale, yScale: yScale))
        self.xAxes                     = xAxes
        self.yAxes                     = yAxes
        self.rangeAnnotations          = rangeAnnotations
        self.horizontalAnnotations     = horizontalAnnotations
        self.pointAnnotations          = pointAnnotations + eventMarkers.map(\.pointAnnotation)
        self.customViewAnnotations     = customViewAnnotations
        self.isHorizontalScrollEnabled = isHorizontalScrollEnabled
        self.isHorizontalZoomEnabled   = isHorizontalZoomEnabled
        self.isVerticalScrollEnabled   = isVerticalScrollEnabled
        self.isVerticalZoomEnabled     = isVerticalZoomEnabled
        self.isLiveTrackingEnabled     = isLiveTrackingEnabled
        self.initialViewport           = initialViewport
        self.viewportBinding           = viewport
        self.selectionStateBinding     = selectionState
        self.selectionMode             = selectionMode
        self.selectionBehavior         = selectionBehavior
        self.overlappingSelectionMode  = overlappingSelectionMode
        self.clearsSelectionOnGestureEnd = clearsSelectionOnGestureEnd
        self.crosshairStyle            = crosshairStyle
        self.tooltipPlacement          = tooltipPlacement
        self.onSelectionChanged        = onSelectionChanged
        self.onElementSelectionChanged = onElementSelectionChanged
        self.canvasRenderOrder         = canvasRenderOrder
        self.emptyState                = emptyState
        self.tooltipContent            = tooltipContent
    }

    public init<S: ChartSeriesProtocol>(
        series: [S],
        xScale: XScale,
        yScale: YScale,
        xAxes: [XAxisConfig]                                  = [.init(position: .bottom)],
        yAxes: [YAxisConfig]                                  = [.init(position: .leading)],
        rangeAnnotations: [RangeAnnotation]                   = [],
        horizontalAnnotations: [HorizontalAnnotation]         = [],
        pointAnnotations: [PointAnnotation<Double, Double>]   = [],
        eventMarkers: [ChartEventMarker]                      = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        isHorizontalScrollEnabled: Bool                       = true,
        isHorizontalZoomEnabled: Bool                         = true,
        isVerticalScrollEnabled: Bool                         = true,
        isVerticalZoomEnabled: Bool                           = true,
        isLiveTrackingEnabled: Bool                           = false,
        initialViewport: ChartInitialViewport?                = nil,
        viewport: Binding<ChartViewportState>?                = nil,
        selectionState: Binding<ChartSelectionState>?         = nil,
        selectionMode: ChartSelectionMode                     = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior             = .tap,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        clearsSelectionOnGestureEnd: Bool                     = true,
        crosshairStyle: ChartCrosshairStyle                   = .hidden,
        tooltipPlacement: ChartTooltipPlacement               = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer]                      = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)?                          = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) where S.Point == Point {
        self.init(
            series: series.map(AnyChartSeries.init),
            xScale: xScale,
            yScale: yScale,
            xAxes: xAxes,
            yAxes: yAxes,
            rangeAnnotations: rangeAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            initialViewport: initialViewport,
            viewport: viewport,
            selectionState: selectionState,
            selectionMode: selectionMode,
            selectionBehavior: selectionBehavior,
            overlappingSelectionMode: overlappingSelectionMode,
            clearsSelectionOnGestureEnd: clearsSelectionOnGestureEnd,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            canvasRenderOrder: canvasRenderOrder,
            emptyState: emptyState,
            tooltipContent: tooltipContent
        )
    }

    // MARK: - Body

    public var body: some View {
        let allData = series.flatMap { $0.data }

        Group {
            if allData.isEmpty, let emptyView = emptyState?() {
                emptyView.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let topH    = xAxes.filter { $0.position == .top      }.reduce(0) { $0 + $1.height }
                let bottomH = xAxes.filter { $0.position == .bottom   }.reduce(0) { $0 + $1.height }

                chartWithLegend(topH: topH, bottomH: bottomH)
            }
        }
        .onChange(of: series.map { $0.id }) { _ in
            syncBaseScales()
            store.handleDataChange(
                series: series,
                isLiveTrackingEnabled: isLiveTrackingEnabled,
                initialViewport: initialViewport,
                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                isVerticalScrollEnabled: isVerticalScrollEnabled
            )
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
                ChartLegendView(items: items, spacing: legendSpacing)
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
                                    series:                    series.sorted { $0.zIndex < $1.zIndex },
                                    seriesContexts:            store.seriesContexts,
                                    oldSeriesContexts:         store.oldSeriesContexts,
                                    animationProgress:         store.animationProgress,
                                    isAnimationActive:         store.isAnimationActive,
                                    animationStyle:            series.first?.animation ?? .none,
                                    activeXScale:              store.activeXScale,
                                    activeYScale:              store.activeYScale,
                                    xAxes:                     xAxes,
                                    yAxes:                     yAxes,
                                    canvasRenderOrder:         canvasRenderOrder,
                                    rangeAnnotations:          rangeAnnotations,
                                    horizontalAnnotations:     horizontalAnnotations,
                                    visiblePointAnnotations:   visiblePointAnnotations,
                                    violinBackgrounds:         store.violinBackgrounds,
                                    violinColorMapper:         nil,
                                    highlightedPoints:         store.highlightedPoints,
                                    crosshairStyle:            crosshairStyle,
                                    tooltipPlacement:          tooltipPlacement,
                                    tooltipOffset:             tooltipOffset,
                                    tooltipPadding:            tooltipPadding,
                                    tooltipMaxWidth:           tooltipMaxWidth,
                                    tooltipContent:            tooltipContent
                                )

                                ChartGestureHandler(
                                    config: ChartGestureConfig(
                                        isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                                        isVerticalScrollEnabled:   isVerticalScrollEnabled,
                                        isHorizontalZoomEnabled:   isHorizontalZoomEnabled,
                                        isVerticalZoomEnabled:     isVerticalZoomEnabled,
                                        hitboxRadius:              hitboxRadius,
                                        selectionBehavior:         selectionBehavior,
                                        clearsSelectionOnGestureEnd: clearsSelectionOnGestureEnd
                                    ),
                                    onEvent: { handleGestureEvent($0) }
                                )

                                ForEach(visibleCustomViewAnnotations) { annotation in
                                    let xPos = store.activeXScale.scale(annotation.x)
                                    let yPos = geometry.size.height - store.activeYScale.scale(annotation.y)
                                    if geometry.size.width > 0,
                                       geometry.size.height > 0,
                                       xPos.isFinite,
                                       yPos.isFinite,
                                       xPos >= 0,
                                       xPos <= geometry.size.width,
                                       yPos >= 0,
                                       yPos <= geometry.size.height {
                                        annotation.content
                                            .fixedSize()
                                            .position(x: xPos, y: yPos)
                                    }
                                }

                                if !highlightedAnnotations.isEmpty {
                                    ChartAnnotationTooltipOverlay(
                                        annotations: highlightedAnnotations,
                                        canvasSize: geometry.size,
                                        placement: tooltipPlacement,
                                        offset: tooltipOffset,
                                        padding: tooltipPadding,
                                        maxWidth: tooltipMaxWidth,
                                        content: annotationTooltipContent
                                    )
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
                                restoreBoundViewportOrInitialize()
                                publishViewportState()
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
        if handleAnnotationGestureEvent(event) {
            publishSelectionState()
            publishViewportState()
            return
        }

        store.handleGestureEvent(
            event,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            minZoomScale: minZoomScale,
            hitboxRadius: hitboxRadius,
            selectionMode: selectionMode,
            overlappingSelectionMode: overlappingSelectionMode,
            series: series
        )
        notifySelectionChange(for: event)
        publishSelectionState()
        publishViewportState()
    }

    private func notifySelectionChange(for event: ChartGestureEvent) {
        switch event {
        case .highlight, .highlightCleared, .panChanged, .zoomChanged:
            onSelectionChanged(store.highlightedPoints)
            onElementSelectionChanged(store.selectedElements)
        case .panEnded, .zoomEnded:
            break
        }
    }

    private func handleAnnotationGestureEvent(_ event: ChartGestureEvent) -> Bool {
        switch event {
        case .highlight(let location):
            guard isAnnotationSelectionEnabled else { return false }

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
                onSelectionChanged([])
                onElementSelectionChanged([])
                return true
            }

            return false

        case .highlightCleared:
            if !highlightedAnnotations.isEmpty {
                highlightedAnnotations = []
                onAnnotationSelectionChanged([])
            }
            return false

        case .panChanged, .zoomChanged:
            annotationSelectionCycle.reset()
            if !highlightedAnnotations.isEmpty {
                highlightedAnnotations = []
                onAnnotationSelectionChanged([])
            }
            return false

        case .panEnded, .zoomEnded:
            return false
        }
    }

    // MARK: - Scale sync

    private func syncBaseScales() {
        store.updateBaseScales(xScale: baseXScale, yScale: baseYScale)
    }

    private func handleScaleDomainChange() {
        syncBaseScales()
        if !isLiveTrackingEnabled {
            store.resetViewport()
            initializeViewportIfNeeded()
        }
        store.queueUpdate(series: series, in: store.canvasSize, animate: false)
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
           state.visibleXDomain != nil || state.visibleYDomain != nil {
            store.applyViewportState(state)
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
        store.applyViewportState(state)
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
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
    }

    private func publishSelectionState() {
        let state = store.selectionState
        if selectionStateBinding?.wrappedValue != state {
            selectionStateBinding?.wrappedValue = state
        }
    }

    private func applyProgrammaticZoom(magnification: Double) {
        syncBaseScales()
        store.applyProgrammaticZoom(
            magnification: magnification,
            minZoomScale: minZoomScale,
            zoomX: isHorizontalZoomEnabled,
            zoomY: isVerticalZoomEnabled
        )
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
        publishViewportState()
    }

    private func resetViewportFromControls() {
        syncBaseScales()
        store.resetViewport()
        initializeViewportIfNeeded()
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
        publishViewportState()
    }

    // MARK: - Off-screen culling

    private var visiblePointAnnotations: [PointAnnotation<Double, Double>] {
        let domain  = store.activeXScale.domain
        let buffer  = (domain.upperBound - domain.lowerBound) * 0.1
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

private struct ChartAnnotationTooltipOverlay: View {
    let annotations: [ChartAnnotationContext]
    let canvasSize: CGSize
    let placement: ChartTooltipPlacement
    let offset: CGPoint
    let padding: CGFloat
    let maxWidth: CGFloat?
    let content: (([ChartAnnotationContext]) -> AnyView)?

    @State private var tooltipSize: CGSize = .zero

    var body: some View {
        if let anchor = ChartTooltipLayout.anchor(for: annotations.map(\.position)) {
            resolvedContent
                .frame(maxWidth: maxWidth, alignment: .leading)
                .fixedSize(horizontal: maxWidth == nil, vertical: true)
                .readSize { tooltipSize = $0 }
                .position(
                    ChartTooltipLayout.resolve(
                        anchor: anchor,
                        tooltipSize: tooltipSize,
                        canvasSize: canvasSize,
                        placement: placement,
                        offset: offset,
                        padding: padding
                    ).position
                )
        }
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
