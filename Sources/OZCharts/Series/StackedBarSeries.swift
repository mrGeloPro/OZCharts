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

}
