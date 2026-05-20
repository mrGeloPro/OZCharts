//
//  CartesianChartView+Interaction.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension CartesianChartView {
    func handleGestureEvent(_ event: ChartGestureEvent) {
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

    func handlePointGestureEvent(_ event: ChartGestureEvent) {
        applyPointGestureEvent(event)
        notifySelectionChange(for: event)
    }

    func applyPointGestureEvent(_ event: ChartGestureEvent) {
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
            nearestSelectionPolicy: nearestSelectionPolicy,
            series: series
        )
    }

    func notifySelectionChange(for event: ChartGestureEvent) {
        switch event {
        case .highlight, .highlightCleared, .panChanged, .zoomChanged:
            if !currentSelection.isEmpty {
                clearRuntimeDiagnostics(codes: [ChartDiagnosticCode.selectionMissedHitbox])
            }
            onSelectionChanged(store.highlightedPoints)
            onElementSelectionChanged(store.selectedElements)
            onChartSelectionChanged(currentSelection)
        case .panEnded, .zoomEnded:
            break
        }
    }

    func notifyEmptyTapIfNeeded(for event: ChartGestureEvent) {
        guard case let .highlight(location) = event,
              store.highlightedPoints.isEmpty,
              store.selectedElements.isEmpty,
              highlightedAnnotations.isEmpty else { return }

        onEmptyTap(location)
        publishRuntimeDiagnostics([
            ChartDiagnostics.selectionMissedHitbox(location: location, hitboxRadius: hitboxRadius)
        ])
    }

    func clearAnnotationSelection() {
        guard !highlightedAnnotations.isEmpty else { return }

        highlightedAnnotations = []
        annotationSelectionCycle.reset()
        onAnnotationSelectionChanged([])
        onChartSelectionChanged(currentSelection)
    }

    func handleAxisMarkerTap(
        _ context: ChartAxisMarkerContext,
        selectableContexts: [ChartAxisMarkerContext]
    ) {
        guard axisMarkerSelectionOptions.isEnabled else { return }

        var cycle = axisMarkerSelectionCycle
        let selected = ChartAxisMarkerSelectionResolver.select(
            near: context,
            contexts: selectableContexts,
            defaultRadius: axisMarkerSelectionOptions.hitboxRadius,
            overlappingMode: axisMarkerSelectionOptions.overlappingMode,
            cycle: &cycle
        )
        axisMarkerSelectionCycle = cycle
        highlightedAxisMarkers = selected
        onAxisMarkerSelectionChanged(selected)
    }

    func handleAnnotationGestureEvent(
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
}
