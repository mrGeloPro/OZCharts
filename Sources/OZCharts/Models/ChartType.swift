//
//  ChartType.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import SwiftUI

public enum LineInterpolation {
    case linear
    case step
}

public enum ChartType<Point: ChartDataPoint> where Point.XValue == Double, Point.YValue == Double {
    case line(lineWidth: CGFloat = 2, color: Color = .blue)
    case scatter(pointSize: CGFloat = 8, color: Color = .purple)
    case donut(thickness: CGFloat = 40, colors: [Color] = [.purple, .pink, .yellow])
    case groupedScatter(
        pointSize: CGFloat = 6,
        colorMapper: (Point) -> Color,
        backgroundRenderer: ((inout GraphicsContext, CGSize, CartesianCoordinator<Point, LinearScale, LinearScale>) -> Void)? = nil
    )
    
    case groupedArea(
        lineWidth: CGFloat = 2,
        fillOpacity: Double = 0.3,
        interpolation: LineInterpolation = .step,
        groupMapper: (Point) -> AnyHashable,
        colorMapper: (AnyHashable) -> Color,
        zOrder: [AnyHashable]
    )
    
    case stackedHorizontalBar(
        barHeight: CGFloat = 30,
        cornerRadius: CGFloat = 4,
        strokeColor: Color = .black.opacity(0.5),
        strokeWidth: CGFloat = 1.5,
        stackMapper: (Point) -> AnyHashable,
        colorMapper: (AnyHashable) -> Color,
        stackOrder: [AnyHashable]
    )
    
    case violin(
        pointSize: CGFloat = 6,
        centerX: Double,
        maxWidth: Double,
        bandwidth: Double = 12.0,
        resolution: Int = 60,
        groupMapper: (Point) -> AnyHashable,
        sideMapper: (AnyHashable) -> ViolinSide,
        colorMapper: (AnyHashable) -> Color
    )
}
