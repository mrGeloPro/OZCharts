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
    private struct IndexedContext {
        let context: ChartPointContext<Point>
        let order: Int
    }

    private struct OriginalXEntry {
        let x: Double
        let order: Int
    }

    private let indexedContexts: [IndexedContext]
    private let sortedByPositionX: [IndexedContext]
    private let contextsByOriginalX: [Double: [ChartPointContext<Point>]]
    private let originalXEntries: [OriginalXEntry]

    init(seriesContexts: [[ChartPointContext<Point>]]) {
        self.init(contexts: seriesContexts.flatMap { $0 })
    }

    init(contexts: [ChartPointContext<Point>]) {
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
        guard radius >= 0, !sortedByPositionX.isEmpty else { return [] }

        let lowerX = location.x - radius
        let upperX = location.x + radius
        let radiusSquared = radius * radius
        var selected: [IndexedContext] = []

        var index = lowerBoundForPositionX(lowerX)
        while index < sortedByPositionX.count {
            let item = sortedByPositionX[index]
            let dx = item.context.position.x - location.x
            if dx > radius {
                break
            }

            let dy = item.context.position.y - location.y
            if abs(dy) <= radius, dx * dx + dy * dy <= radiusSquared {
                selected.append(item)
            }
            if item.context.position.x > upperX {
                break
            }
            index += 1
        }

        return selected.sorted { $0.order < $1.order }.map(\.context)
    }

    func nearestPoint(near location: CGPoint) -> ChartPointContext<Point>? {
        guard !sortedByPositionX.isEmpty else { return nil }

        let insertionIndex = lowerBoundForPositionX(location.x)
        var bestItem: IndexedContext?
        var bestDistance = CGFloat.greatestFiniteMagnitude

        func evaluate(_ item: IndexedContext) {
            let dx = item.context.position.x - location.x
            let dy = item.context.position.y - location.y
            let distance = dx * dx + dy * dy

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

        var leftIndex = insertionIndex - 1
        while leftIndex >= 0 {
            let item = sortedByPositionX[leftIndex]
            let dx = item.context.position.x - location.x
            guard dx * dx <= bestDistance else { break }
            evaluate(item)
            leftIndex -= 1
        }

        var rightIndex = insertionIndex
        while rightIndex < sortedByPositionX.count {
            let item = sortedByPositionX[rightIndex]
            let dx = item.context.position.x - location.x
            guard dx * dx <= bestDistance else { break }
            evaluate(item)
            rightIndex += 1
        }

        return bestItem?.context
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
