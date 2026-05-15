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
        elementContexts(near: location, contexts: contexts).map(\.payload)
    }

    static func elementContexts(
        near location: CGPoint,
        contexts: [ChartElementContext]
    ) -> [ChartElementContext] {
        var bestContext: ChartElementContext?

        for context in contexts where context.contains(location) {
            guard let currentBest = bestContext else {
                bestContext = context
                continue
            }

            if context.zIndex > currentBest.zIndex ||
                (context.zIndex == currentBest.zIndex &&
                    (context.payload.seriesIndex ?? 0) > (currentBest.payload.seriesIndex ?? 0)) {
                bestContext = context
            }
        }

        guard var context = bestContext else { return [] }
        context.payload.interactionPosition = location
        return [context]
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
}
