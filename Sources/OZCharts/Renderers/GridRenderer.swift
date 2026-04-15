//
//  GridRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 16.04.2026.
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
            let ticks = axis.explicitValues?.map { activeXScale.scale($0) } ?? activeXScale.ticks(count: axis.tickCount, formatter: { _ in "" }).map { $0.position }
            for xPos in ticks {
                var path = Path()
                path.move(to: CGPoint(x: xPos, y: 0))
                path.addLine(to: CGPoint(x: xPos, y: size.height))
                context.stroke(path, with: .color(axis.gridColor), style: StrokeStyle(lineWidth: axis.gridLineWidth, dash: axis.gridLineDash))
            }
        }
        
        for axis in yAxes where axis.showGrid {
            let ticks = axis.explicitValues?.map { activeYScale.scale($0) } ?? activeYScale.ticks(count: axis.tickCount, formatter: { _ in "" }).map { $0.position }
            for yTick in ticks {
                let yPos = size.height - yTick
                var path = Path()
                path.move(to: CGPoint(x: 0, y: yPos))
                path.addLine(to: CGPoint(x: size.width, y: yPos))
                context.stroke(path, with: .color(axis.gridColor), style: StrokeStyle(lineWidth: axis.gridLineWidth, dash: axis.gridLineDash))
            }
        }
    }
}
