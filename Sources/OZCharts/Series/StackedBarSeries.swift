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
}

public struct StackedBarSeries<P: GroupedChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id = UUID()
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle

    public var barHeight: CGFloat
    public var cornerRadius: CGFloat
    public var segmentGap: CGFloat
    public var stackOrder: [P.GroupID]
    public var colorMapper: (P.GroupID) -> Color
    public var groupLabel: ((P.GroupID) -> String?)?

    public init(
        data: [P],
        stackOrder: [P.GroupID],
        colorMapper: @escaping (P.GroupID) -> Color,
        groupLabel: ((P.GroupID) -> String?)? = nil,
        barHeight: CGFloat             = 28,
        cornerRadius: CGFloat          = 4,
        segmentGap: CGFloat            = 2,
        animation: ChartAnimationStyle = .none,
        zIndex: Int                    = 0
    ) {
        self.data         = data
        self.stackOrder   = stackOrder
        self.colorMapper  = colorMapper
        self.groupLabel   = groupLabel
        self.barHeight    = barHeight
        self.cornerRadius = cornerRadius
        self.segmentGap   = segmentGap
        self.animation    = animation
        self.zIndex       = zIndex
    }

    public var legendItems: [ChartLegendItem] {
        guard let groupLabel else { return [] }
        return stackOrder.compactMap { group in
            guard let title = groupLabel(group) else { return nil }
            return ChartLegendItem(title: title, color: colorMapper(group), symbol: .square)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        guard !contexts.isEmpty else { return }
        for segment in segmentLayouts(contexts: contexts) {
            let path = Path(roundedRect: segment.rect, cornerRadius: cornerRadius)
            context.fill(path, with: .color(colorMapper(segment.group)))
        }
    }

    func segmentLayouts(contexts: [ChartPointContext<P>]) -> [StackedBarSegmentLayout<P.GroupID>] {
        guard !contexts.isEmpty else { return [] }
        var rows: [Double: [(group: P.GroupID, value: Double, screenY: CGFloat)]] = [:]
        for ctx in contexts {
            let p = ctx.originalPoint
            rows[p.y, default: []].append((p.group, p.x, ctx.position.y))
        }
        let baselineX = contexts.first?.scaleX(0) ?? 0
        var layouts: [StackedBarSegmentLayout<P.GroupID>] = []

        for (_, segments) in rows {
            let ordered = stackOrder.compactMap { g in
                segments.first(where: { $0.group == g })
            }
            guard let firstSeg = ordered.first else { continue }
            let rowY = firstSeg.screenY
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
                layouts.append(StackedBarSegmentLayout(group: seg.group, rect: rect))

                cursorX += widthPx
            }
        }
        return layouts
    }
}
