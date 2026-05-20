//
//  CartesianChartView+Viewport.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension CartesianChartView {
    func handleSeriesChange() {
        syncBaseScales()
        publishDiagnostics(plotAreaSize: store.canvasSize)
        store.handleDataChange(
            series: series,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            liveTrackingMode: liveTrackingMode,
            initialViewport: initialViewport,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled
        )
    }

    func syncBaseScales() {
        store.updateBaseScales(xScale: baseXScale, yScale: baseYScale)
    }

    func handleScaleDomainChange() {
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

    func initializeViewportIfNeeded() {
        store.initializeViewport(
            initialViewport: initialViewport,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled
        )
    }

    func restoreBoundViewportOrInitialize() {
        if let state = boundViewportState,
           state.visibleXDomain != nil ||
           state.visibleYDomain != nil ||
           state.command != nil {
            store.applyViewportState(state, liveTrackingMode: liveTrackingMode)
        } else {
            initializeViewportIfNeeded()
        }
    }

    var boundViewportState: ChartViewportState? {
        viewportBinding?.wrappedValue
    }

    var boundSelectionState: ChartSelectionState? {
        selectionStateBinding?.wrappedValue
    }

    func applyBoundViewportState(_ state: ChartViewportState?) {
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

    func publishViewportState() {
        let state = store.viewportState
        if viewportBinding?.wrappedValue != state {
            viewportBinding?.wrappedValue = state
        }
    }

    func applyBoundSelectionState(_ state: ChartSelectionState?) {
        guard let state, state != store.selectionState else { return }
        store.applySelectionState(state)
        highlightedAnnotations = []
        onAnnotationSelectionChanged([])
        onSelectionChanged(store.highlightedPoints)
        onElementSelectionChanged(store.selectedElements)
        onChartSelectionChanged(currentSelection)
    }

    func publishSelectionState() {
        let state = store.selectionState
        if selectionStateBinding?.wrappedValue != state {
            selectionStateBinding?.wrappedValue = state
        }
    }

    var currentSelection: ChartSelection<Point> {
        ChartSelection(
            points: store.highlightedPoints,
            elements: store.selectedElements,
            annotations: highlightedAnnotations,
            state: store.selectionState
        )
    }

    var resolvedTooltipAnchorPoint: CGPoint? {
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

    var resolvedAnnotationTooltipAnchorPoint: CGPoint? {
        guard !highlightedAnnotations.isEmpty else { return nil }

        switch tooltipAnchor {
        case .tapLocation, .hitPoint:
            return lastGestureLocation
        case .selectedValue, .elementCenter:
            return nil
        }
    }

    func applyProgrammaticZoom(magnification: Double) {
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

    func resetViewportFromControls() {
        syncBaseScales()
        store.clearSelectionForViewportChange(selectionDismissalPolicy)
        store.resetViewport()
        initializeViewportIfNeeded()
        store.queueUpdate(series: series, in: store.canvasSize, animate: false, coalesce: false)
        publishViewportState()
    }
}
