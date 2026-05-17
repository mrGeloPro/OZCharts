//
//  StackedBarOptions.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct StackedBarLayoutOptions {
    public var leftAxisWidth: CGFloat
    public var rightAxisWidth: CGFloat
    public var axisLabelSpacing: CGFloat
    public var rowLabelLineLimit: Int?
    public var barHeight: CGFloat
    public var cornerRadius: CGFloat
    public var segmentGap: CGFloat
    public var rowHitboxHeight: CGFloat?

    public init(
        leftAxisWidth: CGFloat = 88,
        rightAxisWidth: CGFloat = 56,
        axisLabelSpacing: CGFloat = 6,
        rowLabelLineLimit: Int? = nil,
        barHeight: CGFloat = 28,
        cornerRadius: CGFloat = 4,
        segmentGap: CGFloat = 2,
        rowHitboxHeight: CGFloat? = nil
    ) {
        self.leftAxisWidth = leftAxisWidth
        self.rightAxisWidth = rightAxisWidth
        self.axisLabelSpacing = axisLabelSpacing
        self.rowLabelLineLimit = rowLabelLineLimit
        self.barHeight = barHeight
        self.cornerRadius = cornerRadius
        self.segmentGap = segmentGap
        self.rowHitboxHeight = rowHitboxHeight
    }

    public static let automatic = StackedBarLayoutOptions()

    public static func achievement(
        leftAxisWidth: CGFloat = 92,
        rightAxisWidth: CGFloat = 58,
        axisLabelSpacing: CGFloat = 8,
        rowLabelLineLimit: Int? = nil,
        barHeight: CGFloat = 20,
        segmentGap: CGFloat = 2,
        rowHitboxHeight: CGFloat? = 44
    ) -> StackedBarLayoutOptions {
        StackedBarLayoutOptions(
            leftAxisWidth: leftAxisWidth,
            rightAxisWidth: rightAxisWidth,
            axisLabelSpacing: axisLabelSpacing,
            rowLabelLineLimit: rowLabelLineLimit,
            barHeight: barHeight,
            cornerRadius: 0,
            segmentGap: segmentGap,
            rowHitboxHeight: rowHitboxHeight
        )
    }
}

public struct StackedBarSeparatorStyle {
    public var color: Color
    public var width: CGFloat
    public var signature: String?

    public init(color: Color, width: CGFloat = 1, signature: String? = nil) {
        self.color = color
        self.width = width
        self.signature = signature
    }
}

public struct StackedBarInteractionOptions {
    public var selectsSegments: Bool
    public var selectsRows: Bool
    public var selectsRemainder: Bool

    public init(
        selectsSegments: Bool = true,
        selectsRows: Bool = false,
        selectsRemainder: Bool = false
    ) {
        self.selectsSegments = selectsSegments
        self.selectsRows = selectsRows
        self.selectsRemainder = selectsRemainder
    }

    public static let segments = StackedBarInteractionOptions()
    public static let rows = StackedBarInteractionOptions(selectsSegments: false, selectsRows: true)
    public static let rowsAndSegments = StackedBarInteractionOptions(selectsSegments: true, selectsRows: true)
}

public struct StackedBarRemainderStyle {
    public var targetValue: (_ rowValue: Double, _ stackedTotal: Double) -> Double?
    public var fillStyle: ChartFillStyle
    public var legendLabel: String?
    public var legendColor: Color
    public var isSelectable: Bool
    public var accessibilityLabel: String?
    public var signature: String?

    public init(
        targetValue: @escaping (_ rowValue: Double, _ stackedTotal: Double) -> Double?,
        fillStyle: ChartFillStyle,
        legendLabel: String? = nil,
        legendColor: Color = .gray,
        isSelectable: Bool = false,
        accessibilityLabel: String? = nil,
        signature: String? = nil
    ) {
        self.targetValue = targetValue
        self.fillStyle = fillStyle
        self.legendLabel = legendLabel
        self.legendColor = legendColor
        self.isSelectable = isSelectable
        self.accessibilityLabel = accessibilityLabel
        self.signature = signature
    }

    public static func target(
        _ target: Double,
        fillStyle: ChartFillStyle,
        legendLabel: String? = nil,
        legendColor: Color = .gray,
        isSelectable: Bool = false,
        accessibilityLabel: String? = nil
    ) -> StackedBarRemainderStyle {
        StackedBarRemainderStyle(
            targetValue: { _, _ in target },
            fillStyle: fillStyle,
            legendLabel: legendLabel,
            legendColor: legendColor,
            isSelectable: isSelectable,
            accessibilityLabel: accessibilityLabel,
            signature: "target:\(target)"
        )
    }

    public static func target(
        _ targetValue: @escaping (_ rowValue: Double) -> Double?,
        signature: String,
        fillStyle: ChartFillStyle,
        legendLabel: String? = nil,
        legendColor: Color = .gray,
        isSelectable: Bool = false,
        accessibilityLabel: String? = nil
    ) -> StackedBarRemainderStyle {
        StackedBarRemainderStyle(
            targetValue: { rowValue, _ in targetValue(rowValue) },
            fillStyle: fillStyle,
            legendLabel: legendLabel,
            legendColor: legendColor,
            isSelectable: isSelectable,
            accessibilityLabel: accessibilityLabel,
            signature: signature
        )
    }
}

public struct StackedBarSelection: Identifiable, Equatable {
    public var id: UUID
    public var element: ChartSelectedElement
    public var rowIndex: Int?
    public var rowValue: Double?
    public var rowLabel: String?
    public var segmentIndex: Int?
    public var segmentLabel: String?
    public var value: Double?
    public var totalValue: Double?
    public var position: CGPoint
    public var interactionPosition: CGPoint?
    public var bounds: CGRect
    public var kind: ChartSelectedElementKind
    public var isSupplementary: Bool

    public init?(element: ChartSelectedElement) {
        guard element.kind == .stackedBarSegment ||
            element.kind == .stackedBarRemainder ||
            element.kind == .stackedBarRow else { return nil }

        self.id = element.id
        self.element = element
        self.rowIndex = element.rowIndex
        self.rowValue = element.y
        self.rowLabel = element.rowLabel
        self.segmentIndex = element.segmentIndex
        self.segmentLabel = element.groupLabel ?? element.label
        self.value = element.value
        self.totalValue = element.totalValue
        self.position = element.position
        self.interactionPosition = element.interactionPosition
        self.bounds = element.bounds
        self.kind = element.kind
        self.isSupplementary = element.isSupplementary
    }
}

public extension ChartSelection {
    var stackedBarSelections: [StackedBarSelection] {
        elements.compactMap(StackedBarSelection.init(element:))
    }

    var primaryStackedBarSelection: StackedBarSelection? {
        stackedBarSelections.first
    }
}
