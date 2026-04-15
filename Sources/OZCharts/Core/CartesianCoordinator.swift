//
//  CartesianCoordinator.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import Foundation
import CoreGraphics

public struct ChartPointContext<Point: ChartDataPoint>: Identifiable {
    public var id: UUID { originalPoint.id }
    public let originalPoint: Point
    public let position: CGPoint
    
    public init(originalPoint: Point, position: CGPoint) {
        self.originalPoint = originalPoint
        self.position = position
    }
}

public final class CartesianCoordinator<Point: ChartDataPoint, XScale: Scale, YScale: Scale>
where XScale.InputType == Point.XValue, XScale.OutputType == CGFloat,
      YScale.InputType == Point.YValue, YScale.OutputType == CGFloat {
    
    public var xScale: XScale
    public var yScale: YScale
    
    public init(xScale: XScale, yScale: YScale) {
        self.xScale = xScale
        self.yScale = yScale
    }
    
    public func calculateLayout(for data: [Point], in size: CGSize) async -> [ChartPointContext<Point>] {
            let safeWidth = max(0, size.width)
            let safeHeight = max(0, size.height)
            
            xScale.range = 0...safeWidth
            yScale.range = 0...safeHeight
                
            let localXScale = xScale
            let localYScale = yScale
            
            return await Task.detached {
                return data.map { dataPoint in
                    ChartPointContext(
                        originalPoint: dataPoint,
                        position: CGPoint(
                            x: localXScale.scale(dataPoint.x),
                            y: safeHeight - localYScale.scale(dataPoint.y)
                        )
                    )
                }
            }.value
        }
        
        public func value(at location: CGPoint, in size: CGSize) -> (x: Point.XValue, y: Point.YValue) {
            let safeWidth = max(0, size.width)
            let safeHeight = max(0, size.height)
            
            xScale.range = 0...safeWidth
            yScale.range = 0...safeHeight
            
            let adjustedY = safeHeight - location.y
            
            return (xScale.invert(location.x), yScale.invert(adjustedY))
        }
    
    public func nearestPoint(to location: CGPoint, from contexts: [ChartPointContext<Point>]) -> ChartPointContext<Point>? {
        guard !contexts.isEmpty else { return nil }
        return contexts.min(by: { point1, point2 in
            hypot(point1.position.x - location.x, point1.position.y - location.y) <
            hypot(point2.position.x - location.x, point2.position.y - location.y)
        })
    }
}
