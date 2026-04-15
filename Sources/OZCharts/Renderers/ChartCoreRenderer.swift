//
//  ChartCoreRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 16.04.2026.
//

import SwiftUI

public struct ChartCoreRenderer {
    public static func draw<Point: ChartDataPoint, XScale: Scale, YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        type: ChartType<Point>,
        data: [Point],
        pointContexts: [ChartPointContext<Point>],
        violinBackgrounds: [AnyHashable: Path],
        activeXScale: XScale,
        activeYScale: YScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat,
            YScale.InputType == Double, YScale.OutputType == CGFloat,
            Point.XValue == Double, Point.YValue == Double {
        
        // 1. Малюємо фони для скрипки (якщо є)
        if case .violin(_, _, _, _, _, _, _, let colorMapper) = type {
            for (groupId, path) in violinBackgrounds {
                context.fill(path, with: .color(colorMapper(groupId).opacity(0.4)))
                context.stroke(path, with: .color(colorMapper(groupId)), lineWidth: 1)
            }
        }
        
        switch type {
        case .donut(let thickness, let colors):
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2 - thickness / 2
            let total = data.reduce(0) { $0 + $1.y }
            var startAngle = Angle.zero
            for (index, point) in data.enumerated() {
                let endAngle = startAngle + Angle(degrees: (point.y / total) * 360)
                var path = Path()
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                context.stroke(path, with: .color(colors[index % colors.count]), lineWidth: thickness)
                startAngle = endAngle
            }
            
        case .groupedArea(let lineWidth, let fillOpacity, let interpolation, let groupMapper, let colorMapper, let zOrder):
            var groupedPoints: [AnyHashable: [ChartPointContext<Point>]] = [:]
            for ctx in pointContexts { groupedPoints[groupMapper(ctx.originalPoint), default: []].append(ctx) }
            for groupId in zOrder {
                guard var points = groupedPoints[groupId], !points.isEmpty else { continue }
                points.sort { $0.position.x < $1.position.x }
                var linePath = Path()
                linePath.move(to: points[0].position)
                for i in 1..<points.count {
                    if interpolation == .step { linePath.addLine(to: CGPoint(x: points[i].position.x, y: points[i-1].position.y)) }
                    linePath.addLine(to: points[i].position)
                }
                var areaPath = linePath
                areaPath.addLine(to: CGPoint(x: points.last!.position.x, y: size.height))
                areaPath.addLine(to: CGPoint(x: points.first!.position.x, y: size.height))
                areaPath.closeSubpath()
                context.fill(areaPath, with: .color(colorMapper(groupId).opacity(fillOpacity)))
                context.stroke(linePath, with: .color(colorMapper(groupId)), style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
            }
            
        case .stackedHorizontalBar(let barHeight, let cornerRadius, let strokeColor, let strokeWidth, let stackMapper, let colorMapper, let stackOrder):
            var rows: [Double: [ChartPointContext<Point>]] = [:]
            for ctx in pointContexts { rows[ctx.originalPoint.y, default: []].append(ctx) }
            for (yValue, pointsInRow) in rows {
                let sortedPoints = pointsInRow.sorted { p1, p2 in
                    let i1 = stackOrder.firstIndex(of: stackMapper(p1.originalPoint)) ?? 0
                    let i2 = stackOrder.firstIndex(of: stackMapper(p2.originalPoint)) ?? 0
                    return i1 < i2
                }
                var currentX: CGFloat = activeXScale.scale(0)
                let yPos = size.height - activeYScale.scale(yValue)
                for ctx in sortedPoints {
                    let physicalWidth = activeXScale.scale(ctx.originalPoint.x) - activeXScale.scale(0)
                    let rect = CGRect(x: currentX, y: yPos - barHeight / 2, width: physicalWidth, height: barHeight)
                    let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
                    context.fill(path, with: .color(colorMapper(stackMapper(ctx.originalPoint))))
                    context.stroke(path, with: .color(strokeColor), lineWidth: strokeWidth)
                    currentX += physicalWidth
                }
            }
            
        case .violin(let pointSize, _, _, _, _, let groupMapper, _, let colorMapper):
            for point in pointContexts {
                let rect = CGRect(x: point.position.x - pointSize/2, y: point.position.y - pointSize/2, width: pointSize, height: pointSize)
                context.fill(Path(ellipseIn: rect), with: .color(colorMapper(groupMapper(point.originalPoint))))
            }
            
        default: break
        }
    }
}
