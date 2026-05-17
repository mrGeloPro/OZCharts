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
    let rowIndex: Int
    let rowLabel: String?
    let rowEndX: CGFloat
    let segmentValue: Double
    let pointID: UUID?
    let rowYValue: Double
}

struct StackedBarRemainderLayout {
    let rect: CGRect
    let rowValue: Double
    let rowIndex: Int
    let rowLabel: String?
    let rowTotal: Double
    let targetValue: Double
    let rowYValue: Double
}

struct StackedBarRowLayout {
    let rect: CGRect
    let rowValue: Double
    let rowIndex: Int
    let rowLabel: String?
    let rowTotal: Double
    let rowYValue: Double
}

private struct PendingStackedBarLabel {
    let id: UUID
    let label: String
    let anchor: CGPoint
}

private struct StackedBarRowSegment<GroupID: Hashable> {
    let group: GroupID
    let value: Double
    let screenY: CGFloat
    let pointID: UUID?
}

private struct StackedBarRowMetrics<GroupID: Hashable> {
    let rowIndex: Int
    let rowYValue: Double
    let screenY: CGFloat
    let rowLabel: String?
    let rowTotal: Double
    let baselineX: CGFloat
    let rowEndX: CGFloat
    let targetValue: Double?
    let targetEndX: CGFloat?
    let segments: [StackedBarRowSegment<GroupID>]
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
    public var rowLabel: ((Double) -> String?)?
    public var remainderStyle: StackedBarRemainderStyle?
    public var separatorStyle: StackedBarSeparatorStyle?
    public var interactionOptions: StackedBarInteractionOptions
    public var rowHitboxHeight: CGFloat?
    public var valueLabelStyle: ChartValueLabelStyle?

