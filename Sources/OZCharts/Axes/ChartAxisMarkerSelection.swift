//
//  ChartAxisMarkerSelection.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

struct ChartAxisMarkerSelectionCycle {
    private var ids: [UUID] = []
    private var index: Int = 0

    mutating func resolve(
        _ selected: [ChartAxisMarkerContext],
        mode: ChartOverlappingSelectionMode
    ) -> [ChartAxisMarkerContext] {
        guard mode == .cycle, selected.count > 1 else {
            if selected.count <= 1 {
                reset()
            }
            return selected
        }

        let newIDs = selected.map(\.id)
        if newIDs == ids {
            index = (index + 1) % selected.count
        } else {
            ids = newIDs
            index = 0
        }

        return [selected[index]]
    }

    mutating func reset() {
        ids = []
        index = 0
    }
}

enum ChartAxisMarkerSelectionResolver {
    static func select(
        near context: ChartAxisMarkerContext,
        contexts: [ChartAxisMarkerContext],
        defaultRadius: CGFloat,
        overlappingMode: ChartOverlappingSelectionMode,
        cycle: inout ChartAxisMarkerSelectionCycle
    ) -> [ChartAxisMarkerContext] {
        let selected = contexts.filter { candidate in
            let radius = candidate.marker.hitboxRadius ?? defaultRadius
            let hitFrame = candidate.frame.insetBy(dx: -radius, dy: -radius)
            return hitFrame.intersects(context.frame) || hitFrame.contains(context.anchor)
        }

        return cycle.resolve(selected, mode: overlappingMode)
    }
}
