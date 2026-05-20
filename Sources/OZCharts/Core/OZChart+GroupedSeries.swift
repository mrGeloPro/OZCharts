//
//  OZChart+GroupedSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension OZChart where Point: GroupedChartDataPoint {
    func stackedArea(
        id: UUID? = nil,
        stackOrder: [Point.GroupID],
        colorMapper: @escaping (Point.GroupID) -> Color,
        fillStyleMapper: ((Point.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((Point.GroupID) -> String?)? = nil,
        interpolation: LineInterpolation = .step,
        lineWidth: CGFloat = 3,
        fillOpacity: Double = 0.32,
        shadow: ChartShadowStyle? = nil,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            StackedAreaSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .stackedArea),
                stackOrder: stackOrder,
                colorMapper: colorMapper,
                fillStyleMapper: fillStyleMapper,
                groupLabel: groupLabel,
                interpolation: interpolation,
                lineWidth: lineWidth,
                fillOpacity: fillOpacity,
                shadow: shadow,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    func stackedBar(
        id: UUID? = nil,
        stackOrder: [Point.GroupID],
        colorMapper: @escaping (Point.GroupID) -> Color,
        fillStyleMapper: ((Point.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((Point.GroupID) -> String?)? = nil,
        rowLabel: ((Double) -> String?)? = nil,
        rowEndLabel: ((_ rowValue: Double, _ stackedTotal: Double) -> String?)? = nil,
        layout: StackedBarLayoutOptions? = nil,
        remainder: StackedBarRemainderStyle? = nil,
        separatorStyle: StackedBarSeparatorStyle? = nil,
        interactionOptions: StackedBarInteractionOptions = .segments,
        valueLabelStyle: ChartValueLabelStyle? = nil,
        barHeight: CGFloat = 28,
        cornerRadius: CGFloat = 4,
        segmentGap: CGFloat = 2,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        let resolvedLayout = layout ?? StackedBarLayoutOptions(
            barHeight: barHeight,
            cornerRadius: cornerRadius,
            segmentGap: segmentGap
        )

        var copy = addingSeries(
            StackedBarSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .stackedBar),
                stackOrder: stackOrder,
                colorMapper: colorMapper,
                fillStyleMapper: fillStyleMapper,
                groupLabel: groupLabel,
                rowLabel: rowLabel,
                remainderStyle: remainder,
                separatorStyle: separatorStyle,
                interactionOptions: interactionOptions,
                rowHitboxHeight: resolvedLayout.rowHitboxHeight,
                valueLabelStyle: valueLabelStyle,
                barHeight: resolvedLayout.barHeight,
                cornerRadius: resolvedLayout.cornerRadius,
                segmentGap: resolvedLayout.segmentGap,
                animation: animation,
                zIndex: zIndex
            )
        )

        if rowLabel != nil || rowEndLabel != nil, copy.yAxes == nil {
            copy.yAxes = stackedBarRowAxes(
                stackOrder: stackOrder,
                rowLabel: rowLabel,
                rowEndLabel: rowEndLabel,
                layout: resolvedLayout
            )
        }
        return copy
    }

    func violin(
        id: UUID? = nil,
        centerX: Double,
        maxHalfWidth: CGFloat = 120,
        sideMapper: @escaping (Point.GroupID) -> ViolinSide,
        colorMapper: @escaping (Point.GroupID) -> Color,
        fillStyleMapper: ((Point.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((Point.GroupID) -> String?)? = nil,
        fillOpacity: Double = 0.35,
        strokeWidth: CGFloat = 1,
        showScatter: Bool = true,
        scatterSize: CGFloat = 5,
        scatterOpacity: Double = 0.9,
        shadow: ChartShadowStyle? = nil,
        bandwidth: Double? = nil,
        sampleCount: Int = 80,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            ViolinSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .violin),
                centerX: centerX,
                maxHalfWidth: maxHalfWidth,
                sideMapper: sideMapper,
                colorMapper: colorMapper,
                fillStyleMapper: fillStyleMapper,
                groupLabel: groupLabel,
                fillOpacity: fillOpacity,
                strokeWidth: strokeWidth,
                showScatter: showScatter,
                scatterSize: scatterSize,
                scatterOpacity: scatterOpacity,
                shadow: shadow,
                bandwidth: bandwidth,
                sampleCount: sampleCount,
                animation: animation,
                zIndex: zIndex
            )
        )
    }
}

private extension OZChart where Point: GroupedChartDataPoint {
    func stackedBarRowAxes(
        stackOrder: [Point.GroupID],
        rowLabel: ((Double) -> String?)?,
        rowEndLabel: ((_ rowValue: Double, _ stackedTotal: Double) -> String?)?,
        layout: StackedBarLayoutOptions
    ) -> [YAxisConfig] {
        let visibleGroups = Set(stackOrder)
        let visibleData = sourceData.filter { visibleGroups.contains($0.group) }
        let rowValues = Array(Set(visibleData.map(\.y))).sorted()
        let rowTotals = Dictionary(grouping: visibleData, by: \.y)
            .mapValues { points in points.map(\.x).reduce(0, +) }

        var axes: [YAxisConfig] = []
        if let rowLabel {
            axes.append(
                .stackedBarRows(
                    values: rowValues,
                    position: .leading,
                    width: layout.leftAxisWidth,
                    labelSpacing: layout.axisLabelSpacing,
                    labelLineLimit: layout.rowLabelLineLimit,
                    rowLabel: rowLabel
                )
            )
        }
        if let rowEndLabel {
            axes.append(
                .stackedBarRows(
                    values: rowValues,
                    position: .trailing,
                    width: layout.rightAxisWidth,
                    labelSpacing: layout.axisLabelSpacing,
                    labelLineLimit: 1,
                    rowLabel: { row in rowEndLabel(row, rowTotals[row] ?? 0) }
                )
            )
        }
        return axes
    }
}
