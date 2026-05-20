//
//  ChartStore+Data.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension ChartStore {
    // MARK: - Data Updates & Live Tracking

    public func handleDataChange(
        series: [AnyChartSeries<Point>],
        isLiveTrackingEnabled: Bool,
        liveTrackingMode: ChartLiveTrackingMode? = nil,
        initialViewport: ChartInitialViewport? = nil,
        isHorizontalScrollEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true
    ) {
        let allData = series.flatMap(\.data)
        if allData.isEmpty {
            clearDataState()
            return
        }

        let resolvedLiveTrackingMode = liveTrackingMode ??
            (isLiveTrackingEnabled ? .followLatest() : .disabled)

        if resolvedLiveTrackingMode.isEnabled {
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
                mode: resolvedLiveTrackingMode,
                newGlobalMax: baseXScale.domain.upperBound,
                currentWindowWidth: windowWidth,
                globalXDomain: baseXScale.domain
            )
            applyViewportToScales()
        } else {
            initializeViewport(
                initialViewport: initialViewport,
                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                isVerticalScrollEnabled: isVerticalScrollEnabled
            )
            viewport.clampVisibleDomains(
                globalXDomain: baseXScale.domain,
                globalYDomain: baseYScale.domain
            )
            applyViewportToScales()
        }

        let hasAnimation = series.contains { $0.animation.swiftUIAnimation != nil }
        queueUpdate(series: series, in: canvasSize, animate: hasAnimation, coalesce: !hasAnimation)
    }

    func clearDataState() {
        layoutTask?.cancel()
        layoutTask = nil
        currentSeriesIDs = []
        oldSeriesContexts = []
        oldRenderSeriesContexts = []
        seriesContexts = []
        renderSeriesContexts = []
        pointInteractionIndex = nil
        highlightedPoints = []
        selectedElements = []
        selectedElementContexts = []
        selectableElements = []
        violinBackgrounds = [:]
        animationProgress = 1.0
        animationPhase = 0
        isAnimationActive = false
        resetSelectionCycle()
    }
}
