//
//  ChartPlotBorderRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

enum ChartPlotBorderRenderer {
    static func draw(
        into context: inout GraphicsContext,
        size: CGSize,
        style: ChartPlotBorderStyle
    ) {
        guard size.width > 0,
              size.height > 0,
              style.lineWidth > 0,
              !style.edges.isEmpty else { return }

        let inset = style.lineWidth / 2
        let minX = inset
        let maxX = max(inset, size.width - inset)
        let minY = inset
        let maxY = max(inset, size.height - inset)
        let stroke = StrokeStyle(lineWidth: style.lineWidth, dash: style.dash)

        if style.edges.contains(.top) {
            strokeLine(from: CGPoint(x: minX, y: minY), to: CGPoint(x: maxX, y: minY), into: &context, style: style, stroke: stroke)
        }
        if style.edges.contains(.bottom) {
            strokeLine(from: CGPoint(x: minX, y: maxY), to: CGPoint(x: maxX, y: maxY), into: &context, style: style, stroke: stroke)
        }
        if style.edges.contains(.leading) {
            strokeLine(from: CGPoint(x: minX, y: minY), to: CGPoint(x: minX, y: maxY), into: &context, style: style, stroke: stroke)
        }
        if style.edges.contains(.trailing) {
            strokeLine(from: CGPoint(x: maxX, y: minY), to: CGPoint(x: maxX, y: maxY), into: &context, style: style, stroke: stroke)
        }
    }

    private static func strokeLine(
        from start: CGPoint,
        to end: CGPoint,
        into context: inout GraphicsContext,
        style: ChartPlotBorderStyle,
        stroke: StrokeStyle
    ) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        context.stroke(path, with: .color(style.color), style: stroke)
    }
}
