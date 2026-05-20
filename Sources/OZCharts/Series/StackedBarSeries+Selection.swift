//
//  StackedBarSeries+Selection.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension StackedBarSeries {
    public func selectionElements(
        contexts: [ChartPointContext<P>],
        size _: CGSize
    ) -> [ChartElementContext] {
        var elements: [ChartElementContext] = []

        if interactionOptions.selectsRows {
            elements += rowSelectionElements(contexts: contexts)
        }
        if interactionOptions.selectsSegments {
            elements += segmentSelectionElements(contexts: contexts)
        }
        if interactionOptions.selectsRemainder || remainderStyle?.isSelectable == true {
            elements += remainderSelectionElements(contexts: contexts)
        }

        return elements
    }

    private func rowSelectionElements(contexts: [ChartPointContext<P>]) -> [ChartElementContext] {
        rowLayouts(contexts: contexts).map { row in
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

    private func segmentSelectionElements(contexts: [ChartPointContext<P>]) -> [ChartElementContext] {
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

    private func remainderSelectionElements(contexts: [ChartPointContext<P>]) -> [ChartElementContext] {
        remainderLayouts(contexts: contexts).map { remainder in
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
