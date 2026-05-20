//
//  StackedBarSeries+Layout.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

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

extension StackedBarSeries {
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
                guard let firstSegment = ordered.first else { return nil }
                let rowValue = ordered.map(\.value).reduce(0, +)
                let rowEndX = contexts.first?.scaleX(rowValue) ?? baselineX
                let targetValue = remainderStyle?.targetValue(rowYValue, rowValue)
                let targetEndX = targetValue.map { contexts.first?.scaleX($0) ?? rowEndX }

                return StackedBarRowMetrics(
                    rowIndex: rowIndex,
                    rowYValue: rowYValue,
                    screenY: firstSegment.screenY,
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
}
