//
//  ChartStore.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

@MainActor
public final class ChartStore<
    Point: ChartDataPoint,
    XScale: Scale,
    YScale: Scale
>: ObservableObject
where XScale.InputType == Point.XValue, XScale.OutputType == CGFloat,
      YScale.InputType == Point.YValue, YScale.OutputType == CGFloat,
      Point.XValue == Double, Point.YValue == Double {

    // MARK: - Published State
    @Published public var activeXScale: XScale
    @Published public var activeYScale: YScale

    @Published public var seriesContexts: [[ChartPointContext<Point>]] = []
    @Published public var oldSeriesContexts: [[ChartPointContext<Point>]] = []
    @Published public var animationProgress: CGFloat = 1.0
    @Published public var isAnimationActive = false

    @Published public var highlightedPoints: [ChartPointContext<Point>] = []
    @Published public var selectedElements: [ChartSelectedElement] = []
    @Published public var selectedElementContexts: [ChartElementContext] = []
    @Published public var selectableElements: [ChartElementContext] = []
    @Published public var violinBackgrounds: [AnyHashable: Path] = [:]

    @Published public var viewport = ChartViewport()

    // MARK: - Internal logic variables
    public var baseXScale: XScale
    public var baseYScale: YScale
    public var canvasSize: CGSize = .zero
    var layoutCoalescingIntervalNanoseconds: UInt64 = 16_000_000
    private var updateCounter: Int = 0
    private var layoutTask: Task<Void, Never>?
    private var selectionCycleIDs: [UUID] = []
    private var selectionCycleIndex: Int = 0
    private var currentSeriesIDs: [UUID] = []

    public init(xScale: XScale, yScale: YScale) {
        self.baseXScale = xScale
        self.baseYScale = yScale
        self.activeXScale = xScale
        self.activeYScale = yScale
    }

    public func updateBaseScales(xScale: XScale, yScale: YScale) {
        baseXScale = xScale
        baseYScale = yScale
    }

    public func resetViewport() {
        viewport.reset()
        activeXScale = baseXScale
        activeYScale = baseYScale
    }

    public var viewportState: ChartViewportState {
        viewport.state
    }

    public var selectionState: ChartSelectionState {
        ChartSelectionState(
            selectedX: highlightedPoints.first?.originalPoint.x,
            selectedPoints: selectedPointPayloads(for: highlightedPoints),
            selectedElements: selectedElements
        )
    }

    deinit {
        layoutTask?.cancel()
    }

    // MARK: - Data Updates & Live Tracking

    public func handleDataChange(
        series: [AnyChartSeries<Point>],
        isLiveTrackingEnabled: Bool,
        initialViewport: ChartInitialViewport? = nil,
        isHorizontalScrollEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true
    ) {
        let allData = series.flatMap { $0.data }
        if allData.isEmpty {
            clearDataState()
            return
        }

        if isLiveTrackingEnabled {
            initializeViewport(
                initialViewport: initialViewport,
                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                isVerticalScrollEnabled: isVerticalScrollEnabled
            )
            let currentDomain = viewport.visibleXDomain ?? baseXScale.domain
            let windowWidth = max(0, currentDomain.upperBound - currentDomain.lowerBound)
            if viewport.visibleXDomain == nil {
                viewport.visibleXDomain = currentDomain
            }
            viewport.applyLiveTracking(
                newGlobalMax: baseXScale.domain.upperBound,
                currentWindowWidth: windowWidth,
                globalXDomain: baseXScale.domain
            )
            applyViewportToScales()
        } else if !isLiveTrackingEnabled {
            initializeViewport(
                initialViewport: initialViewport,
                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                isVerticalScrollEnabled: isVerticalScrollEnabled
            )
        }

        let hasAnimation = series.contains { $0.animation.swiftUIAnimation != nil }
        queueUpdate(series: series, in: canvasSize, animate: hasAnimation)
    }

    // MARK: - Gesture Handling

    public func handleGestureEvent(
        _ event: ChartGestureEvent,
        isHorizontalScrollEnabled: Bool,
        isVerticalScrollEnabled: Bool,
        isHorizontalZoomEnabled: Bool,
        isVerticalZoomEnabled: Bool,
        minZoomScale: Double,
        hitboxRadius: CGFloat,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        series: [AnyChartSeries<Point>]
    ) {
        switch event {
        case .panChanged(let translation):
            viewport.isDragging = true
            highlightedPoints = []
            selectedElements = []
            selectedElementContexts = []
            resetSelectionCycle()
            viewport.applyPan(
                translationWidth:  translation.width,
                translationHeight: translation.height,
                canvasSize:        canvasSize,
                globalXDomain:     baseXScale.domain,
                globalYDomain:     baseYScale.domain,
                scrollX:           isHorizontalScrollEnabled,
                scrollY:           isVerticalScrollEnabled
            )
            applyViewportToScales()
            queueUpdate(series: series, in: canvasSize, animate: false, coalesce: false)

        case .panEnded:
            viewport.endPan()

        case .zoomChanged(let magnification):
            highlightedPoints = []
            selectedElements = []
            selectedElementContexts = []
            resetSelectionCycle()
            viewport.applyZoom(
                magnification:  magnification,
                globalXDomain:  baseXScale.domain,
                globalYDomain:  baseYScale.domain,
                minZoomScale:   minZoomScale,
                zoomX:          isHorizontalZoomEnabled,
                zoomY:          isVerticalZoomEnabled
            )
            applyViewportToScales()
            queueUpdate(series: series, in: canvasSize, animate: false, coalesce: false)

        case .zoomEnded:
            viewport.endZoom()

        case .highlight(let location):
            let elementContexts = selectElementContexts(near: location)
            if !elementContexts.isEmpty {
                selectedElementContexts = elementContexts
                selectedElements = elementContexts.map(\.payload)
                highlightedPoints = []
            } else {
                selectedElementContexts = []
                selectedElements = []
                highlightedPoints = selectPoints(
                    near: location,
                    radius: hitboxRadius,
                    mode: selectionMode,
                    overlappingSelectionMode: overlappingSelectionMode
                )
            }

        case .highlightCleared:
            highlightedPoints = []
            selectedElements = []
            selectedElementContexts = []
        }
    }

    func selectElements(near location: CGPoint) -> [ChartSelectedElement] {
        selectElementContexts(near: location).map(\.payload)
    }

    func selectElementContexts(near location: CGPoint) -> [ChartElementContext] {
        ChartHitTestResolver.elementContexts(
            near: location,
            contexts: selectableElements
        )
    }

    func selectPoints(
        near location: CGPoint,
        radius: CGFloat,
        mode: ChartSelectionMode,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all
    ) -> [ChartPointContext<Point>] {
        let allContexts = seriesContexts.flatMap { $0 }
        return ChartHitTestResolver.points(
            near: location,
            contexts: allContexts,
            radius: radius,
            mode: mode,
            overlappingSelectionMode: overlappingSelectionMode,
            cycleIDs: &selectionCycleIDs,
            cycleIndex: &selectionCycleIndex
        )
    }

    func selectNearestXValue(_ xValue: Double) -> [ChartPointContext<Point>] {
        guard xValue.isFinite else { return [] }

        let allContexts = seriesContexts.flatMap { $0 }
        guard let nearest = allContexts.min(by: {
            abs($0.originalPoint.x - xValue) < abs($1.originalPoint.x - xValue)
        }) else {
            return []
        }

        return allContexts.filter { $0.originalPoint.x == nearest.originalPoint.x }
    }

    func selectPoints(byIDs pointIDs: [UUID]) -> [ChartPointContext<Point>] {
        guard !pointIDs.isEmpty else { return [] }

        let selectedIDs = Set(pointIDs)
        return seriesContexts
            .flatMap { $0 }
            .filter { selectedIDs.contains($0.originalPoint.id) }
    }

    func selectElements(byIDs elementIDs: [UUID]) -> [ChartSelectedElement] {
        guard !elementIDs.isEmpty else { return [] }

        let selectedIDs = Set(elementIDs)
        return selectableElements
            .map(\.payload)
            .filter { selectedIDs.contains($0.elementID) }
    }

    func selectElementContexts(byIDs elementIDs: [UUID]) -> [ChartElementContext] {
        guard !elementIDs.isEmpty else { return [] }

        let selectedIDs = Set(elementIDs)
        return selectableElements
            .filter { selectedIDs.contains($0.payload.elementID) }
    }

    public func applySelectionState(_ state: ChartSelectionState) {
        if !state.selectedElements.isEmpty {
            let selectedContextsByID = selectElementContexts(byIDs: state.selectedElements.map(\.elementID))
            selectedElementContexts = selectedContextsByID
            selectedElements = selectedContextsByID.map(\.payload)
            highlightedPoints = []
            resetSelectionCycle()
            return
        }

        if !state.selectedPoints.isEmpty {
            let selectedByID = selectPoints(byIDs: state.selectedPoints.map(\.pointID))
            if !selectedByID.isEmpty || state.selectedX == nil {
                highlightedPoints = selectedByID
                selectedElements = []
                selectedElementContexts = []
                resetSelectionCycle()
                return
            }
            highlightedPoints = selectNearestXValue(state.selectedX ?? 0)
            selectedElements = []
            selectedElementContexts = []
            resetSelectionCycle()
            return
        }

        guard let selectedX = state.selectedX else {
            highlightedPoints = []
            selectedElements = []
            selectedElementContexts = []
            resetSelectionCycle()
            return
        }

        highlightedPoints = selectNearestXValue(selectedX)
        selectedElements = []
        selectedElementContexts = []
        resetSelectionCycle()
    }

    private func resetSelectionCycle() {
        selectionCycleIDs = []
        selectionCycleIndex = 0
    }

    private func clearDataState() {
        layoutTask?.cancel()
        layoutTask = nil
        currentSeriesIDs = []
        oldSeriesContexts = []
        seriesContexts = []
        highlightedPoints = []
        selectedElements = []
        selectedElementContexts = []
        selectableElements = []
        violinBackgrounds = [:]
        animationProgress = 1.0
        isAnimationActive = false
        resetSelectionCycle()
    }

    public func applyViewportToScales() {
        if let newXDomain = viewport.visibleXDomain,
           let newScaleX: XScale = replacementScale(like: activeXScale, domain: newXDomain) {
            activeXScale = newScaleX
        }
        if let newYDomain = viewport.visibleYDomain,
           let newScaleY: YScale = replacementScale(like: activeYScale, domain: newYDomain) {
            activeYScale = newScaleY
        }
    }

    public func applyViewportState(_ state: ChartViewportState) {
        activeXScale = baseXScale
        activeYScale = baseYScale
        viewport.applyState(
            state,
            globalXDomain: baseXScale.domain,
            globalYDomain: baseYScale.domain
        )
        applyViewportToScales()
    }

    public func applyProgrammaticZoom(
        magnification: Double,
        minZoomScale: Double,
        zoomX: Bool,
        zoomY: Bool
    ) {
        viewport.applyProgrammaticZoom(
            magnification: magnification,
            globalXDomain: baseXScale.domain,
            globalYDomain: baseYScale.domain,
            minZoomScale: minZoomScale,
            zoomX: zoomX,
            zoomY: zoomY
        )
        applyViewportToScales()
    }

    public func initializeViewport(
        initialViewport: ChartInitialViewport?,
        isHorizontalScrollEnabled: Bool,
        isVerticalScrollEnabled: Bool
    ) {
        viewport.initializeVisibleDomains(
            globalXDomain: baseXScale.domain,
            globalYDomain: baseYScale.domain,
            initialViewport: initialViewport,
            scrollX: isHorizontalScrollEnabled,
            scrollY: isVerticalScrollEnabled
        )
        applyViewportToScales()
    }

    // MARK: - Layout Recalculation

    public func queueUpdate(
        series: [AnyChartSeries<Point>],
        in size: CGSize,
        animate: Bool,
        coalesce: Bool = true
    ) {
        currentSeriesIDs = series.sorted { $0.zIndex < $1.zIndex }.map(\.id)
        guard size.width > 0 && size.height > 0 else { return }

        updateCounter += 1
        let currentID = updateCounter
        layoutTask?.cancel()

        if !coalesce && !animate {
            oldSeriesContexts = []
            let contexts = calculateSeriesContexts(for: series, in: size)
            seriesContexts = contexts
            selectableElements = calculateSelectionElementContexts(for: series, contexts: contexts, in: size)
            animationProgress = 1.0
            isAnimationActive = false
            layoutTask = nil
            return
        }

        layoutTask = Task { @MainActor in
            if coalesce, layoutCoalescingIntervalNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: layoutCoalescingIntervalNanoseconds)
            }

            guard !Task.isCancelled, currentID == self.updateCounter else { return }

            if animate {
                oldSeriesContexts = seriesContexts
                animationProgress = 0.0
                isAnimationActive = true
                try? await Task.sleep(nanoseconds: 5_000_000)
            } else {
                oldSeriesContexts = []
                animationProgress = 1.0
                isAnimationActive = false
            }

            guard !Task.isCancelled, currentID == self.updateCounter else { return }

            let newContexts = calculateSeriesContexts(for: series, in: size)
            let newElements = calculateSelectionElementContexts(for: series, contexts: newContexts, in: size)

            guard !Task.isCancelled, currentID == self.updateCounter else { return }
            seriesContexts = newContexts
            selectableElements = newElements

            let hasAnimation = series.contains { $0.animation.swiftUIAnimation != nil }
            if animate && hasAnimation {
                let anim = series.first(where: { $0.animation.swiftUIAnimation != nil })?.animation.swiftUIAnimation
                withAnimation(anim) { animationProgress = 1.0 }
            } else {
                animationProgress = 1.0
            }

            if currentID == self.updateCounter {
                layoutTask = nil
            }
        }
    }

    private func calculateSeriesContexts(
        for series: [AnyChartSeries<Point>],
        in size: CGSize
    ) -> [[ChartPointContext<Point>]] {
        var newContexts: [[ChartPointContext<Point>]] = []
        let sorted = series.sorted { $0.zIndex < $1.zIndex }

        for s in sorted {
            var coordinator = CartesianCoordinator<Point, XScale, YScale>(
                xScale: activeXScale,
                yScale: activeYScale
            )
            let contexts = coordinator.calculateLayout(for: s.data, in: size)

            activeXScale = coordinator.xScale
            activeYScale = coordinator.yScale
            newContexts.append(contexts)
        }

        return newContexts
    }

    private func calculateSelectionElementContexts(
        for series: [AnyChartSeries<Point>],
        contexts: [[ChartPointContext<Point>]],
        in size: CGSize
    ) -> [ChartElementContext] {
        let sorted = series.sorted { $0.zIndex < $1.zIndex }
        return sorted.enumerated().flatMap { index, series in
            let seriesContexts = contexts[safe: index] ?? []
            return series.selectionElements(contexts: seriesContexts, size: size).map { element in
                var payload = element.payload
                payload.seriesID = payload.seriesID ?? series.id
                payload.seriesIndex = payload.seriesIndex ?? index
                return ChartElementContext(
                    payload: payload,
                    hitShape: element.hitShape,
                    zIndex: element.zIndex
                )
            }
        }
    }

    private func selectedPointPayloads(
        for points: [ChartPointContext<Point>]
    ) -> [ChartSelectedPoint] {
        points.map { context in
            let seriesMatch = seriesContexts.enumerated().first { _, contexts in
                contexts.contains { $0.originalPoint.id == context.originalPoint.id }
            }

            return ChartSelectedPoint(
                pointID: context.originalPoint.id,
                seriesID: seriesMatch.flatMap { currentSeriesIDs[safe: $0.offset] },
                seriesIndex: seriesMatch?.offset,
                x: context.originalPoint.x,
                y: context.originalPoint.y
            )
        }
    }
}

private func replacementScale<S: Scale>(
    like scale: S,
    domain: ClosedRange<Double>
) -> S? where S.InputType == Double, S.OutputType == CGFloat {
    if let linear = scale as? LinearScale {
        return LinearScale(
            domain: domain,
            range: linear.range,
            isReversed: linear.isReversed
        ) as? S
    }

    if let log = scale as? LogScale {
        return LogScale(
            domain: domain,
            range: log.range,
            isReversed: log.isReversed,
            base: log.base
        ) as? S
    }

    return nil
}
