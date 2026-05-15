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

    private struct CellKey: Hashable {
        let x: Int
        let y: Int
    }

    private struct OccupiedCell {
        let key: CellKey
        let contexts: [IndexedContext]
    }

    private struct SpatialGrid {
        private let cellSize: CGFloat
        private let cells: [CellKey: [IndexedContext]]
        private let occupiedCells: [OccupiedCell]
        private let occupiedXRange: ClosedRange<Int>?
        private let occupiedYRange: ClosedRange<Int>?

        init(
            indexedContexts: [IndexedContext],
            canvasSize: CGSize?,
            preferredHitRadius: CGFloat
        ) {
            self.cellSize = Self.adaptiveCellSize(
                for: indexedContexts,
                canvasSize: canvasSize,
                preferredHitRadius: preferredHitRadius
            )

            var cells: [CellKey: [IndexedContext]] = [:]
            cells.reserveCapacity(indexedContexts.count)

            for item in indexedContexts {
                let position = item.context.position
                guard position.x.isFinite, position.y.isFinite else { continue }
                cells[Self.cellKey(for: position, cellSize: self.cellSize), default: []].append(item)
            }

            self.cells = cells
            self.occupiedCells = cells.map { OccupiedCell(key: $0.key, contexts: $0.value) }
            self.occupiedXRange = Self.occupiedRange(cells.keys.map(\.x))
            self.occupiedYRange = Self.occupiedRange(cells.keys.map(\.y))
        }

        var isEmpty: Bool {
            occupiedCells.isEmpty
        }

        func pointsInRadius(
            near location: CGPoint,
            radius: CGFloat
        ) -> [IndexedContext] {
            guard radius >= 0, location.x.isFinite, location.y.isFinite, !isEmpty else { return [] }

            let minimumCell = Self.cellKey(
                for: CGPoint(x: location.x - radius, y: location.y - radius),
                cellSize: cellSize
            )
            let maximumCell = Self.cellKey(
                for: CGPoint(x: location.x + radius, y: location.y + radius),
                cellSize: cellSize
            )
            let radiusSquared = radius * radius
            var selected: [IndexedContext] = []

            func appendMatches(in contexts: [IndexedContext]) {
                for item in contexts {
                    let dx = item.context.position.x - location.x
                    let dy = item.context.position.y - location.y
                    if dx * dx + dy * dy <= radiusSquared {
                        selected.append(item)
                    }
                }
            }

            let xCellCount = maximumCell.x - minimumCell.x + 1
            let yCellCount = maximumCell.y - minimumCell.y + 1
            if xCellCount > occupiedCells.count ||
                yCellCount > occupiedCells.count ||
                xCellCount * yCellCount > occupiedCells.count {
                for cell in occupiedCells {
                    appendMatches(in: cell.contexts)
                }
            } else {
                for x in minimumCell.x ... maximumCell.x {
                    for y in minimumCell.y ... maximumCell.y {
                        guard let contexts = cells[CellKey(x: x, y: y)] else { continue }
                        appendMatches(in: contexts)
                    }
                }
            }

            return selected
        }

        func nearestPoint(near location: CGPoint) -> IndexedContext? {
            guard location.x.isFinite,
                  location.y.isFinite,
                  let occupiedXRange,
                  let occupiedYRange,
                  !isEmpty else { return nil }

            var bestItem: IndexedContext?
            var bestDistance = CGFloat.greatestFiniteMagnitude

            let locationCell = Self.cellKey(for: location, cellSize: cellSize)
            let centerCell = CellKey(
                x: min(max(locationCell.x, occupiedXRange.lowerBound), occupiedXRange.upperBound),
                y: min(max(locationCell.y, occupiedYRange.lowerBound), occupiedYRange.upperBound)
            )
            let maximumRing = max(
                occupiedXRange.upperBound - occupiedXRange.lowerBound,
                occupiedYRange.upperBound - occupiedYRange.lowerBound
            )

            for ring in 0 ... maximumRing {
                var didVisitCell = false

                visitCells(
                    onRing: ring,
                    around: centerCell,
                    xRange: occupiedXRange,
                    yRange: occupiedYRange
                ) { key in
                    didVisitCell = true
                    guard let contexts = cells[key] else { return }
                    for item in contexts {
                        let dx = item.context.position.x - location.x
                        let dy = item.context.position.y - location.y
                        let distance = dx * dx + dy * dy

                        if distance < bestDistance ||
                            (distance == bestDistance && item.order < (bestItem?.order ?? Int.max)) {
                            bestDistance = distance
                            bestItem = item
                        }
                    }
                }

                guard didVisitCell else { continue }

                let nextRing = ring + 1
                guard nextRing <= maximumRing else { break }
                if minimumDistanceSquared(
                    from: location,
                    toRing: nextRing,
                    around: centerCell,
                    xRange: occupiedXRange,
                    yRange: occupiedYRange
                ) > bestDistance {
                    break
                }
            }

            return bestItem
        }

        private static func cellKey(for position: CGPoint, cellSize: CGFloat) -> CellKey {
            CellKey(
                x: Int(floor(position.x / cellSize)),
                y: Int(floor(position.y / cellSize))
            )
        }

        private static func occupiedRange(_ values: [Int]) -> ClosedRange<Int>? {
            guard let minimum = values.min(), let maximum = values.max() else { return nil }
            return minimum ... maximum
        }

        private static func adaptiveCellSize(
            for indexedContexts: [IndexedContext],
            canvasSize: CGSize?,
            preferredHitRadius: CGFloat
        ) -> CGFloat {
            guard !indexedContexts.isEmpty else {
                return max(4, min(64, preferredHitRadius))
            }

            let fallbackBounds = finitePositionBounds(for: indexedContexts)
            let width = resolvedLength(
                canvasSize?.width,
                fallback: fallbackBounds?.width
            )
            let height = resolvedLength(
                canvasSize?.height,
                fallback: fallbackBounds?.height
            )
            let area = max(1, width * height)
            let density = CGFloat(indexedContexts.count) / area
            let targetPointsPerCell: CGFloat = indexedContexts.count > 50000 ? 128 : 64
            let densityCellSize = density > 0
                ? sqrt(targetPointsPerCell / density)
                : preferredHitRadius
            let radiusCellSize = max(8, preferredHitRadius)
            let candidate = min(densityCellSize, radiusCellSize)

            return max(8, min(64, candidate))
        }

        private static func finitePositionBounds(
            for indexedContexts: [IndexedContext]
        ) -> CGRect? {
            var bounds: CGRect?
            for item in indexedContexts {
                let position = item.context.position
                guard position.x.isFinite, position.y.isFinite else { continue }
                let pointBounds = CGRect(x: position.x, y: position.y, width: 1, height: 1)
                bounds = bounds?.union(pointBounds) ?? pointBounds
            }
            return bounds
        }

        private static func resolvedLength(
            _ length: CGFloat?,
            fallback: CGFloat?
        ) -> CGFloat {
            if let length, length.isFinite, length > 0 {
                return length
            }
            if let fallback, fallback.isFinite, fallback > 0 {
                return fallback
            }
            return 1
        }

        private func visitCells(
            onRing ring: Int,
            around center: CellKey,
            xRange: ClosedRange<Int>,
            yRange: ClosedRange<Int>,
            _ visit: (CellKey) -> Void
        ) {
            guard ring > 0 else {
                guard xRange.contains(center.x), yRange.contains(center.y) else { return }
                visit(center)
                return
            }

            let minimumX = max(center.x - ring, xRange.lowerBound)
            let maximumX = min(center.x + ring, xRange.upperBound)
            let minimumY = max(center.y - ring, yRange.lowerBound)
            let maximumY = min(center.y + ring, yRange.upperBound)

            guard minimumX <= maximumX, minimumY <= maximumY else { return }

            let topY = center.y - ring
            let bottomY = center.y + ring
            if yRange.contains(topY) {
                for x in minimumX ... maximumX {
                    visit(CellKey(x: x, y: topY))
                }
            }
            if bottomY != topY, yRange.contains(bottomY) {
                for x in minimumX ... maximumX {
                    visit(CellKey(x: x, y: bottomY))
                }
            }

            let leftX = center.x - ring
            let rightX = center.x + ring
            let innerMinimumY = max(center.y - ring + 1, yRange.lowerBound)
            let innerMaximumY = min(center.y + ring - 1, yRange.upperBound)
            guard innerMinimumY <= innerMaximumY else { return }

            if xRange.contains(leftX) {
                for y in innerMinimumY ... innerMaximumY {
                    visit(CellKey(x: leftX, y: y))
                }
            }
            if rightX != leftX, xRange.contains(rightX) {
                for y in innerMinimumY ... innerMaximumY {
                    visit(CellKey(x: rightX, y: y))
                }
            }
        }

        private func minimumDistanceSquared(
            from location: CGPoint,
            toRing ring: Int,
            around center: CellKey,
            xRange: ClosedRange<Int>,
            yRange: ClosedRange<Int>
        ) -> CGFloat {
            var minimumDistance = CGFloat.greatestFiniteMagnitude
            visitCells(
                onRing: ring,
                around: center,
                xRange: xRange,
                yRange: yRange
            ) { key in
                minimumDistance = min(
                    minimumDistance,
                    minimumDistanceSquared(from: location, to: key)
                )
            }
            return minimumDistance
        }

        private func minimumDistanceSquared(
            from location: CGPoint,
            to cell: CellKey
        ) -> CGFloat {
            let minimumX = CGFloat(cell.x) * cellSize
            let maximumX = minimumX + cellSize
            let minimumY = CGFloat(cell.y) * cellSize
            let maximumY = minimumY + cellSize

            let dx: CGFloat = if location.x < minimumX {
                minimumX - location.x
            } else if location.x > maximumX {
                location.x - maximumX
            } else {
                0
            }

            let dy: CGFloat = if location.y < minimumY {
                minimumY - location.y
            } else if location.y > maximumY {
                location.y - maximumY
            } else {
                0
            }

            return dx * dx + dy * dy
        }
    }

    private let indexedContexts: [IndexedContext]
    private let sortedByPositionX: [IndexedContext]
    private let spatialGrid: SpatialGrid
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
        self.spatialGrid = SpatialGrid(
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
