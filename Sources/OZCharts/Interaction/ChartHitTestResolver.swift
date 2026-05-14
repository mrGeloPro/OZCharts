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
        contexts
            .filter { $0.contains(location) }
            .sorted {
                if $0.zIndex == $1.zIndex {
                    return ($0.payload.seriesIndex ?? 0) > ($1.payload.seriesIndex ?? 0)
                }
                return $0.zIndex > $1.zIndex
            }
            .first
            .map { [$0] } ?? []
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
        guard !contexts.isEmpty else { return [] }

        let selected: [ChartPointContext<Point>]
        switch mode {
        case .none:
            selected = []

        case .pointsInRadius:
            let radiusSq = radius * radius
            selected = contexts.filter {
                distanceSquared(from: $0.position, to: location) <= radiusSq
            }

        case .nearestPoint:
            selected = contexts.min {
                distanceSquared(from: $0.position, to: location) <
                distanceSquared(from: $1.position, to: location)
            }.map { [$0] } ?? []

        case .nearestX:
            guard let nearest = contexts.min(by: {
                abs($0.position.x - location.x) < abs($1.position.x - location.x)
            }) else {
                return []
            }
            selected = contexts.filter { $0.originalPoint.x == nearest.originalPoint.x }
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

    private static func distanceSquared(from lhs: CGPoint, to rhs: CGPoint) -> CGFloat {
        let dx = lhs.x - rhs.x
        let dy = lhs.y - rhs.y
        return dx * dx + dy * dy
    }
}
