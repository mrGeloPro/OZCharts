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

    var state: ChartViewportState {
        ChartViewportState(
            visibleXDomain: visibleXDomain,
            visibleYDomain: visibleYDomain
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

    mutating func endPan() {
        dragStartXDomain = nil
        dragStartYDomain = nil
        isDragging = false
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

    mutating func endZoom() {
        zoomStartXDomain = nil
        zoomStartYDomain = nil
        isZooming = false
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
    }

    // MARK: - Live tracking

    mutating func applyLiveTracking(
        newGlobalMax: Double,
        currentWindowWidth: Double,
        globalXDomain: ClosedRange<Double>
    ) {
        guard !isDragging, visibleXDomain != nil else {
            return
        }
        let newDomain = (newGlobalMax - currentWindowWidth)...newGlobalMax
        visibleXDomain = clamp(newDomain, within: globalXDomain)
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