    public init(
        data: [P],
        id: UUID = UUID(),
        stackOrder: [P.GroupID],
        colorMapper: @escaping (P.GroupID) -> Color,
        fillStyleMapper: ((P.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((P.GroupID) -> String?)? = nil,
        rowLabel: ((Double) -> String?)? = nil,
        remainderStyle: StackedBarRemainderStyle? = nil,
        separatorStyle: StackedBarSeparatorStyle? = nil,
        interactionOptions: StackedBarInteractionOptions = .segments,
        rowHitboxHeight: CGFloat? = nil,
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
        self.rowLabel = rowLabel
        self.remainderStyle = remainderStyle
        self.separatorStyle = separatorStyle
        self.interactionOptions = interactionOptions
        self.rowHitboxHeight = rowHitboxHeight
        self.valueLabelStyle = valueLabelStyle
        self.barHeight = barHeight
        self.cornerRadius = cornerRadius
        self.segmentGap = segmentGap
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItems: [ChartLegendItem] {
        guard let groupLabel else { return remainderLegendItems }
        let stackItems: [ChartLegendItem] = stackOrder.compactMap { group in
            guard let title = groupLabel(group) else { return nil }
            return ChartLegendItem(title: title, color: colorMapper(group), symbol: .square)
        }
        return stackItems + remainderLegendItems
    }

    private var remainderLegendItems: [ChartLegendItem] {
        guard let remainderStyle, let label = remainderStyle.legendLabel else { return [] }
        return [ChartLegendItem(title: label, color: remainderStyle.legendColor, symbol: .square)]
    }

    private var interactionSignature: String {
        [
            interactionOptions.selectsSegments ? "segments" : nil,
            interactionOptions.selectsRows ? "rows" : nil,
            interactionOptions.selectsRemainder ? "remainder" : nil
        ]
        .compactMap { $0 }
        .joined(separator: "|")
    }

    private var rowHitboxSignature: Double {
        Double(rowHitboxHeight ?? -1)
    }

    private var remainderSignature: String {
        guard let remainderStyle else { return "none" }
        return [
            "selectable:\(remainderStyle.isSelectable)",
            "legend:\(remainderStyle.legendLabel != nil)",
            "accessibility:\(remainderStyle.accessibilityLabel ?? "")",
            "signature:\(remainderStyle.signature ?? "dynamic")"
        ].joined(separator: "|")
    }

    private var separatorSignature: String {
        guard let separatorStyle else { return "none" }
        return [
            "width:\(Double(separatorStyle.width))",
            "signature:\(separatorStyle.signature ?? "default")"
        ].joined(separator: "|")
    }

    public var layoutSignature: ChartSeriesSignature {
        ChartSeriesSignature(
            kind: String(reflecting: Self.self),
            values: [
                Double(barHeight),
                Double(cornerRadius),
                Double(segmentGap),
                rowHitboxSignature,
                Double(separatorStyle?.width ?? -1)
            ],
            tokens: [
                "stackOrder:\(stackOrder.map { String(describing: $0) }.joined(separator: "|"))",
                "hasFillStyleMapper:\(fillStyleMapper != nil)",
                "hasGroupLabel:\(groupLabel != nil)",
                "hasRowLabel:\(rowLabel != nil)",
                "remainder:\(remainderSignature)",
                "separator:\(separatorSignature)",
                "interaction:\(interactionSignature)",
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
        let remainders = remainderLayouts(contexts: contexts)

        for segment in layouts {
            let path = Path(roundedRect: segment.rect, cornerRadius: cornerRadius)
            let style = fillStyleMapper?(segment.group) ?? .color(colorMapper(segment.group))
            context.fill(path, with: style, in: segment.rect)
        }

        for remainder in remainders {
            let path = Path(roundedRect: remainder.rect, cornerRadius: cornerRadius)
            context.fill(path, with: remainderStyle?.fillStyle ?? .color(.clear), in: remainder.rect)
        }

        if let separatorStyle {
            drawSeparators(for: layouts, into: &context, style: separatorStyle)
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
        rowMetrics(contexts: contexts).flatMap { row -> [StackedBarSegmentLayout<P.GroupID>] in
            var cursorX: CGFloat = row.baselineX

            return row.segments.compactMap { segment in
                let scaledX = contexts.first?.scaleX(segment.value) ?? row.baselineX
                let widthPx = scaledX.isNaN
                    ? 0
                    : max(0, scaledX - row.baselineX)

                guard widthPx > 0 else { return nil }

                let drawWidth = max(0, widthPx - segmentGap)
                let rect = CGRect(
                    x: cursorX,
                    y: row.screenY - barHeight / 2,
                    width: drawWidth,
                    height: barHeight
                )
                cursorX += widthPx

                return StackedBarSegmentLayout(
                    group: segment.group,
                    rect: rect,
                    rowValue: row.rowTotal,
                    rowIndex: row.rowIndex,
                    rowLabel: row.rowLabel,
                    rowEndX: row.rowEndX,
                    segmentValue: segment.value,
                    pointID: segment.pointID,
                    rowYValue: row.rowYValue
                )
            }
        }
    }

    func remainderLayouts(contexts: [ChartPointContext<P>]) -> [StackedBarRemainderLayout] {
        guard remainderStyle != nil else { return [] }
        return rowMetrics(contexts: contexts).compactMap { row in
            guard let targetValue = row.targetValue,
                  let targetEndX = row.targetEndX,
                  targetValue > row.rowTotal else { return nil }

            let leadingGap = min(segmentGap, max(0, targetEndX - row.rowEndX))
            let rect = CGRect(
                x: row.rowEndX + leadingGap,
                y: row.screenY - barHeight / 2,
                width: max(0, targetEndX - row.rowEndX - leadingGap),
                height: barHeight
            )
            guard rect.width > 0 else { return nil }

            return StackedBarRemainderLayout(
                rect: rect,
                rowValue: row.rowYValue,
                rowIndex: row.rowIndex,
                rowLabel: row.rowLabel,
                rowTotal: row.rowTotal,
                targetValue: targetValue,
                rowYValue: row.rowYValue
            )
        }
    }

    func rowLayouts(contexts: [ChartPointContext<P>]) -> [StackedBarRowLayout] {
        rowMetrics(contexts: contexts).compactMap { row in
            let rowEndX = row.targetEndX ?? row.rowEndX
            let height = rowHitboxHeight ?? max(barHeight, 36)
            let rect = CGRect(
                x: row.baselineX,
                y: row.screenY - height / 2,
                width: max(0, rowEndX - row.baselineX),
                height: height
            )
            guard rect.width > 0 else { return nil }

            return StackedBarRowLayout(
                rect: rect,
                rowValue: row.rowYValue,
                rowIndex: row.rowIndex,
                rowLabel: row.rowLabel,
                rowTotal: row.rowTotal,
                rowYValue: row.rowYValue
            )
        }
    }

    private func rowMetrics(contexts: [ChartPointContext<P>]) -> [StackedBarRowMetrics<P.GroupID>] {
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

        return rows
            .sorted { $0.key < $1.key }
            .enumerated()
            .compactMap { rowIndex, rowData in
                let (rowYValue, segmentsByGroup) = rowData
                let ordered = stackOrder.compactMap { group in
                    segmentsByGroup[group].map {
                        StackedBarRowSegment(
                            group: group,
                            value: $0.value,
                            screenY: $0.screenY,
                            pointID: $0.pointID
                        )
                    }
                }
                guard let firstSeg = ordered.first else { return nil }
                let rowY = firstSeg.screenY
                let rowValue = ordered.map(\.value).reduce(0, +)
                let rowEndX = contexts.first?.scaleX(rowValue) ?? baselineX
                let targetValue = remainderStyle?.targetValue(rowYValue, rowValue)
                let targetEndX = targetValue.map { contexts.first?.scaleX($0) ?? rowEndX }

                return StackedBarRowMetrics(
                    rowIndex: rowIndex,
                    rowYValue: rowYValue,
                    screenY: rowY,
                    rowLabel: rowLabel?(rowYValue),
                    rowTotal: rowValue,
                    baselineX: baselineX,
                    rowEndX: rowEndX,
                    targetValue: targetValue,
                    targetEndX: targetEndX,
                    segments: ordered
                )
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

    public func selectionElements(
        contexts: [ChartPointContext<P>],
        size _: CGSize
    ) -> [ChartElementContext] {
        var elements: [ChartElementContext] = []

        if interactionOptions.selectsRows {
            elements += rowLayouts(contexts: contexts).map { row in
                let payload = ChartSelectedElement(
                    elementID: stableElementID(kindToken: "a1", rowValue: row.rowYValue),
                    kind: .stackedBarRow,
                    seriesID: id,
                    segmentIndex: nil,
                    groupLabel: row.rowLabel,
                    label: row.rowLabel,
                    x: row.rowTotal,
                    y: row.rowYValue,
                    value: row.rowTotal,
                    totalValue: row.rowTotal,
                    rowIndex: row.rowIndex,
                    rowLabel: row.rowLabel,
                    position: CGPoint(x: row.rect.midX, y: row.rect.midY),
                    bounds: row.rect
                )

                return ChartElementContext(
                    payload: payload,
                    hitShape: .rect(row.rect),
                    zIndex: zIndex - 1
                )
            }
        }

        if interactionOptions.selectsSegments {
            elements += segmentLayouts(contexts: contexts).enumerated().map { index, segment in
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
                    totalValue: segment.rowValue,
                    rowIndex: segment.rowIndex,
                    rowLabel: segment.rowLabel,
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

        if interactionOptions.selectsRemainder || remainderStyle?.isSelectable == true {
            elements += remainderLayouts(contexts: contexts).map { remainder in
                let payload = ChartSelectedElement(
                    elementID: stableElementID(kindToken: "a2", rowValue: remainder.rowYValue),
                    kind: .stackedBarRemainder,
                    seriesID: id,
                    pointID: nil,
                    segmentIndex: nil,
                    groupLabel: remainderStyle?.accessibilityLabel,
                    label: remainderStyle?.accessibilityLabel,
                    x: remainder.targetValue - remainder.rowTotal,
                    y: remainder.rowYValue,
                    value: remainder.targetValue - remainder.rowTotal,
                    totalValue: remainder.rowTotal,
                    rowIndex: remainder.rowIndex,
                    rowLabel: remainder.rowLabel,
                    isSupplementary: true,
                    position: CGPoint(x: remainder.rect.midX, y: remainder.rect.midY),
                    bounds: remainder.rect
                )

                return ChartElementContext(
                    payload: payload,
                    hitShape: .rect(remainder.rect),
                    zIndex: zIndex
                )
            }
        }

        return elements
    }

    private func stableElementID(kindToken: String, rowValue: Double) -> UUID {
        let seriesHex = id.uuidString
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
        let rowHex = String(format: "%016llx", rowValue.bitPattern)
        let raw = String(seriesHex.prefix(14)) + kindToken + rowHex
        let part1 = String(raw.prefix(8))
        let part2 = String(raw.dropFirst(8).prefix(4))
        let part3 = String(raw.dropFirst(12).prefix(4))
        let part4 = String(raw.dropFirst(16).prefix(4))
        let part5 = String(raw.dropFirst(20).prefix(12))
        let uuidString = "\(part1)-\(part2)-\(part3)-\(part4)-\(part5)"
        return UUID(uuidString: uuidString) ?? UUID()
    }
}
