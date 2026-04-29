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
        let preferred = preferredPosition(
            anchor: anchor,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding
        )

        return clamp(preferred, tooltipSize: tooltipSize, canvasSize: canvasSize, padding: padding)
    }

    private static func preferredPosition(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat
    ) -> CGPoint {
        switch placement {
        case .automatic:
            if anchor.y - tooltipSize.height - padding > 0 {
                return preferredPosition(anchor: anchor, tooltipSize: tooltipSize, canvasSize: canvasSize, placement: .top, offset: offset, padding: padding)
            }
            if anchor.y + tooltipSize.height + padding < canvasSize.height {
                return preferredPosition(anchor: anchor, tooltipSize: tooltipSize, canvasSize: canvasSize, placement: .bottom, offset: offset, padding: padding)
            }
            if anchor.x + tooltipSize.width + padding < canvasSize.width {
                return preferredPosition(anchor: anchor, tooltipSize: tooltipSize, canvasSize: canvasSize, placement: .trailing, offset: offset, padding: padding)
            }
            if anchor.x - tooltipSize.width - padding > 0 {
                return preferredPosition(anchor: anchor, tooltipSize: tooltipSize, canvasSize: canvasSize, placement: .leading, offset: offset, padding: padding)
            }
            return preferredPosition(anchor: anchor, tooltipSize: tooltipSize, canvasSize: canvasSize, placement: .center, offset: offset, padding: padding)

        case .top:
            return CGPoint(
                x: anchor.x + offset.x,
                y: anchor.y - tooltipSize.height / 2 + offset.y
            )

        case .bottom:
            return CGPoint(
                x: anchor.x + offset.x,
                y: anchor.y + tooltipSize.height / 2 - offset.y
            )

        case .leading:
            return CGPoint(
                x: anchor.x - tooltipSize.width / 2 + offset.x,
                y: anchor.y + offset.y
            )

        case .trailing:
            return CGPoint(
                x: anchor.x + tooltipSize.width / 2 + offset.x,
                y: anchor.y + offset.y
            )

        case .center:
            return CGPoint(x: anchor.x + offset.x, y: anchor.y + offset.y)

        case .fixed(let point):
            return CGPoint(x: point.x + offset.x, y: point.y + offset.y)
        }
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
