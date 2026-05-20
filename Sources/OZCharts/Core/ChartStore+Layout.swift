//
//  ChartStore+Layout.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension ChartStore {
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

        if !coalesce {
            let shouldAnimate = applySeriesUpdate(
                series: series,
                in: size,
                animate: animate
            )
            if shouldAnimate {
                let animation = series.first(where: { $0.animation.swiftUIAnimation != nil })?.animation.swiftUIAnimation
                layoutTask = Task { @MainActor in
                    await Task.yield()
                    guard !Task.isCancelled, currentID == self.updateCounter else { return }
                    withAnimation(animation) { animationProgress = 1.0 }
                    if currentID == self.updateCounter {
                        layoutTask = nil
                    }
                }
            } else {
                layoutTask = nil
            }
            return
        }

        layoutTask = Task { @MainActor in
            if coalesce, layoutCoalescingIntervalNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: layoutCoalescingIntervalNanoseconds)
            }

            guard !Task.isCancelled, currentID == self.updateCounter else { return }

            let shouldAnimate = applySeriesUpdate(
                series: series,
                in: size,
                animate: animate
            )

            if shouldAnimate {
                let anim = series.first(where: { $0.animation.swiftUIAnimation != nil })?.animation.swiftUIAnimation
                await Task.yield()
                guard !Task.isCancelled, currentID == self.updateCounter else { return }
                withAnimation(anim) { animationProgress = 1.0 }
            }

            if currentID == self.updateCounter {
                layoutTask = nil
            }
        }
    }

    @discardableResult
    private func applySeriesUpdate(
        series: [AnyChartSeries<Point>],
        in size: CGSize,
        animate: Bool
    ) -> Bool {
        let previousContexts = seriesContexts
        let previousRenderContexts = renderSeriesContexts
        let hasAnimation = series.contains { $0.animation.swiftUIAnimation != nil }
        let shouldAnimate = animate && hasAnimation

        let newContexts = calculateSeriesContexts(for: series, in: size)
        let newRenderContexts = calculateRenderSeriesContexts(for: series, contexts: newContexts, in: size)
        let newElements = calculateSelectionElementContexts(for: series, contexts: newContexts, in: size)

        var resetTransaction = Transaction()
        resetTransaction.disablesAnimations = true
        withTransaction(resetTransaction) {
            if shouldAnimate {
                oldSeriesContexts = previousContexts
                oldRenderSeriesContexts = previousRenderContexts
                animationProgress = 0.0
                animationPhase &+= 1
                isAnimationActive = true
            } else {
                oldSeriesContexts = []
                oldRenderSeriesContexts = []
                animationProgress = 1.0
                isAnimationActive = false
            }

            seriesContexts = newContexts
            renderSeriesContexts = newRenderContexts
            pointInteractionIndex = nil
            selectableElements = newElements
        }

        return shouldAnimate
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

    func currentPointInteractionIndex(
        preferredHitRadius: CGFloat = 20
    ) -> ChartPointInteractionIndex<Point> {
        if let pointInteractionIndex {
            return pointInteractionIndex
        }

        let newIndex = ChartPointInteractionIndex(
            seriesContexts: seriesContexts,
            canvasSize: canvasSize,
            preferredHitRadius: preferredHitRadius
        )
        pointInteractionIndex = newIndex
        return newIndex
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

    private func calculateRenderSeriesContexts(
        for series: [AnyChartSeries<Point>],
        contexts: [[ChartPointContext<Point>]],
        in size: CGSize
    ) -> [[ChartPointContext<Point>]] {
        let sorted = series.sorted { $0.zIndex < $1.zIndex }
        return sorted.enumerated().map { index, series in
            let seriesContexts = contexts[safe: index] ?? []
            return series.renderContexts(from: seriesContexts, in: size)
        }
    }
}
