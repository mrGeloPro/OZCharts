//
//  StackedAreaSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct StackedAreaLayer<GroupID: Hashable> {
    let group: GroupID
    let lower: [CGPoint]
    let upper: [CGPoint]
}

private struct StackedAreaKey<GroupID: Hashable>: Hashable {
    let group: GroupID
    let x: Double
}

public struct StackedAreaSeries<P: GroupedChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle

    public var stackOrder: [P.GroupID]
    public var colorMapper: (P.GroupID) -> Color
    public var fillStyleMapper: ((P.GroupID) -> ChartFillStyle)?
    public var groupLabel: ((P.GroupID) -> String?)?
    public var interpolation: LineInterpolation
    public var lineWidth: CGFloat
    public var fillOpacity: Double
    public var shadow: ChartShadowStyle?

    public init(
        data: [P],
        id: UUID = UUID(),
        stackOrder: [P.GroupID],
        colorMapper: @escaping (P.GroupID) -> Color,
        fillStyleMapper: ((P.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((P.GroupID) -> String?)? = nil,
        interpolation: LineInterpolation = .step,
        lineWidth: CGFloat = 3,
        fillOpacity: Double = 0.32,
        shadow: ChartShadowStyle? = nil,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.id = id
        self.data = data
        self.stackOrder = stackOrder
        self.colorMapper = colorMapper
        self.fillStyleMapper = fillStyleMapper
        self.groupLabel = groupLabel
        self.interpolation = interpolation
        self.lineWidth = lineWidth
        self.fillOpacity = fillOpacity
        self.shadow = shadow
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItems: [ChartLegendItem] {
        guard let groupLabel else { return [] }
        return stackOrder.compactMap { group in
            guard let title = groupLabel(group) else { return nil }
            return ChartLegendItem(title: title, color: colorMapper(group), symbol: .square)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        let layers = stackedAreaLayers(contexts: contexts)
        guard !layers.isEmpty else { return }

        for layer in layers {
            let areaPath = areaPath(lower: layer.lower, upper: layer.upper)
            let fill = fillStyleMapper?(layer.group) ?? .color(colorMapper(layer.group).opacity(fillOpacity))
            let rect = CGRect(origin: .zero, size: size)

            if let shadow {
                context.drawLayer { drawingLayer in
                    drawingLayer.addFilter(.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y))
                    drawingLayer.fill(areaPath, with: fill, in: rect)
                }
            } else {
                context.fill(areaPath, with: fill, in: rect)
            }

            let upperPath = linePath(points: layer.upper)
            context.stroke(
                upperPath,
                with: .color(colorMapper(layer.group)),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
            )
        }
    }

    func stackedAreaLayers(contexts: [ChartPointContext<P>]) -> [StackedAreaLayer<P.GroupID>] {
        guard let reference = contexts.first else { return [] }

        let xValues = Array(Set(contexts.map(\.originalPoint.x))).sorted()
        guard !xValues.isEmpty else { return [] }

        var valueByGroupAndX: [StackedAreaKey<P.GroupID>: Double] = [:]
        for context in contexts {
            let point = context.originalPoint
            valueByGroupAndX[StackedAreaKey(group: point.group, x: point.x), default: 0] += point.y
        }

        var cumulative = Dictionary(uniqueKeysWithValues: xValues.map { ($0, 0.0) })
        var layers: [StackedAreaLayer<P.GroupID>] = []

        for group in stackOrder {
            var lower: [CGPoint] = []
            var upper: [CGPoint] = []

            for x in xValues {
                let value = valueByGroupAndX[StackedAreaKey(group: group, x: x)] ?? 0
                let lowerValue = cumulative[x] ?? 0
                let upperValue = lowerValue + value
                cumulative[x] = upperValue

                lower.append(CGPoint(x: reference.scaleX(x), y: reference.scaleY(lowerValue)))
                upper.append(CGPoint(x: reference.scaleX(x), y: reference.scaleY(upperValue)))
            }

            if upper.contains(where: { $0.y.isFinite }) {
                layers.append(StackedAreaLayer(group: group, lower: lower, upper: upper))
            }
        }

        return layers
    }

    private func areaPath(lower: [CGPoint], upper: [CGPoint]) -> Path {
        var path = linePath(points: upper)
        for point in resolvedPathPoints(from: lower).reversed() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    private func linePath(points: [CGPoint]) -> Path {
        var path = Path()
        let resolved = resolvedPathPoints(from: points)
        guard let first = resolved.first else { return path }
        path.move(to: first)
        for point in resolved.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }

    private func resolvedPathPoints(from points: [CGPoint]) -> [CGPoint] {
        guard let first = points.first else { return [] }
        var result = [first]
        for index in 1..<points.count {
            if interpolation == .step {
                result.append(CGPoint(x: points[index].x, y: points[index - 1].y))
            }
            result.append(points[index])
        }
        return result
    }
}
