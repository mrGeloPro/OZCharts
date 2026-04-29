//
//  CartesianCoordinator.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import CoreGraphics

// MARK: - ChartPointContext

public struct ChartPointContext<Point: ChartDataPoint>: Identifiable {
    public var id: UUID { originalPoint.id }
    public let originalPoint: Point
    public let position: CGPoint
    public let scaleX: (Double) -> CGFloat
    /// Maps a logical y-value (Double) into screen y-coordinate (already y-flipped so screen origin is top-left).
    public let scaleY: (Double) -> CGFloat

    public init(
        originalPoint: Point,
        position: CGPoint,
        scaleX: @escaping (Double) -> CGFloat = { _ in 0 },
        scaleY: @escaping (Double) -> CGFloat = { _ in 0 }
    ) {
        self.originalPoint = originalPoint
        self.position      = position
        self.scaleX        = scaleX
        self.scaleY        = scaleY
    }
}

// MARK: - CartesianCoordinator

public struct CartesianCoordinator<Point: ChartDataPoint, XScale: Scale, YScale: Scale>
where XScale.InputType == Point.XValue, XScale.OutputType == CGFloat,
      YScale.InputType == Point.YValue, YScale.OutputType == CGFloat,
      Point.XValue == Double, Point.YValue == Double {

    public var xScale: XScale
    public var yScale: YScale

    public init(xScale: XScale, yScale: YScale) {
        self.xScale = xScale
        self.yScale = yScale
    }

    // MARK: Layout

    public mutating func calculateLayout(for data: [Point], in size: CGSize) -> [ChartPointContext<Point>] {
        let safeWidth  = max(0, size.width)
        let safeHeight = max(0, size.height)

        xScale.range = 0...safeWidth
        yScale.range = 0...safeHeight

        let lx = xScale
        let ly = yScale

        return data.map { point in
            ChartPointContext(
                originalPoint: point,
                position: CGPoint(
                    x: lx.scale(point.x),
                    y: safeHeight - ly.scale(point.y)
                ),
                scaleX: { v in lx.scale(v) },
                scaleY: { v in safeHeight - ly.scale(v) }
            )
        }
    }

    // MARK: Hit-testing

    public mutating func value(at location: CGPoint, in size: CGSize) -> (x: Point.XValue, y: Point.YValue) {
        let safeWidth  = max(0, size.width)
        let safeHeight = max(0, size.height)

        xScale.range = 0...safeWidth
        yScale.range = 0...safeHeight

        return (xScale.invert(location.x), yScale.invert(safeHeight - location.y))
    }

    public func nearestPoint(
        to location: CGPoint,
        from contexts: [ChartPointContext<Point>]
    ) -> ChartPointContext<Point>? {
        contexts.min {
            hypot($0.position.x - location.x, $0.position.y - location.y) <
            hypot($1.position.x - location.x, $1.position.y - location.y)
        }
    }
}
