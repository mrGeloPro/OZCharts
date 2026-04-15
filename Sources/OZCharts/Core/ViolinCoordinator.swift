//
//  ViolinCoordinator.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import SwiftUI
import CoreGraphics

public enum ViolinSide { case left, right, symmetric }

public struct ViolinLayoutContext<Point: ChartDataPoint> {
    public let points: [ChartPointContext<Point>]
    public let backgroundPaths: [AnyHashable: Path]
}

public final class ViolinCoordinator<Point: ChartDataPoint, XScale: Scale, YScale: Scale>
where XScale.InputType == Double, XScale.OutputType == CGFloat,
      YScale.InputType == Double, YScale.OutputType == CGFloat,
      Point.XValue == Double, Point.YValue == Double {
    
    public var xScale: XScale
    public var yScale: YScale
    
    public init(xScale: XScale, yScale: YScale) {
        self.xScale = xScale
        self.yScale = yScale
    }
    
    public func calculateLayout(
        for data: [Point],
        in size: CGSize,
        centerX: Double,
        maxWidth: Double,
        pointSize: CGFloat,
        bandwidth: Double,
        resolution: Int,
        groupMapper: @escaping (Point) -> AnyHashable,
        sideMapper: @escaping (AnyHashable) -> ViolinSide
    ) async -> ViolinLayoutContext<Point> {
        
        let safeWidth = max(0, size.width)
        let safeHeight = max(0, size.height)
        
        xScale.range = 0...safeWidth
        xScale.isReversed = false
        yScale.range = 0...safeHeight
        yScale.isReversed = false
        let localXScale = xScale
        let localYScale = yScale
        
        return await Task.detached {
            var groupedData: [AnyHashable: [Point]] = [:]
            for point in data { groupedData[groupMapper(point), default: []].append(point) }
            
            var finalPoints: [ChartPointContext<Point>] = []
            var paths: [AnyHashable: Path] = [:]

            let dataMinY = data.map(\.y).min() ?? 0.0
            let dataMaxY = data.map(\.y).max() ?? 1.0
        
            let globalMinY = dataMinY - (bandwidth * 3)
            let globalMaxY = dataMaxY + (bandwidth * 3)
            

            let stepY = (globalMaxY - globalMinY) / Double(resolution)
            
            for (groupId, points) in groupedData {
                let side = sideMapper(groupId)
                var profile: [(y: Double, density: Double)] = []
                var maxDensity: Double = 0.0
                
                for i in 0...resolution {
                    let yVal = globalMinY + Double(i) * stepY
                    var density = 0.0
                    for p in points {
                        let distance = yVal - p.y
                        density += exp(-(distance * distance) / (2.0 * bandwidth * bandwidth))
                    }
                    profile.append((yVal, density))
                    maxDensity = max(maxDensity, density)
                }
                if maxDensity == 0 { maxDensity = 1 }
                
                var path = Path()
                let centerXPx = localXScale.scale(centerX)
                
                path.move(to: CGPoint(x: centerXPx, y: safeHeight - localYScale.scale(profile[0].y)))
                
                for point in profile {
                    let widthCoord = (point.density / maxDensity) * maxWidth
                    let yPx = safeHeight - localYScale.scale(point.y)
                    let xOffsetPx = localXScale.scale(centerX + (side == .left ? -widthCoord : widthCoord)) - centerXPx
                    path.addLine(to: CGPoint(x: centerXPx + xOffsetPx, y: yPx))
                }
                path.addLine(to: CGPoint(x: centerXPx, y: safeHeight - localYScale.scale(profile.last!.y)))
                path.closeSubpath()
                paths[groupId] = path
                
                let pointRadiusPx = (pointSize / 2.0) + 1.0
                
                for point in points {
                    var exactDensity = 0.0
                    for p in points {
                        let distance = point.y - p.y
                        exactDensity += exp(-(distance * distance) / (2.0 * bandwidth * bandwidth))
                    }
                    
                    let widthCoord = (exactDensity / maxDensity) * maxWidth
                    let maxXPx = localXScale.scale(centerX + widthCoord)
                    let pixelWidth = abs(maxXPx - centerXPx)
                    
                    let safePixelWidth = max(0, pixelWidth - pointRadiusPx)
                    var hasher = Hasher()
                    hasher.combine(point.id)
                    let hashValue = abs(hasher.finalize())
                    let pseudoRandomFactor = CGFloat(hashValue % 1000) / 1000.0
                    
                    let jitterPx = pseudoRandomFactor * safePixelWidth
                    
                    let finalXPx = side == .left ? centerXPx - jitterPx : centerXPx + jitterPx
                    finalPoints.append(ChartPointContext(
                        originalPoint: point,
                        position: CGPoint(x: finalXPx, y: safeHeight - localYScale.scale(point.y))
                    ))
                }
            }
            return ViolinLayoutContext(points: finalPoints, backgroundPaths: paths)
        }.value
    }
}
