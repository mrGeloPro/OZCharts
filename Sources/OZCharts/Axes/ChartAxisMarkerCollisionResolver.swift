//
//  ChartAxisMarkerCollisionResolver.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

struct ChartAxisMarkerLayoutCandidate {
    let id: UUID
    let axis: ChartAxisMarkerAxis
    let placement: ChartAxisMarkerPlacement
    let anchor: CGPoint
    let position: CGPoint
    let size: CGSize
    let compactSize: CGSize?
    let priority: Double
    let collisionStrategy: ChartAxisMarkerCollisionStrategy
    let originalIndex: Int
}

struct ChartAxisMarkerLayoutResult {
    let id: UUID
    let anchor: CGPoint
    let position: CGPoint
    let frame: CGRect
    let isVisible: Bool
    let usesCompactContent: Bool
    let originalIndex: Int
}

enum ChartAxisMarkerCollisionResolver {
    static func resolve(
        _ candidates: [ChartAxisMarkerLayoutCandidate],
        bounds: CGRect
    ) -> [ChartAxisMarkerLayoutResult] {
        let groups = Dictionary(grouping: candidates) { candidate in
            ChartAxisMarkerCollisionGroup(
                axis: candidate.axis,
                placement: candidate.placement
            )
        }

        return groups.values
            .flatMap { resolveGroup($0, bounds: bounds) }
            .sorted { $0.originalIndex < $1.originalIndex }
    }
}

private extension ChartAxisMarkerCollisionResolver {
    static func resolveGroup(
        _ candidates: [ChartAxisMarkerLayoutCandidate],
        bounds: CGRect
    ) -> [ChartAxisMarkerLayoutResult] {
        let sorted = candidates.sorted { first, second in
            if first.priority != second.priority {
                return first.priority > second.priority
            }
            return first.originalIndex < second.originalIndex
        }

        var placedFrames: [CGRect] = []
        var results: [ChartAxisMarkerLayoutResult] = []

        for candidate in sorted {
            let result = resolve(candidate, placedFrames: placedFrames, bounds: bounds)
            results.append(result)

            if result.isVisible {
                placedFrames.append(result.frame)
            }
        }

        return results
    }

