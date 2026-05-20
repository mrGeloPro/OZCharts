//
//  ChartStore+Viewport.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension ChartStore {
    public func resetViewport() {
        viewport.reset()
        activeXScale = baseXScale
        activeYScale = baseYScale
    }

    public var viewportState: ChartViewportState {
        viewport.state
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

    public func applyViewportState(
        _ state: ChartViewportState,
        liveTrackingMode: ChartLiveTrackingMode = .disabled,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .none
    ) {
        clearSelectionForViewportChangeIfNeeded(selectionDismissalPolicy)
        activeXScale = baseXScale
        activeYScale = baseYScale

        let currentXDomain = viewport.visibleXDomain ?? state.visibleXDomain ?? baseXScale.domain
        let currentWindowWidth = max(0, currentXDomain.upperBound - currentXDomain.lowerBound)

        if state.visibleXDomain != nil ||
            state.visibleYDomain != nil ||
            state.liveTrackingStatus != .inactive {
            var stateWithoutCommand = state
            stateWithoutCommand.command = nil
            viewport.applyState(
                stateWithoutCommand,
                globalXDomain: baseXScale.domain,
                globalYDomain: baseYScale.domain
            )
            if liveTrackingMode.isEnabled,
               state.liveTrackingStatus == .inactive,
               state.visibleXDomain != nil {
                viewport.endPan(
                    liveTrackingMode: liveTrackingMode,
                    globalXDomain: baseXScale.domain
                )
            }
        }

        if state.command == .jumpToLatest {
            viewport.jumpToLatest(
                currentWindowWidth: currentWindowWidth,
                globalXDomain: baseXScale.domain
            )
        }

        applyViewportToScales()
    }

    public func jumpToLatest(
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .none
    ) {
        clearSelectionForViewportChangeIfNeeded(selectionDismissalPolicy)
        let currentDomain = viewport.visibleXDomain ?? baseXScale.domain
        let windowWidth = max(0, currentDomain.upperBound - currentDomain.lowerBound)
        viewport.jumpToLatest(
            currentWindowWidth: windowWidth,
            globalXDomain: baseXScale.domain
        )
        applyViewportToScales()
    }

    public func clearSelectionForViewportChange(
        _ selectionDismissalPolicy: ChartSelectionDismissalPolicy
    ) {
        clearSelectionForViewportChangeIfNeeded(selectionDismissalPolicy)
    }

    public func applyProgrammaticZoom(
        magnification: Double,
        minZoomScale: Double,
        zoomX: Bool,
        zoomY: Bool,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .none
    ) {
        clearSelectionForViewportChangeIfNeeded(selectionDismissalPolicy)
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
