//
//  ChartViewport.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public struct ChartViewport {
    var visibleXDomain: ClosedRange<Double>?
    var visibleYDomain: ClosedRange<Double>?
    var dragStartXDomain: ClosedRange<Double>?
    var dragStartYDomain: ClosedRange<Double>?
    var zoomStartXDomain: ClosedRange<Double>?
    var zoomStartYDomain: ClosedRange<Double>?

    var isDragging: Bool = false
    var isZooming: Bool = false
    var liveTrackingStatus: ChartLiveTrackingStatus = .inactive
    var pausedTrailingOffset: Double?

    var state: ChartViewportState {
        ChartViewportState(
            visibleXDomain: visibleXDomain,
            visibleYDomain: visibleYDomain,
            liveTrackingStatus: liveTrackingStatus
        )
    }

    // MARK: - Pan

    mutating func initializeVisibleDomains(
        globalXDomain: ClosedRange<Double>,
        globalYDomain: ClosedRange<Double>,
        initialViewport: ChartInitialViewport?,
        scrollX: Bool,
        scrollY: Bool
    ) {
        if visibleXDomain == nil {
            if let initialXDomain = initialViewport?.xDomain?.resolved(within: globalXDomain) {
                visibleXDomain = initialXDomain
            } else if scrollX {
                visibleXDomain = globalXDomain
            }
        }

        if visibleYDomain == nil {
            if let initialYDomain = initialViewport?.yDomain?.resolved(within: globalYDomain) {
                visibleYDomain = initialYDomain
            } else if scrollY {
                visibleYDomain = globalYDomain
            }
        }
    }

    mutating func applyPan(
        translationWidth: CGFloat,
        translationHeight: CGFloat,
        canvasSize: CGSize,
        globalXDomain: ClosedRange<Double>,
        globalYDomain: ClosedRange<Double>,
        scrollX: Bool,
        scrollY: Bool
    ) {
        guard !isZooming else { return }

        if scrollX {
            guard canvasSize.width > 0 else { return }
            let currentX = visibleXDomain ?? globalXDomain
            if dragStartXDomain == nil { dragStartXDomain = currentX }
            if let start = dragStartXDomain {
                let range  = start.upperBound - start.lowerBound
                let shift  = -(translationWidth / canvasSize.width) * range
                visibleXDomain = clamp(start.lowerBound + shift ... start.upperBound + shift, within: globalXDomain)
            }
        }
        if scrollY {
            guard canvasSize.height > 0 else { return }
            let currentY = visibleYDomain ?? globalYDomain
            if dragStartYDomain == nil { dragStartYDomain = currentY }
            if let start = dragStartYDomain {
                let range  = start.upperBound - start.lowerBound
                let shift  = (translationHeight / canvasSize.height) * range
                visibleYDomain = clamp(start.lowerBound + shift ... start.upperBound + shift, within: globalYDomain)
            }
        }
    }

    mutating func endPan(
        liveTrackingMode: ChartLiveTrackingMode = .disabled,
        globalXDomain: ClosedRange<Double>? = nil
    ) {
        dragStartXDomain = nil
        dragStartYDomain = nil
        isDragging = false
        updateLiveTrackingStatusAfterInteraction(
            mode: liveTrackingMode,
            globalXDomain: globalXDomain
        )
    }

    // MARK: - Zoom

    mutating func applyZoom(
        magnification: CGFloat,
        globalXDomain: ClosedRange<Double>,
        globalYDomain: ClosedRange<Double>,
        minZoomScale: Double,
        zoomX: Bool,
        zoomY: Bool
    ) {
        isZooming = true
        dragStartXDomain = nil
        dragStartYDomain = nil
        isDragging = false

        if zoomX {
            let current = visibleXDomain ?? globalXDomain
            if zoomStartXDomain == nil { zoomStartXDomain = current }
            if let start = zoomStartXDomain {
                visibleXDomain = zoomed(start, by: magnification, within: globalXDomain, minScale: minZoomScale)
            }
        }
        if zoomY {
            let current = visibleYDomain ?? globalYDomain
            if zoomStartYDomain == nil { zoomStartYDomain = current }
            if let start = zoomStartYDomain {
                visibleYDomain = zoomed(start, by: magnification, within: globalYDomain, minScale: minZoomScale)
            }
        }
    }

    mutating func endZoom(
        liveTrackingMode: ChartLiveTrackingMode = .disabled,
        globalXDomain: ClosedRange<Double>? = nil
    ) {
        zoomStartXDomain = nil
        zoomStartYDomain = nil
        isZooming = false
        updateLiveTrackingStatusAfterInteraction(
            mode: liveTrackingMode,
            globalXDomain: globalXDomain
        )
    }

    mutating func applyProgrammaticZoom(
        magnification: Double,
        globalXDomain: ClosedRange<Double>,
        globalYDomain: ClosedRange<Double>,
        minZoomScale: Double,
        zoomX: Bool,
        zoomY: Bool
    ) {
        guard magnification.isFinite, magnification > 0 else { return }

        dragStartXDomain = nil
        dragStartYDomain = nil
        zoomStartXDomain = nil
        zoomStartYDomain = nil
        isDragging = false
        isZooming = false

        if zoomX {
            let current = visibleXDomain ?? globalXDomain
            visibleXDomain = zoomed(
                current,
                by: CGFloat(magnification),
                within: globalXDomain,
                minScale: minZoomScale
            )
        }

        if zoomY {
            let current = visibleYDomain ?? globalYDomain
            visibleYDomain = zoomed(
                current,
                by: CGFloat(magnification),
                within: globalYDomain,
                minScale: minZoomScale
            )
        }
    }

    mutating func applyState(
        _ state: ChartViewportState,
        globalXDomain: ClosedRange<Double>,
        globalYDomain: ClosedRange<Double>
    ) {
        visibleXDomain = state.visibleXDomain.flatMap {
            validClamped($0, within: globalXDomain)
        }
        visibleYDomain = state.visibleYDomain.flatMap {
            validClamped($0, within: globalYDomain)
        }
        dragStartXDomain = nil
        dragStartYDomain = nil
        zoomStartXDomain = nil
        zoomStartYDomain = nil
        isDragging = false
        isZooming = false
        liveTrackingStatus = state.liveTrackingStatus
        if liveTrackingStatus != .pausedByUser {
            pausedTrailingOffset = nil
        }
    }

    // MARK: - Reset

    mutating func reset() {
        visibleXDomain   = nil
        visibleYDomain   = nil
        dragStartXDomain = nil
        dragStartYDomain = nil
        zoomStartXDomain = nil
        zoomStartYDomain = nil
        isDragging       = false
        isZooming        = false
        liveTrackingStatus = .inactive
        pausedTrailingOffset = nil
    }

    // MARK: - Live tracking

    mutating func applyLiveTracking(
        mode: ChartLiveTrackingMode,
        newGlobalMax: Double,
        currentWindowWidth: Double,
        globalXDomain: ClosedRange<Double>
    ) {
        guard mode.isEnabled else {
            liveTrackingStatus = .inactive
            pausedTrailingOffset = nil
            clampVisibleDomains(globalXDomain: globalXDomain, globalYDomain: nil)
            return
        }

        guard !isDragging, !isZooming, visibleXDomain != nil else {
            if liveTrackingStatus == .inactive {
                liveTrackingStatus = .followingLatest
            }
            return
        }

        let canFollow = !mode.pauseOnUserInteraction ||
            liveTrackingStatus != .pausedByUser ||
            isAtTrailingEdge(globalXDomain: globalXDomain, toleranceRatio: mode.trailingToleranceRatio)

        guard canFollow else {
            applyPausedLiveTracking(
                mode: mode,
                currentWindowWidth: currentWindowWidth,
                globalXDomain: globalXDomain
            )
            liveTrackingStatus = .pausedByUser
            return
        }

        let newDomain = (newGlobalMax - currentWindowWidth)...newGlobalMax
        visibleXDomain = clamp(newDomain, within: globalXDomain)
        liveTrackingStatus = .followingLatest
        pausedTrailingOffset = nil
    }

    mutating func jumpToLatest(
        currentWindowWidth: Double,
        globalXDomain: ClosedRange<Double>
    ) {
        guard currentWindowWidth.isFinite, currentWindowWidth > 0 else {
            visibleXDomain = globalXDomain
            dragStartXDomain = nil
            zoomStartXDomain = nil
            isDragging = false
            isZooming = false
            liveTrackingStatus = .followingLatest
            pausedTrailingOffset = nil
            return
        }

        let newDomain = (globalXDomain.upperBound - currentWindowWidth)...globalXDomain.upperBound
        visibleXDomain = clamp(newDomain, within: globalXDomain)
        dragStartXDomain = nil
        zoomStartXDomain = nil
        isDragging = false
        isZooming = false
        liveTrackingStatus = .followingLatest
        pausedTrailingOffset = nil
    }

    mutating func clampVisibleDomains(
        globalXDomain: ClosedRange<Double>?,
        globalYDomain: ClosedRange<Double>?
    ) {
        if let globalXDomain, let visibleXDomain {
            self.visibleXDomain = validClamped(visibleXDomain, within: globalXDomain)
        }
        if let globalYDomain, let visibleYDomain {
            self.visibleYDomain = validClamped(visibleYDomain, within: globalYDomain)
        }
    }

    // MARK: - Private helpers

    private func clamp(
        _ range: ClosedRange<Double>,
        within global: ClosedRange<Double>
    ) -> ClosedRange<Double> {
        var lo = range.lowerBound
        var hi = range.upperBound
        let width = hi - lo
        if lo < global.lowerBound { lo = global.lowerBound; hi = lo + width }
        if hi > global.upperBound { hi = global.upperBound; lo = hi - width }
        return max(global.lowerBound, lo)...min(global.upperBound, hi)
    }

    private func validClamped(
        _ range: ClosedRange<Double>,
        within global: ClosedRange<Double>
    ) -> ClosedRange<Double>? {
        guard range.lowerBound.isFinite,
              range.upperBound.isFinite,
              range.lowerBound < range.upperBound else {
            return nil
        }

        return clamp(range, within: global)
    }

    private mutating func updateLiveTrackingStatusAfterInteraction(
        mode: ChartLiveTrackingMode,
        globalXDomain: ClosedRange<Double>?
    ) {
        guard mode.isEnabled else {
            liveTrackingStatus = .inactive
            pausedTrailingOffset = nil
            return
        }

        guard mode.pauseOnUserInteraction, let globalXDomain else {
            liveTrackingStatus = .followingLatest
            pausedTrailingOffset = nil
            return
        }

        let isTrailing = isAtTrailingEdge(
            globalXDomain: globalXDomain,
            toleranceRatio: mode.trailingToleranceRatio
        )
        liveTrackingStatus = isTrailing ? .followingLatest : .pausedByUser
        pausedTrailingOffset = isTrailing ? nil : trailingOffset(from: globalXDomain)
    }

    private mutating func applyPausedLiveTracking(
        mode: ChartLiveTrackingMode,
        currentWindowWidth: Double,
        globalXDomain: ClosedRange<Double>
    ) {
        guard mode.pausedBehavior == .preserveTrailingOffset,
              currentWindowWidth.isFinite,
              currentWindowWidth > 0 else {
            clampVisibleDomains(globalXDomain: globalXDomain, globalYDomain: nil)
            return
        }

        let offset = pausedTrailingOffset ?? trailingOffset(from: globalXDomain) ?? 0
        pausedTrailingOffset = max(0, offset)

        let upper = globalXDomain.upperBound - max(0, offset)
        let lower = upper - currentWindowWidth
        visibleXDomain = clamp(lower...upper, within: globalXDomain)
    }

    private func isAtTrailingEdge(
        globalXDomain: ClosedRange<Double>,
        toleranceRatio: Double
    ) -> Bool {
        guard let visibleXDomain else { return true }

        let windowWidth = max(visibleXDomain.upperBound - visibleXDomain.lowerBound, 0)
        let tolerance = max(windowWidth * max(0, toleranceRatio), .ulpOfOne)
        return abs(globalXDomain.upperBound - visibleXDomain.upperBound) <= tolerance
    }

    private func trailingOffset(from globalXDomain: ClosedRange<Double>) -> Double? {
        guard let visibleXDomain else { return nil }
        return max(0, globalXDomain.upperBound - visibleXDomain.upperBound)
    }

    private func zoomed(
        _ start: ClosedRange<Double>,
        by magnification: CGFloat,
        within global: ClosedRange<Double>,
        minScale: Double
    ) -> ClosedRange<Double> {
        guard magnification.isFinite, magnification > 0 else { return start }

        let globalRange = global.upperBound - global.lowerBound
        var newRange    = (start.upperBound - start.lowerBound) / Double(magnification)
        newRange = min(newRange, globalRange)
        newRange = max(newRange, globalRange * minScale)
        let center  = start.lowerBound + (start.upperBound - start.lowerBound) / 2
        var lo = center - newRange / 2
        var hi = center + newRange / 2
        if lo < global.lowerBound { let c = global.lowerBound - lo; lo += c; hi += c }
        if hi > global.upperBound { let c = hi - global.upperBound; lo -= c; hi -= c }
        return lo...hi
    }
}
