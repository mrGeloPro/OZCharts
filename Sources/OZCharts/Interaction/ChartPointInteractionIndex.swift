//
//  ChartPointInteractionIndex.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

struct ChartPointInteractionIndex<Point: ChartDataPoint>
    where Point.XValue == Double, Point.YValue == Double {
    struct IndexedContext {
        let context: ChartPointContext<Point>
        let order: Int
    }

    private struct OriginalXEntry {
        let x: Double
        let order: Int
    }

    private let indexedContexts: [IndexedContext]
    private let sortedByPositionX: [IndexedContext]
    private let spatialGrid: ChartInteractionSpatialGrid<Point>
    private let contextsByOriginalX: [Double: [ChartPointContext<Point>]]
    private let originalXEntries: [OriginalXEntry]

    init(
        seriesContexts: [[ChartPointContext<Point>]],
        canvasSize: CGSize? = nil,
        preferredHitRadius: CGFloat = 20
    ) {
        self.init(
            contexts: seriesContexts.flatMap { $0 },
            canvasSize: canvasSize,
            preferredHitRadius: preferredHitRadius
        )
    }

    init(
        contexts: [ChartPointContext<Point>],
        canvasSize: CGSize? = nil,
        preferredHitRadius: CGFloat = 20
    ) {
        var indexedContexts: [IndexedContext] = []
        indexedContexts.reserveCapacity(contexts.count)

        var contextsByOriginalX: [Double: [ChartPointContext<Point>]] = [:]
        var originalXOrder: [Double: Int] = [:]

        for (order, context) in contexts.enumerated() {
            indexedContexts.append(IndexedContext(context: context, order: order))

            let x = context.originalPoint.x
            contextsByOriginalX[x, default: []].append(context)
            if originalXOrder[x] == nil {
                originalXOrder[x] = order
            }
        }

        self.indexedContexts = indexedContexts
        self.sortedByPositionX = indexedContexts.sorted {
            if $0.context.position.x == $1.context.position.x {
                return $0.order < $1.order
            }
            return $0.context.position.x < $1.context.position.x
        }
        self.spatialGrid = ChartInteractionSpatialGrid(
            indexedContexts: indexedContexts,
            canvasSize: canvasSize,
            preferredHitRadius: preferredHitRadius
        )
        self.contextsByOriginalX = contextsByOriginalX
        self.originalXEntries = originalXOrder
            .map { OriginalXEntry(x: $0.key, order: $0.value) }
            .sorted {
                if $0.x == $1.x {
                    return $0.order < $1.order
                }
                return $0.x < $1.x
            }
    }

    var isEmpty: Bool {
        indexedContexts.isEmpty
    }

    func pointsInRadius(
        near location: CGPoint,
        radius: CGFloat
    ) -> [ChartPointContext<Point>] {
        let selected = spatialGrid.pointsInRadius(near: location, radius: radius)
        return selected.sorted { $0.order < $1.order }.map(\.context)
    }

    func nearestPoint(near location: CGPoint) -> ChartPointContext<Point>? {
        spatialGrid.nearestPoint(near: location)?.context
    }

    func nearestXPoints(near location: CGPoint) -> [ChartPointContext<Point>] {
        guard let nearest = nearestScreenXContext(near: location.x) else { return [] }
        return contextsByOriginalX[nearest.originalPoint.x] ?? [nearest]
    }

    func nearestOriginalXValue(_ xValue: Double) -> [ChartPointContext<Point>] {
        guard xValue.isFinite, !originalXEntries.isEmpty else { return [] }

        let insertionIndex = lowerBoundForOriginalX(xValue)
        var bestEntry: OriginalXEntry?
        var bestDistance = Double.greatestFiniteMagnitude

        func evaluate(_ entry: OriginalXEntry) {
            let distance = abs(entry.x - xValue)
            if distance < bestDistance ||
                (distance == bestDistance && entry.order < (bestEntry?.order ?? Int.max)) {
                bestDistance = distance
                bestEntry = entry
            }
        }

        if insertionIndex < originalXEntries.count {
            evaluate(originalXEntries[insertionIndex])
        }
        if insertionIndex > 0 {
            evaluate(originalXEntries[insertionIndex - 1])
        }

        guard let bestEntry else { return [] }
        return contextsByOriginalX[bestEntry.x] ?? []
    }

    func points(byIDs pointIDs: [UUID]) -> [ChartPointContext<Point>] {
        guard !pointIDs.isEmpty else { return [] }

        let selectedIDs = Set(pointIDs)
        return indexedContexts
            .filter { selectedIDs.contains($0.context.originalPoint.id) }
            .map(\.context)
    }

    private func nearestScreenXContext(near screenX: CGFloat) -> ChartPointContext<Point>? {
        guard !sortedByPositionX.isEmpty else { return nil }

        let insertionIndex = lowerBoundForPositionX(screenX)
        var bestItem: IndexedContext?
        var bestDistance = CGFloat.greatestFiniteMagnitude

        func evaluate(_ item: IndexedContext) {
            let distance = abs(item.context.position.x - screenX)
            if distance < bestDistance ||
                (distance == bestDistance && item.order < (bestItem?.order ?? Int.max)) {
                bestDistance = distance
                bestItem = item
            }
        }

        if insertionIndex < sortedByPositionX.count {
            evaluate(sortedByPositionX[insertionIndex])
        }
        if insertionIndex > 0 {
            evaluate(sortedByPositionX[insertionIndex - 1])
        }

        return bestItem?.context
    }

    private func lowerBoundForPositionX(_ x: CGFloat) -> Int {
        var lower = 0
        var upper = sortedByPositionX.count

        while lower < upper {
            let middle = (lower + upper) / 2
            if sortedByPositionX[middle].context.position.x < x {
                lower = middle + 1
            } else {
                upper = middle
            }
        }

        return lower
    }

    private func lowerBoundForOriginalX(_ x: Double) -> Int {
        var lower = 0
        var upper = originalXEntries.count

        while lower < upper {
            let middle = (lower + upper) / 2
            if originalXEntries[middle].x < x {
                lower = middle + 1
            } else {
                upper = middle
            }
        }

        return lower
    }
}