    static func resolve(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect],
        bounds: CGRect
    ) -> ChartAxisMarkerLayoutResult {
        switch candidate.collisionStrategy {
        case .allowOverlap:
            return result(for: candidate, position: candidate.position, compact: false)

        case .hideLowerPriority:
            return hideIfNeeded(candidate, placedFrames: placedFrames)

        case .hideLabel:
            return compactIfNeeded(candidate, placedFrames: placedFrames)

        case let .shift(maxOffset):
            return shiftedOrVisible(
                candidate,
                placedFrames: placedFrames,
                bounds: bounds,
                maxOffset: maxOffset
            )

        case let .stack(spacing):
            return stackedOrVisible(
                candidate,
                placedFrames: placedFrames,
                bounds: bounds,
                spacing: spacing
            )

        case .automatic:
            return automatic(candidate, placedFrames: placedFrames, bounds: bounds)
        }
    }

    static func hideIfNeeded(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect]
    ) -> ChartAxisMarkerLayoutResult {
        let frame = rect(center: candidate.position, size: candidate.size)
        guard intersects(frame, placedFrames) else {
            return result(for: candidate, position: candidate.position, compact: false)
        }

        return hiddenResult(for: candidate, frame: frame)
    }

    static func compactIfNeeded(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect]
    ) -> ChartAxisMarkerLayoutResult {
        let fullFrame = rect(center: candidate.position, size: candidate.size)
        guard intersects(fullFrame, placedFrames),
              let compactSize = candidate.compactSize
        else {
            return result(for: candidate, position: candidate.position, compact: false)
        }

        let compactFrame = rect(center: candidate.position, size: compactSize)
        return ChartAxisMarkerLayoutResult(
            id: candidate.id,
            anchor: candidate.anchor,
            position: candidate.position,
            frame: compactFrame,
            isVisible: true,
            usesCompactContent: true,
            originalIndex: candidate.originalIndex
        )
    }

    static func shiftedOrVisible(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect],
        bounds: CGRect,
        maxOffset: CGFloat
    ) -> ChartAxisMarkerLayoutResult {
        if let position = firstNonConflictingShift(
            candidate,
            placedFrames: placedFrames,
            bounds: bounds,
            maxOffset: maxOffset
        ) {
            return result(for: candidate, position: position, compact: false)
        }

        return result(for: candidate, position: candidate.position, compact: false)
    }

    static func stackedOrVisible(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect],
        bounds: CGRect,
        spacing: CGFloat
    ) -> ChartAxisMarkerLayoutResult {
        if let position = firstNonConflictingStack(
            candidate,
            placedFrames: placedFrames,
            bounds: bounds,
            spacing: spacing
        ) {
            return result(for: candidate, position: position, compact: false)
        }

        return result(for: candidate, position: candidate.position, compact: false)
    }

    static func automatic(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect],
        bounds: CGRect
    ) -> ChartAxisMarkerLayoutResult {
        let fullFrame = rect(center: candidate.position, size: candidate.size)
        guard intersects(fullFrame, placedFrames) else {
            return result(for: candidate, position: candidate.position, compact: false)
        }

        if let compactSize = candidate.compactSize {
            let compactFrame = rect(center: candidate.position, size: compactSize)
            if !intersects(compactFrame, placedFrames), bounds.contains(compactFrame) {
                return ChartAxisMarkerLayoutResult(
                    id: candidate.id,
                    anchor: candidate.anchor,
                    position: candidate.position,
                    frame: compactFrame,
                    isVisible: true,
                    usesCompactContent: true,
                    originalIndex: candidate.originalIndex
                )
            }
        }

        if let shiftedPosition = firstNonConflictingShift(
            candidate,
            placedFrames: placedFrames,
            bounds: bounds,
            maxOffset: 18
        ) {
            return result(for: candidate, position: shiftedPosition, compact: false)
        }

        if let stackedPosition = firstNonConflictingStack(
            candidate,
            placedFrames: placedFrames,
            bounds: bounds,
            spacing: 4
        ) {
            return result(for: candidate, position: stackedPosition, compact: false)
        }

        return hiddenResult(for: candidate, frame: fullFrame)
    }

    static func firstNonConflictingShift(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect],
        bounds: CGRect,
        maxOffset: CGFloat
    ) -> CGPoint? {
        for offset in shiftOffsets(upTo: maxOffset) {
            let position = shiftedPosition(for: candidate, offset: offset)
            let frame = rect(center: position, size: candidate.size)
            if !intersects(frame, placedFrames), bounds.contains(frame) {
                return position
            }
        }

        return nil
    }

    static func firstNonConflictingStack(
        _ candidate: ChartAxisMarkerLayoutCandidate,
        placedFrames: [CGRect],
        bounds: CGRect,
        spacing: CGFloat
    ) -> CGPoint? {
        let step = stackStep(for: candidate, spacing: spacing)

        for multiplier in 1...8 {
            let position = CGPoint(
                x: candidate.position.x + step.dx * CGFloat(multiplier),
                y: candidate.position.y + step.dy * CGFloat(multiplier)
            )
            let frame = rect(center: position, size: candidate.size)
            if !intersects(frame, placedFrames), bounds.contains(frame) {
                return position
            }
        }

        return nil
    }

    static func result(
        for candidate: ChartAxisMarkerLayoutCandidate,
        position: CGPoint,
        compact: Bool
    ) -> ChartAxisMarkerLayoutResult {
        let size = compact ? candidate.compactSize ?? candidate.size : candidate.size
        return ChartAxisMarkerLayoutResult(
            id: candidate.id,
            anchor: candidate.anchor,
            position: position,
            frame: rect(center: position, size: size),
            isVisible: true,
            usesCompactContent: compact,
            originalIndex: candidate.originalIndex
        )
    }

    static func hiddenResult(
        for candidate: ChartAxisMarkerLayoutCandidate,
        frame: CGRect
    ) -> ChartAxisMarkerLayoutResult {
        ChartAxisMarkerLayoutResult(
            id: candidate.id,
            anchor: candidate.anchor,
            position: candidate.position,
            frame: frame,
            isVisible: false,
            usesCompactContent: false,
            originalIndex: candidate.originalIndex
        )
    }

    static func shiftedPosition(
        for candidate: ChartAxisMarkerLayoutCandidate,
        offset: CGFloat
    ) -> CGPoint {
        switch candidate.axis {
        case .x:
            return CGPoint(x: candidate.position.x + offset, y: candidate.position.y)
        case .y:
            return CGPoint(x: candidate.position.x, y: candidate.position.y + offset)
        }
    }

    static func stackStep(
        for candidate: ChartAxisMarkerLayoutCandidate,
        spacing: CGFloat
    ) -> CGVector {
        let size = candidate.size
        switch candidate.placement {
        case .top:
            return CGVector(dx: 0, dy: -(size.height + spacing))
        case .bottom:
            return CGVector(dx: 0, dy: size.height + spacing)
        case .leading:
            return CGVector(dx: -(size.width + spacing), dy: 0)
        case .trailing:
            return CGVector(dx: size.width + spacing, dy: 0)
        }
    }

    static func shiftOffsets(upTo maxOffset: CGFloat) -> [CGFloat] {
        guard maxOffset > 0 else { return [0] }

        let step = max(4, min(8, maxOffset / 4))
        var values: [CGFloat] = [0]
        var current = step

        while current <= maxOffset {
            values.append(current)
            values.append(-current)
            current += step
        }

        return values
    }

    static func intersects(_ frame: CGRect, _ frames: [CGRect]) -> Bool {
        frames.contains { frame.intersects($0) }
    }

    static func rect(center: CGPoint, size: CGSize) -> CGRect {
        let resolvedSize = CGSize(
            width: max(size.width, 1),
            height: max(size.height, 1)
        )
        return CGRect(
            x: center.x - resolvedSize.width / 2,
            y: center.y - resolvedSize.height / 2,
            width: resolvedSize.width,
            height: resolvedSize.height
        )
    }
}

private struct ChartAxisMarkerCollisionGroup: Hashable {
    let axis: ChartAxisMarkerAxis
    let placement: ChartAxisMarkerPlacement
}
