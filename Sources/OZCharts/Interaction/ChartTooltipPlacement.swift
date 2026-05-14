//
//  ChartTooltipPlacement.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public enum ChartTooltipPlacement: Equatable {
    case automatic
    case top
    case bottom
    case leading
    case trailing
    case center
    case fixed(CGPoint)
}

enum ChartTooltipAttachment: Equatable {
    case top
    case bottom
    case leading
    case trailing
    case center
    case fixed
}

struct ChartTooltipLayoutResult: Equatable {
    var position: CGPoint
    var attachment: ChartTooltipAttachment
    var anchor: CGPoint
    var wasClamped: Bool
}

struct ChartTooltipLayout {
    static func anchor(for positions: [CGPoint]) -> CGPoint? {
        guard !positions.isEmpty else { return nil }
        let x = positions.map(\.x).reduce(0, +) / CGFloat(positions.count)
        let y = positions.map(\.y).reduce(0, +) / CGFloat(positions.count)
        return CGPoint(x: x, y: y)
    }

    static func anchor<Point: ChartDataPoint>(
        for points: [ChartPointContext<Point>]
    ) -> CGPoint? {
        anchor(for: points.map(\.position))
    }

    static func position(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat
    ) -> CGPoint {
        resolve(
            anchor: anchor,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding
        ).position
    }

    static func resolve(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat
    ) -> ChartTooltipLayoutResult {
        let preferred = preferredLayout(
            anchor: anchor,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding
        )
        let clamped = clamp(preferred.position, tooltipSize: tooltipSize, canvasSize: canvasSize, padding: padding)

        return ChartTooltipLayoutResult(
            position: clamped,
            attachment: preferred.attachment,
            anchor: anchor,
            wasClamped: clamped != preferred.position
        )
    }

    private static func preferredLayout(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat
    ) -> (position: CGPoint, attachment: ChartTooltipAttachment) {
        switch placement {
        case .automatic:
            let placements: [ChartTooltipPlacement] = [.top, .bottom, .trailing, .leading, .center]
            let candidates = placements.map {
                preferredLayout(
                    anchor: anchor,
                    tooltipSize: tooltipSize,
                    canvasSize: canvasSize,
                    placement: $0,
                    offset: offset,
                    padding: padding
                )
            }
            if let fitting = candidates.first(where: {
                overflowAmount(
                    for: $0.position,
                    tooltipSize: tooltipSize,
                    canvasSize: canvasSize,
                    padding: padding
                ) == 0
            }) {
                return fitting
            }
            return candidates.min {
                overflowAmount(for: $0.position, tooltipSize: tooltipSize, canvasSize: canvasSize, padding: padding) <
                overflowAmount(for: $1.position, tooltipSize: tooltipSize, canvasSize: canvasSize, padding: padding)
            } ?? (anchor, .center)

        case .top:
            return (
                CGPoint(x: anchor.x + offset.x, y: anchor.y - tooltipSize.height / 2 + offset.y),
                .top
            )

        case .bottom:
            return (
                CGPoint(x: anchor.x + offset.x, y: anchor.y + tooltipSize.height / 2 - offset.y),
                .bottom
            )

        case .leading:
            return (
                CGPoint(x: anchor.x - tooltipSize.width / 2 + offset.x, y: anchor.y + offset.y),
                .leading
            )

        case .trailing:
            return (
                CGPoint(x: anchor.x + tooltipSize.width / 2 + offset.x, y: anchor.y + offset.y),
                .trailing
            )

        case .center:
            return (CGPoint(x: anchor.x + offset.x, y: anchor.y + offset.y), .center)

        case .fixed(let point):
            return (CGPoint(x: point.x + offset.x, y: point.y + offset.y), .fixed)
        }
    }

    private static func overflowAmount(
        for point: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        padding: CGFloat
    ) -> CGFloat {
        let halfWidth = tooltipSize.width / 2
        let halfHeight = tooltipSize.height / 2
        let minX = padding + halfWidth
        let maxX = max(minX, canvasSize.width - padding - halfWidth)
        let minY = padding + halfHeight
        let maxY = max(minY, canvasSize.height - padding - halfHeight)

        let xOverflow = max(0, minX - point.x) + max(0, point.x - maxX)
        let yOverflow = max(0, minY - point.y) + max(0, point.y - maxY)
        return xOverflow + yOverflow
    }

    private static func clamp(
        _ point: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        padding: CGFloat
    ) -> CGPoint {
        let halfWidth = tooltipSize.width / 2
        let halfHeight = tooltipSize.height / 2
        let minX = padding + halfWidth
        let maxX = max(minX, canvasSize.width - padding - halfWidth)
        let minY = padding + halfHeight
        let maxY = max(minY, canvasSize.height - padding - halfHeight)

        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }
}
