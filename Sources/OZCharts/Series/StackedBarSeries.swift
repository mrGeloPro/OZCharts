//
//  StackedBarSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct StackedBarSegmentLayout<GroupID: Hashable> {
    let group: GroupID
    let rect: CGRect
    let rowValue: Double
    let rowEndX: CGFloat
    let segmentValue: Double
    let pointID: UUID?
    let rowYValue: Double
}

private struct PendingStackedBarLabel {
    let id: UUID
    let label: String
    let anchor: CGPoint
}

public struct StackedBarSeries<P: GroupedChartDataPoint>: ChartSeriesProtocol
    where P.XValue == Double, P.YValue == Double {
    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle

    public var barHeight: CGFloat
    public var cornerRadius: CGFloat
    public var segmentGap: CGFloat
    public var stackOrder: [P.GroupID]
    public var colorMapper: (P.GroupID) -> Color
    public var fillStyleMapper: ((P.GroupID) -> ChartFillStyle)?
    public var groupLabel: ((P.GroupID) -> String?)?
    public var valueLabelStyle: ChartValueLabelStyle?

    public init(
        data: [P],
        id: UUID = UUID(),
        stackOrder: [P.GroupID],
        colorMapper: @escaping (P.GroupID) -> Color,
        fillStyleMapper: ((P.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((P.GroupID) -> String?)? = nil,
        valueLabelStyle: ChartValueLabelStyle? = nil,
        barHeight: CGFloat = 28,
        cornerRadius: CGFloat = 4,
        segmentGap: CGFloat = 2,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.id = id
        self.data = data
        self.stackOrder = stackOrder
        self.colorMapper = colorMapper
        self.fillStyleMapper = fillStyleMapper
        self.groupLabel = groupLabel
        self.valueLabelStyle = valueLabelStyle
        self.barHeight = barHeight
        self.cornerRadius = cornerRadius
        self.segmentGap = segmentGap
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItems: [ChartLegendItem] {
        guard let groupLabel else { return [] }
        return stackOrder.compactMap { group in
            guard let title = groupLabel(group) else { return nil }
            return ChartLegendItem(title: title, color: colorMapper(group), symbol: .square)
        }
    }

    public var layoutSignature: ChartSeriesSignature {
        ChartSeriesSignature(
            kind: String(reflecting: Self.self),
            values: [
                Double(barHeight),
                Double(cornerRadius),
                Double(segmentGap)
            ],
            tokens: [
                "stackOrder:\(stackOrder.map { String(describing: $0) }.joined(separator: "|"))",
                "hasFillStyleMapper:\(fillStyleMapper != nil)",
                "hasGroupLabel:\(groupLabel != nil)",
                "valueLabelPosition:\(String(describing: valueLabelStyle?.position))",
                "animation:\(animation.kind)"
            ]
        )
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        guard !contexts.isEmpty else { return }
        let layouts = segmentLayouts(contexts: contexts)
        for segment in layouts {
            let path = Path(roundedRect: segment.rect, cornerRadius: cornerRadius)
            let style = fillStyleMapper?(segment.group) ?? .color(colorMapper(segment.group))
            context.fill(path, with: style, in: segment.rect)
        }

        guard let valueLabelStyle, valueLabelStyle.position != .hidden else { return }
        let rowLabels = Dictionary(grouping: layouts, by: { $0.rect.midY }).compactMap { _, row -> StackedBarSegmentLayout<P.GroupID>? in
            row.max { $0.rowEndX < $1.rowEndX }
        }

        let pendingLabels = rowLabels.map { row -> PendingStackedBarLabel in
            let label = valueLabelStyle.formatter(row.rowValue)
            let x: CGFloat = switch valueLabelStyle.position {
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

        let placements: [ChartLabelPlacement] = valueLabelStyle.position == .outside
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
        let resolvedByID: [UUID: ChartResolvedLabel] = Dictionary(
            uniqueKeysWithValues: resolvedLabels.map { ($0.id, $0) }
        )

        for pending in pendingLabels {
            guard let resolved = resolvedByID[pending.id], resolved.isVisible else { continue }
            let text = Text(pending.label)
                .font(valueLabelStyle.font)
                .foregroundColor(valueLabelStyle.color)
            context.draw(text, at: resolved.position, anchor: .center)
        }
    }

    func segmentLayouts(contexts: [ChartPointContext<P>]) -> [StackedBarSegmentLayout<P.GroupID>] {
        guard !contexts.isEmpty else { return [] }
        var rows: [Double: [P.GroupID: (value: Double, screenY: CGFloat, pointID: UUID?)]] = [:]
        for ctx in contexts {
            let p = ctx.originalPoint
            let existing = rows[p.y, default: [:]][p.group]
            rows[p.y, default: [:]][p.group] = (
                value: (existing?.value ?? 0) + p.x,
                screenY: existing?.screenY ?? ctx.position.y,
                pointID: existing?.pointID ?? p.id
            )
        }
        let baselineX = contexts.first?.scaleX(0) ?? 0
        var layouts: [StackedBarSegmentLayout<P.GroupID>] = []

        for (rowYValue, segmentsByGroup) in rows {
            let ordered = stackOrder.compactMap { group in
                segmentsByGroup[group].map { (group: group, value: $0.value, screenY: $0.screenY, pointID: $0.pointID) }
            }
            guard let firstSeg = ordered.first else { continue }
            let rowY = firstSeg.screenY
            let rowValue = ordered.map(\.value).reduce(0, +)
            var cursorX: CGFloat = baselineX

            for seg in ordered {
                let scaledX = contexts.first?.scaleX(seg.value) ?? baselineX
                let widthPx = scaledX.isNaN
                    ? 0
                    : max(0, scaledX - baselineX)

                guard widthPx > 0 else { continue }

                let drawWidth = max(0, widthPx - segmentGap)
                let rect = CGRect(
                    x: cursorX,
                    y: rowY - barHeight / 2,
                    width: drawWidth,
                    height: barHeight
                )
                let rowEndX = contexts.first?.scaleX(rowValue) ?? cursorX + drawWidth
                layouts.append(
                    StackedBarSegmentLayout(
                        group: seg.group,
                        rect: rect,
                        rowValue: rowValue,
                        rowEndX: rowEndX,
                        segmentValue: seg.value,
                        pointID: seg.pointID,
                        rowYValue: rowYValue
                    )
                )

                cursorX += widthPx
            }
        }
        return layouts
    }

    public func selectionElements(
        contexts: [ChartPointContext<P>],
        size _: CGSize
    ) -> [ChartElementContext] {
        segmentLayouts(contexts: contexts).enumerated().map { index, segment in
            let label = groupLabel?(segment.group)
            let elementID = segment.pointID ?? UUID()
            let payload = ChartSelectedElement(
                elementID: elementID,
                kind: .stackedBarSegment,
                seriesID: id,
                pointID: segment.pointID,
                segmentIndex: index,
                groupLabel: label ?? String(describing: segment.group),
                label: label,
                x: segment.segmentValue,
                y: segment.rowYValue,
                value: segment.segmentValue,
                position: CGPoint(x: segment.rect.midX, y: segment.rect.midY),
                bounds: segment.rect
            )

            return ChartElementContext(
                payload: payload,
                hitShape: .rect(segment.rect),
                zIndex: zIndex
            )
        }
    }
}
