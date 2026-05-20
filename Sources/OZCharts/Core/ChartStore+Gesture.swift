//
//  ChartStore+Gesture.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension ChartStore {
    // MARK: - Gesture Handling

    public func handleGestureEvent(
        _ event: ChartGestureEvent,
        isHorizontalScrollEnabled: Bool,
        isVerticalScrollEnabled: Bool,
        isHorizontalZoomEnabled: Bool,
        isVerticalZoomEnabled: Bool,
        minZoomScale: Double,
        hitboxRadius: CGFloat,
        liveTrackingMode: ChartLiveTrackingMode = .disabled,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded,
        series: [AnyChartSeries<Point>]
    ) {
        switch event {
        case let .panChanged(translation):
            viewport.isDragging = true
            clearSelectionForDragIfNeeded(selectionDismissalPolicy)
            let didPan = viewport.applyPan(
                translationWidth: translation.width,
                translationHeight: translation.height,
                canvasSize: canvasSize,
                globalXDomain: baseXScale.domain,
                globalYDomain: baseYScale.domain,
                scrollX: isHorizontalScrollEnabled,
                scrollY: isVerticalScrollEnabled
            )
            guard didPan else { return }
            applyViewportToScales()
            queueUpdate(series: series, in: canvasSize, animate: false, coalesce: false)

        case .panEnded:
            viewport.endPan(
                liveTrackingMode: liveTrackingMode,
                globalXDomain: baseXScale.domain
            )

        case let .zoomChanged(magnification):
            clearSelectionForViewportChangeIfNeeded(selectionDismissalPolicy)
            viewport.applyZoom(
                magnification: magnification,
                globalXDomain: baseXScale.domain,
                globalYDomain: baseYScale.domain,
                minZoomScale: minZoomScale,
                zoomX: isHorizontalZoomEnabled,
                zoomY: isVerticalZoomEnabled
            )
            applyViewportToScales()
            queueUpdate(series: series, in: canvasSize, animate: false, coalesce: false)

        case .zoomEnded:
            viewport.endZoom(
                liveTrackingMode: liveTrackingMode,
                globalXDomain: baseXScale.domain
            )

        case let .highlight(location):
            let elementContexts = selectElementContexts(
                near: location,
                overlappingSelectionMode: overlappingSelectionMode
            )
            if !elementContexts.isEmpty {
                selectedElementContexts = elementContexts
                selectedElements = elementContexts.map(\.payload)
                highlightedPoints = []
            } else {
                let points = selectPoints(
                    near: location,
                    radius: hitboxRadius,
                    mode: selectionMode,
                    overlappingSelectionMode: overlappingSelectionMode,
                    nearestSelectionPolicy: nearestSelectionPolicy
                )
                if points.isEmpty, !selectionDismissalPolicy.contains(.tapOutside) {
                    return
                }
                selectedElementContexts = []
                selectedElements = []
                highlightedPoints = points
            }

        case .highlightCleared:
            highlightedPoints = []
            selectedElements = []
            selectedElementContexts = []
        }
    }
}
