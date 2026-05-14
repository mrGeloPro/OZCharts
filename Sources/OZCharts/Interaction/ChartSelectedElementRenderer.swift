//
//  ChartSelectedElementRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

enum ChartSelectedElementRenderer {
    static func draw(
        into context: inout GraphicsContext,
        elements: [ChartElementContext],
        style: ChartSelectedElementStyle
    ) {
        guard style.lineWidth > 0 else { return }

        for element in elements {
            switch element.hitShape {
            case .circle(let center, let radius):
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                drawPath(Path(ellipseIn: rect), into: &context, style: style)

            case .rect(let rect):
                let path = Path(roundedRect: rect, cornerRadius: style.cornerRadius)
                drawPath(path, into: &context, style: style)

            case .donutSegment(let center, let innerRadius, let outerRadius, let startAngle, let endAngle):
                let radius = (innerRadius + outerRadius) / 2
                let thickness = max(1, outerRadius - innerRadius)
                var path = Path()
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .radians(startAngle),
                    endAngle: .radians(endAngle),
                    clockwise: false
                )
                context.stroke(
                    path,
                    with: .color(style.strokeColor),
                    style: StrokeStyle(lineWidth: thickness + style.lineWidth * 2, lineCap: .round)
                )
            }
        }
    }

    private static func drawPath(
        _ path: Path,
        into context: inout GraphicsContext,
        style: ChartSelectedElementStyle
    ) {
        context.fill(path, with: .color(style.fillColor))
        if style.lineWidth > 0 {
            context.stroke(path, with: .color(style.strokeColor), lineWidth: style.lineWidth)
        }
    }
}
