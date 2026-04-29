//
//  GridRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct GridRenderer {
    public static func draw<XScale: Scale, YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        xAxes: [XAxisConfig],
        yAxes: [YAxisConfig],
        activeXScale: XScale,
        activeYScale: YScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat,
            YScale.InputType == Double, YScale.OutputType == CGFloat {

        for axis in xAxes where axis.showGrid {
            let positions = ChartTickBuilder.ticks(
                scale: activeXScale,
                explicitValues: axis.explicitValues,
                tickCount: axis.tickCount,
                strategy: axis.tickStrategy,
                formatter: { _ in "" }
            ).map(\.position)

            for xPos in positions {
                var path = Path()
                path.move(to: CGPoint(x: xPos, y: 0))
                path.addLine(to: CGPoint(x: xPos, y: size.height))
                context.stroke(
                    path,
                    with: .color(axis.gridColor),
                    style: StrokeStyle(lineWidth: axis.gridLineWidth, dash: axis.gridLineDash)
                )
            }
        }

        for axis in yAxes where axis.showGrid {
            let positions = ChartTickBuilder.ticks(
                scale: activeYScale,
                explicitValues: axis.explicitValues,
                tickCount: axis.tickCount,
                strategy: axis.tickStrategy,
                formatter: { _ in "" }
            ).map(\.position)

            for yTick in positions {
                let yPos = size.height - yTick
                var path = Path()
                path.move(to: CGPoint(x: 0, y: yPos))
                path.addLine(to: CGPoint(x: size.width, y: yPos))
                context.stroke(
                    path,
                    with: .color(axis.gridColor),
                    style: StrokeStyle(lineWidth: axis.gridLineWidth, dash: axis.gridLineDash)
                )
            }
        }
    }
}
