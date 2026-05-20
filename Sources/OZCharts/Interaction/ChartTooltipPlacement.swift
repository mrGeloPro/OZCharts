//
//  ChartTooltipPlacement.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

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

    static func resolvedMaxWidth(
        configuredMaxWidth: CGFloat?,
        canvasWidth: CGFloat,
        padding: CGFloat
    ) -> CGFloat? {
        guard canvasWidth.isFinite, canvasWidth > 0 else { return configuredMaxWidth }

        let availableWidth = max(0, canvasWidth - padding * 2)
        guard availableWidth > 0 else { return configuredMaxWidth }

        if let configuredMaxWidth {
            return min(configuredMaxWidth, availableWidth)
        }
        return availableWidth
    }

    static func resolve(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat,
        overflowAllowance: CGSize = .zero
    ) -> ChartTooltipLayoutResult {
        resolve(
            anchor: anchor,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding,
            directionalOverflowAllowance: ChartTooltipOverflowAllowance(symmetric: overflowAllowance)
        )
    }

    static func resolve(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat,
        directionalOverflowAllowance overflowAllowance: ChartTooltipOverflowAllowance
    ) -> ChartTooltipLayoutResult {
        let preferred = preferredLayout(
            anchor: anchor,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding,
            overflowAllowance: overflowAllowance
        )
        let clamped = clamp(
            preferred.position,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            padding: padding,
            overflowAllowance: overflowAllowance
        )

        return ChartTooltipLayoutResult(
            position: clamped,
            attachment: preferred.attachment,
            anchor: anchor,
            wasClamped: preferred.wasClamped || clamped != preferred.position
        )
    }

    private static func preferredLayout(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat,
        overflowAllowance: ChartTooltipOverflowAllowance = .zero
    ) -> (position: CGPoint, attachment: ChartTooltipAttachment, wasClamped: Bool) {
        switch placement {
        case .automatic:
            let placements = automaticPlacementPriority(anchor: anchor, canvasSize: canvasSize)
            let candidates = placements.map {
                automaticPreferredLayout(
                    anchor: anchor,
                    tooltipSize: tooltipSize,
                    canvasSize: canvasSize,
                    placement: $0,
                    offset: offset,
                    padding: padding,
                    overflowAllowance: overflowAllowance
                )
            }
            if let fitting = candidates.first(where: {
                overflowAmount(
                    for: $0.position,
                    tooltipSize: tooltipSize,
                    canvasSize: canvasSize,
                    padding: padding,
                    overflowAllowance: overflowAllowance
                ) == 0
            }) {
                return fitting
            }
            return candidates.min {
                overflowAmount(
                    for: $0.position,
                    tooltipSize: tooltipSize,
                    canvasSize: canvasSize,
                    padding: padding,
                    overflowAllowance: overflowAllowance
                ) <
                overflowAmount(
                    for: $1.position,
                    tooltipSize: tooltipSize,
                    canvasSize: canvasSize,
                    padding: padding,
                    overflowAllowance: overflowAllowance
                )
            } ?? (anchor, .center, false)

        case .top:
            return (
                CGPoint(x: anchor.x + offset.x, y: anchor.y - tooltipSize.height / 2 + offset.y),
                .top,
                false
            )

        case .bottom:
            return (
                CGPoint(x: anchor.x + offset.x, y: anchor.y + tooltipSize.height / 2 - offset.y),
                .bottom,
                false
            )

        case .leading:
            return (
                CGPoint(x: anchor.x - tooltipSize.width / 2 + offset.x, y: anchor.y + offset.y),
                .leading,
                false
            )

        case .trailing:
            return (
                CGPoint(x: anchor.x + tooltipSize.width / 2 + offset.x, y: anchor.y + offset.y),
                .trailing,
                false
            )

        case .center:
            return (CGPoint(x: anchor.x + offset.x, y: anchor.y + offset.y), .center, false)

        case .fixed(let point):
            return (CGPoint(x: point.x + offset.x, y: point.y + offset.y), .fixed, false)
        }
    }

    private static func automaticPreferredLayout(
        anchor: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        placement: ChartTooltipPlacement,
        offset: CGPoint,
        padding: CGFloat,
        overflowAllowance: ChartTooltipOverflowAllowance
    ) -> (position: CGPoint, attachment: ChartTooltipAttachment, wasClamped: Bool) {
        let layout = preferredLayout(
            anchor: anchor,
            tooltipSize: tooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding,
            overflowAllowance: overflowAllowance
        )

        switch layout.attachment {
        case .top, .bottom:
            let position = CGPoint(
                x: clampedCenterX(
                    preferredX: anchor.x + offset.x,
                    tooltipWidth: tooltipSize.width,
                    canvasWidth: canvasSize.width,
                    padding: padding,
                    leadingOverflowAllowance: overflowAllowance.leading,
                    trailingOverflowAllowance: overflowAllowance.trailing
                ),
                y: layout.position.y
            )
            return (
                position,
                layout.attachment,
                layout.wasClamped || position != layout.position
            )
        case .leading, .trailing:
            let position = CGPoint(
                x: layout.position.x,
                y: clampedCenterY(
                    preferredY: anchor.y + offset.y,
                    tooltipHeight: tooltipSize.height,
                    canvasHeight: canvasSize.height,
                    padding: padding,
                    topOverflowAllowance: overflowAllowance.top,
                    bottomOverflowAllowance: overflowAllowance.bottom
                )
            )
            return (
                position,
                layout.attachment,
                layout.wasClamped || position != layout.position
            )
        case .center, .fixed:
            return layout
        }
    }

    private static func automaticPlacementPriority(
        anchor: CGPoint,
        canvasSize: CGSize
    ) -> [ChartTooltipPlacement] {
        let verticalPrimary: ChartTooltipPlacement = anchor.y < canvasSize.height / 2 ? .bottom : .top
        let verticalFallback: ChartTooltipPlacement = verticalPrimary == .bottom ? .top : .bottom
        let horizontalPrimary: ChartTooltipPlacement = anchor.x < canvasSize.width / 2 ? .trailing : .leading
        let horizontalFallback: ChartTooltipPlacement = horizontalPrimary == .trailing ? .leading : .trailing

        return [
            verticalPrimary,
            verticalFallback,
            horizontalPrimary,
            horizontalFallback,
            .center
        ]
    }

    private static func clampedCenterX(
        preferredX: CGFloat,
        tooltipWidth: CGFloat,
        canvasWidth: CGFloat,
        padding: CGFloat,
        leadingOverflowAllowance: CGFloat,
        trailingOverflowAllowance: CGFloat
    ) -> CGFloat {
        guard tooltipWidth > 0, canvasWidth > 0 else { return preferredX }

        let halfWidth = tooltipWidth / 2
        let minX = padding + halfWidth - leadingOverflowAllowance
        let maxX = max(minX, canvasWidth - padding - halfWidth + trailingOverflowAllowance)
        return clamp(preferredX, lower: minX, upper: maxX)
    }

    private static func clampedCenterY(
        preferredY: CGFloat,
        tooltipHeight: CGFloat,
        canvasHeight: CGFloat,
        padding: CGFloat,
        topOverflowAllowance: CGFloat,
        bottomOverflowAllowance: CGFloat
    ) -> CGFloat {
        guard tooltipHeight > 0, canvasHeight > 0 else { return preferredY }

        let halfHeight = tooltipHeight / 2
        let minY = padding + halfHeight - topOverflowAllowance
        let maxY = max(minY, canvasHeight - padding - halfHeight + bottomOverflowAllowance)
        return clamp(preferredY, lower: minY, upper: maxY)
    }

    private static func overflowAmount(
        for point: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        padding: CGFloat,
        overflowAllowance: ChartTooltipOverflowAllowance = .zero
    ) -> CGFloat {
        let halfWidth = tooltipSize.width / 2
        let halfHeight = tooltipSize.height / 2
        let minX = padding + halfWidth - overflowAllowance.leading
        let maxX = max(minX, canvasSize.width - padding - halfWidth + overflowAllowance.trailing)
        let minY = padding + halfHeight - overflowAllowance.top
        let maxY = max(minY, canvasSize.height - padding - halfHeight + overflowAllowance.bottom)

        let xOverflow = max(0, minX - point.x) + max(0, point.x - maxX)
        let yOverflow = max(0, minY - point.y) + max(0, point.y - maxY)
        return xOverflow + yOverflow
    }

    private static func clamp(
        _ point: CGPoint,
        tooltipSize: CGSize,
        canvasSize: CGSize,
        padding: CGFloat,
        overflowAllowance: ChartTooltipOverflowAllowance = .zero
    ) -> CGPoint {
        let halfWidth = tooltipSize.width / 2
        let halfHeight = tooltipSize.height / 2
        let minX = padding + halfWidth - overflowAllowance.leading
        let maxX = max(minX, canvasSize.width - padding - halfWidth + overflowAllowance.trailing)
        let minY = padding + halfHeight - overflowAllowance.top
        let maxY = max(minY, canvasSize.height - padding - halfHeight + overflowAllowance.bottom)

        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }

    private static func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }

}
