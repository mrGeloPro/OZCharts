//
//  StackedBarSeries+Rendering.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

private struct PendingStackedBarLabel {
    let id: UUID
    let label: String
    let anchor: CGPoint
}

extension StackedBarSeries {
    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        guard !contexts.isEmpty else { return }
        let layouts = segmentLayouts(contexts: contexts)
        let remainders = remainderLayouts(contexts: contexts)

        drawSegments(layouts, into: &context)
        drawRemainders(remainders, into: &context)
        if let separatorStyle {
            drawSeparators(for: layouts, into: &context, style: separatorStyle)
        }
        drawValueLabels(for: layouts, into: &context, size: size)
    }

    private func drawSegments(
        _ layouts: [StackedBarSegmentLayout<P.GroupID>],
        into context: inout GraphicsContext
    ) {
        for segment in layouts {
            let path = Path(roundedRect: segment.rect, cornerRadius: cornerRadius)
            let style = fillStyleMapper?(segment.group) ?? .color(colorMapper(segment.group))
            context.fill(path, with: style, in: segment.rect)
        }
    }

    private func drawRemainders(
        _ remainders: [StackedBarRemainderLayout],
        into context: inout GraphicsContext
    ) {
        for remainder in remainders {
            let path = Path(roundedRect: remainder.rect, cornerRadius: cornerRadius)
            context.fill(path, with: remainderStyle?.fillStyle ?? .color(.clear), in: remainder.rect)
        }
    }

    private func drawSeparators(
        for layouts: [StackedBarSegmentLayout<P.GroupID>],
        into context: inout GraphicsContext,
        style: StackedBarSeparatorStyle
    ) {
        let grouped = Dictionary(grouping: layouts, by: { $0.rowYValue })
        for row in grouped.values {
            for segment in row where segment.rect.maxX < segment.rowEndX - 0.5 {
                var path = Path()
                let x = segment.rect.maxX + max(0, segmentGap - style.width) / 2
                path.move(to: CGPoint(x: x, y: segment.rect.minY))
                path.addLine(to: CGPoint(x: x, y: segment.rect.maxY))
                context.stroke(path, with: .color(style.color), lineWidth: style.width)
            }
        }
    }

    private func drawValueLabels(
        for layouts: [StackedBarSegmentLayout<P.GroupID>],
        into context: inout GraphicsContext,
        size: CGSize
    ) {
        guard let valueLabelStyle, valueLabelStyle.position != .hidden else { return }
        let pendingLabels = pendingValueLabels(for: layouts, style: valueLabelStyle)
        let resolvedByID = resolvedValueLabelPlacements(
            pendingLabels,
            style: valueLabelStyle,
            size: size
        )

        for pending in pendingLabels {
            guard let resolved = resolvedByID[pending.id], resolved.isVisible else { continue }
            let text = Text(pending.label)
                .font(valueLabelStyle.font)
                .foregroundColor(valueLabelStyle.color)
            context.draw(text, at: resolved.position, anchor: .center)
        }
    }

    private func pendingValueLabels(
        for layouts: [StackedBarSegmentLayout<P.GroupID>],
        style: ChartValueLabelStyle
    ) -> [PendingStackedBarLabel] {
        let rowLabels = Dictionary(grouping: layouts, by: { $0.rect.midY })
            .compactMap { _, row -> StackedBarSegmentLayout<P.GroupID>? in
                row.max { $0.rowEndX < $1.rowEndX }
            }

        return rowLabels.map { row in
            let label = style.formatter(row.rowValue)
            let x: CGFloat = switch style.position {
            case .hidden:
                row.rect.midX
            case .inside:
                max(row.rect.minX + 8, row.rowEndX - 22)
            case .outside:
                row.rowEndX + 24
            }
            return PendingStackedBarLabel(
                id: row.pointID ?? UUID(),
                label: label,
                anchor: CGPoint(x: x, y: row.rect.midY)
            )
        }
    }

    private func resolvedValueLabelPlacements(
        _ pendingLabels: [PendingStackedBarLabel],
        style: ChartValueLabelStyle,
        size: CGSize
    ) -> [UUID: ChartResolvedLabel] {
        let placements: [ChartLabelPlacement] = style.position == .outside
            ? [.trailing, .leading]
            : [.center]
        let candidates = pendingLabels.map { pending in
            ChartLabelCandidate(
                id: pending.id,
                anchor: pending.anchor,
                size: ChartTextMetrics.estimatedSize(for: pending.label),
                preferredPlacements: placements,
                padding: 2,
                spacing: 4,
                canHide: true
            )
        }
        let resolvedLabels = ChartLabelCollisionResolver.resolve(
            candidates: candidates,
            canvasSize: size
        )
        return Dictionary(uniqueKeysWithValues: resolvedLabels.map { ($0.id, $0) })
    }
}
