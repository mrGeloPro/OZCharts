//
//  ChartLabelCollisionResolver.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public enum ChartLabelPlacement: Equatable {
    case automatic
    case top
    case bottom
    case leading
    case trailing
    case center
    case fixed(CGPoint)
}

public struct ChartLabelCandidate: Identifiable, Equatable {
    public let id: UUID
    public var anchor: CGPoint
    public var size: CGSize
    public var priority: Int
    public var preferredPlacements: [ChartLabelPlacement]
    public var padding: CGFloat
    public var spacing: CGFloat
    public var canHide: Bool

    public init(
        id: UUID = UUID(),
        anchor: CGPoint,
        size: CGSize,
        priority: Int = 0,
        preferredPlacements: [ChartLabelPlacement] = [.automatic],
        padding: CGFloat = 8,
        spacing: CGFloat = 6,
        canHide: Bool = true
    ) {
        self.id = id
        self.anchor = anchor
        self.size = size
        self.priority = priority
        self.preferredPlacements = preferredPlacements
        self.padding = padding
        self.spacing = spacing
        self.canHide = canHide
    }
}

public struct ChartResolvedLabel: Identifiable, Equatable {
    public let id: UUID
    public var anchor: CGPoint
    public var position: CGPoint
    public var size: CGSize
    public var placement: ChartLabelPlacement
    public var isVisible: Bool

    public var bounds: CGRect {
        CGRect(
            x: position.x - size.width / 2,
            y: position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}

public enum ChartLabelCollisionResolver {
    public static func resolve(
        candidates: [ChartLabelCandidate],
        canvasSize: CGSize,
        avoidanceRects: [CGRect] = []
    ) -> [ChartResolvedLabel] {
        guard canvasSize.width > 0, canvasSize.height > 0 else {
            return candidates.map { hiddenLabel(for: $0) }
        }

        var occupied = avoidanceRects
        var resolvedByID: [UUID: ChartResolvedLabel] = [:]

        for candidate in candidates.sorted(by: prioritySort) {
            let placements = expandedPlacements(candidate.preferredPlacements)
            let options = placements.map { placement in
                label(
                    for: candidate,
                    placement: placement,
                    canvasSize: canvasSize
                )
            }

            if let fitting = options.first(where: {
                !intersectsAny($0.bounds, occupied) && isInside($0.bounds, canvasSize: canvasSize, padding: candidate.padding)
            }) {
                resolvedByID[candidate.id] = fitting
                occupied.append(fitting.bounds.insetBy(dx: -candidate.spacing, dy: -candidate.spacing))
                continue
            }

            let fallback = options
                .map { clamp($0, canvasSize: canvasSize, padding: candidate.padding) }
                .min {
                    collisionPenalty($0.bounds, occupied: occupied, canvasSize: canvasSize, padding: candidate.padding) <
                    collisionPenalty($1.bounds, occupied: occupied, canvasSize: canvasSize, padding: candidate.padding)
                } ?? hiddenLabel(for: candidate)

            if candidate.canHide && intersectsAny(fallback.bounds, occupied) {
                resolvedByID[candidate.id] = hiddenLabel(for: candidate)
            } else {
                resolvedByID[candidate.id] = fallback
                occupied.append(fallback.bounds.insetBy(dx: -candidate.spacing, dy: -candidate.spacing))
            }
        }

        return candidates.compactMap { resolvedByID[$0.id] }
    }

    public static func clampCenter(
        _ center: CGPoint,
        size: CGSize,
        canvasSize: CGSize,
        padding: CGFloat
    ) -> CGPoint {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let minX = padding + halfWidth
        let maxX = max(minX, canvasSize.width - padding - halfWidth)
        let minY = padding + halfHeight
        let maxY = max(minY, canvasSize.height - padding - halfHeight)

        return CGPoint(
            x: min(max(center.x, minX), maxX),
            y: min(max(center.y, minY), maxY)
        )
    }

    private static func prioritySort(lhs: ChartLabelCandidate, rhs: ChartLabelCandidate) -> Bool {
        if lhs.priority == rhs.priority { return lhs.id.uuidString < rhs.id.uuidString }
        return lhs.priority > rhs.priority
    }

    private static func expandedPlacements(_ placements: [ChartLabelPlacement]) -> [ChartLabelPlacement] {
        let expanded = placements.flatMap { placement -> [ChartLabelPlacement] in
            if placement == .automatic {
                return [.top, .bottom, .trailing, .leading, .center]
            }
            return [placement]
        }
        return expanded.isEmpty ? [.center] : expanded
    }

    private static func label(
        for candidate: ChartLabelCandidate,
        placement: ChartLabelPlacement,
        canvasSize: CGSize
    ) -> ChartResolvedLabel {
        let position: CGPoint
        switch placement {
        case .automatic:
            position = candidate.anchor
        case .top:
            position = CGPoint(x: candidate.anchor.x, y: candidate.anchor.y - candidate.size.height / 2 - candidate.spacing)
        case .bottom:
            position = CGPoint(x: candidate.anchor.x, y: candidate.anchor.y + candidate.size.height / 2 + candidate.spacing)
        case .leading:
            position = CGPoint(x: candidate.anchor.x - candidate.size.width / 2 - candidate.spacing, y: candidate.anchor.y)
        case .trailing:
            position = CGPoint(x: candidate.anchor.x + candidate.size.width / 2 + candidate.spacing, y: candidate.anchor.y)
        case .center:
            position = candidate.anchor
        case .fixed(let point):
            position = point
        }

        return ChartResolvedLabel(
            id: candidate.id,
            anchor: candidate.anchor,
            position: position,
            size: candidate.size,
            placement: placement,
            isVisible: true
        )
    }

    private static func clamp(
        _ label: ChartResolvedLabel,
        canvasSize: CGSize,
        padding: CGFloat
    ) -> ChartResolvedLabel {
        var label = label
        label.position = clampCenter(
            label.position,
            size: label.size,
            canvasSize: canvasSize,
            padding: padding
        )
        return label
    }

    private static func hiddenLabel(for candidate: ChartLabelCandidate) -> ChartResolvedLabel {
        ChartResolvedLabel(
            id: candidate.id,
            anchor: candidate.anchor,
            position: candidate.anchor,
            size: candidate.size,
            placement: candidate.preferredPlacements.first ?? .center,
            isVisible: false
        )
    }

    private static func isInside(_ rect: CGRect, canvasSize: CGSize, padding: CGFloat) -> Bool {
        rect.minX >= padding &&
        rect.maxX <= canvasSize.width - padding &&
        rect.minY >= padding &&
        rect.maxY <= canvasSize.height - padding
    }

    private static func intersectsAny(_ rect: CGRect, _ rects: [CGRect]) -> Bool {
        rects.contains { rect.intersects($0) }
    }

    private static func collisionPenalty(
        _ rect: CGRect,
        occupied: [CGRect],
        canvasSize: CGSize,
        padding: CGFloat
    ) -> CGFloat {
        let canvasBounds = CGRect(
            x: padding,
            y: padding,
            width: max(0, canvasSize.width - padding * 2),
            height: max(0, canvasSize.height - padding * 2)
        )
        let outsidePenalty = rectArea(rect) - rectArea(rect.intersection(canvasBounds))
        let collisionPenalty = occupied.reduce(CGFloat.zero) { partial, other in
            partial + rectArea(rect.intersection(other))
        }
        return outsidePenalty + collisionPenalty
    }

    private static func rectArea(_ rect: CGRect) -> CGFloat {
        guard !rect.isNull, rect.width > 0, rect.height > 0 else { return 0 }
        return rect.width * rect.height
    }
}
