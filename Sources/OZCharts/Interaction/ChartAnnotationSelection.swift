//
//  ChartAnnotationSelection.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

struct ChartAnnotationSelectionCycle {
    private var ids: [UUID] = []
    private var index: Int = 0

    mutating func resolve(
        _ selected: [ChartAnnotationContext],
        mode: ChartOverlappingSelectionMode
    ) -> [ChartAnnotationContext] {
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

enum ChartAnnotationSelectionResolver {
    static func select(
        near location: CGPoint,
        contexts: [ChartAnnotationContext],
        defaultRadius: CGFloat,
        overlappingMode: ChartOverlappingSelectionMode,
        cycle: inout ChartAnnotationSelectionCycle
    ) -> [ChartAnnotationContext] {
        let selected = contexts.filter { context in
            let radius = context.hitboxRadius ?? defaultRadius
            let dx = context.position.x - location.x
            let dy = context.position.y - location.y
            return (dx * dx + dy * dy) <= (radius * radius)
        }

        return cycle.resolve(selected, mode: overlappingMode)
    }
}
