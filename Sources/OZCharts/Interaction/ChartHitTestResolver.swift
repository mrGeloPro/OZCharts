//
//  ChartHitTestResolver.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

enum ChartHitTestResolver {
    static func elements(
        near location: CGPoint,
        contexts: [ChartElementContext]
    ) -> [ChartSelectedElement] {
        var cycleIDs: [UUID] = []
        var cycleIndex = 0
        return elements(
            near: location,
            contexts: contexts,
            overlappingSelectionMode: .cycle,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        )
    }

    static func elements(
        near location: CGPoint,
        contexts: [ChartElementContext],
        overlappingSelectionMode: ChartOverlappingSelectionMode,
        cycleIDs: inout [UUID],
        cycleIndex: inout Int
    ) -> [ChartSelectedElement] {
        elementContexts(
            near: location,
            contexts: contexts,
            overlappingSelectionMode: overlappingSelectionMode,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        ).map(\.payload)
    }

    static func elementContexts(
        near location: CGPoint,
        contexts: [ChartElementContext]
    ) -> [ChartElementContext] {
        var cycleIDs: [UUID] = []
        var cycleIndex = 0
        return elementContexts(
            near: location,
            contexts: contexts,
            overlappingSelectionMode: .cycle,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        )
    }

    static func elementContexts(
        near location: CGPoint,
        contexts: [ChartElementContext],
        overlappingSelectionMode: ChartOverlappingSelectionMode,
        cycleIDs: inout [UUID],
        cycleIndex: inout Int
    ) -> [ChartElementContext] {
        let selected = contexts
            .filter { $0.contains(location) }
            .sorted { lhs, rhs in
                if lhs.zIndex != rhs.zIndex {
                    return lhs.zIndex > rhs.zIndex
                }
                return (lhs.payload.seriesIndex ?? 0) > (rhs.payload.seriesIndex ?? 0)
            }

        let resolved = resolveOverlappingElements(
            selected,
            mode: overlappingSelectionMode,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        )

        return resolved.map { context in
            var copy = context
            copy.payload.interactionPosition = location
            return copy
        }
    }

    static func points<Point: ChartDataPoint>(
        near location: CGPoint,
        contexts: [ChartPointContext<Point>],
        radius: CGFloat,
        mode: ChartSelectionMode,
        overlappingSelectionMode: ChartOverlappingSelectionMode,
        cycleIDs: inout [UUID],
        cycleIndex: inout Int
    ) -> [ChartPointContext<Point>] where Point.XValue == Double, Point.YValue == Double {
        points(
            near: location,
            index: ChartPointInteractionIndex(
                contexts: contexts,
                preferredHitRadius: radius
            ),
            radius: radius,
            mode: mode,
            overlappingSelectionMode: overlappingSelectionMode,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        )
    }

    static func points<Point: ChartDataPoint>(
        near location: CGPoint,
        index: ChartPointInteractionIndex<Point>,
        radius: CGFloat,
        mode: ChartSelectionMode,
        overlappingSelectionMode: ChartOverlappingSelectionMode,
        cycleIDs: inout [UUID],
        cycleIndex: inout Int
    ) -> [ChartPointContext<Point>] where Point.XValue == Double, Point.YValue == Double {
        guard !index.isEmpty else { return [] }

        let selected: [ChartPointContext<Point>] = switch mode {
        case .none:
            []

        case .pointsInRadius:
            index.pointsInRadius(
                near: location,
                radius: radius
            )

        case .nearestPoint:
            index.nearestPoint(near: location).map { [$0] } ?? []

        case .nearestX:
            index.nearestXPoints(near: location)
        }

        return resolveOverlappingSelection(
            selected,
            mode: overlappingSelectionMode,
            cycleIDs: &cycleIDs,
            cycleIndex: &cycleIndex
        )
    }

    private static func resolveOverlappingSelection<Point: ChartDataPoint>(
        _ selected: [ChartPointContext<Point>],
        mode: ChartOverlappingSelectionMode,
        cycleIDs: inout [UUID],
        cycleIndex: inout Int
    ) -> [ChartPointContext<Point>] where Point.XValue == Double, Point.YValue == Double {
        guard mode == .cycle, selected.count > 1 else {
            if selected.count <= 1 {
                cycleIDs = []
                cycleIndex = 0
            }
            return selected
        }

        let ids = selected.map(\.id)
        if ids == cycleIDs {
            cycleIndex = (cycleIndex + 1) % selected.count
        } else {
            cycleIDs = ids
            cycleIndex = 0
        }

        return [selected[cycleIndex]]
    }

    private static func resolveOverlappingElements(
        _ selected: [ChartElementContext],
        mode: ChartOverlappingSelectionMode,
        cycleIDs: inout [UUID],
        cycleIndex: inout Int
    ) -> [ChartElementContext] {
        switch mode {
        case .all:
            if selected.count <= 1 {
                cycleIDs = []
                cycleIndex = 0
            }
            return selected

        case .cycle:
            guard selected.count > 1 else {
                cycleIDs = []
                cycleIndex = 0
                return selected
            }

            let ids = selected.map(\.id)
            if ids == cycleIDs {
                cycleIndex = (cycleIndex + 1) % selected.count
            } else {
                cycleIDs = ids
                cycleIndex = 0
            }

            return [selected[cycleIndex]]
        }
    }
}
