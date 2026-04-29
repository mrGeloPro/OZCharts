//
//  LineSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

// MARK: - LineInterpolation

public enum LineInterpolation {
    case linear
    case step
}

// MARK: - AreaStyle

public struct AreaStyle {
    public var fillColor: Color?
    public var fillOpacity: Double
    public var baseline: Double?

    public init(fillColor: Color? = nil, fillOpacity: Double = 0.2, baseline: Double? = nil) {
        self.fillColor   = fillColor
        self.fillOpacity = fillOpacity
        self.baseline    = baseline
    }
}

// MARK: - LineSeries

public struct LineSeries<P: ChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id = UUID()
    public var data: [P]
    public var zIndex: Int
    public var label: String?

    public var color: Color
    public var lineWidth: CGFloat
    public var dash: [CGFloat]
    public var dashPhase: CGFloat
    public var lineCap: CGLineCap
    public var interpolation: LineInterpolation

    public var area: AreaStyle?
    public var animation: ChartAnimationStyle
    public var usesAnimatableOverlay: Bool { true }
    public var downsampling: ChartDownsampling

    public init(
        data: [P],
        color: Color,
        label: String?                    = nil,
        lineWidth: CGFloat               = 2,
        dash: [CGFloat]                  = [],
        dashPhase: CGFloat               = 0,
        lineCap: CGLineCap               = .round,
        interpolation: LineInterpolation = .linear,
        area: AreaStyle?                 = nil,
        downsampling: ChartDownsampling  = .none,
        animation: ChartAnimationStyle   = .none,
        zIndex: Int                      = 0
    ) {
        self.data          = data
        self.label         = label
        self.color         = color
        self.lineWidth     = lineWidth
        self.dash          = dash
        self.dashPhase     = dashPhase
        self.lineCap       = lineCap
        self.interpolation = interpolation
        self.area          = area
        self.downsampling  = downsampling
        self.animation     = animation
        self.zIndex        = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: color, symbol: .line)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        let contexts = renderContexts(from: contexts, in: size)
        guard contexts.count > 1 else { return }
        let sorted = contexts.sorted { $0.position.x < $1.position.x }
        let pts    = sorted.map(\.position)

        if let area {
            var areaPath = buildPath(from: pts)
            let baselineY = area.baseline.map { sorted.first?.scaleY($0) ?? size.height } ?? size.height
            areaPath.addLine(to: CGPoint(x: pts.last!.x, y: baselineY))
            areaPath.addLine(to: CGPoint(x: pts.first!.x, y: baselineY))
            areaPath.closeSubpath()
            context.fill(areaPath, with: .color((area.fillColor ?? color).opacity(area.fillOpacity)))
        }

        context.stroke(
            buildPath(from: pts),
            with: .color(color),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap, dash: dash, dashPhase: dashPhase)
        )
    }
    
    public func animatableView(oldContexts: [ChartPointContext<P>], newContexts: [ChartPointContext<P>], progress: CGFloat) -> AnyView {
        if animation.kind == .none { return AnyView(EmptyView()) }
        return AnyView(
            AnimatableChartLayer(
                oldPoints: oldContexts.sorted { $0.position.x < $1.position.x }.map(\.position),
                newPoints: newContexts.sorted { $0.position.x < $1.position.x }.map(\.position),
                progress: progress,
                animationStyle: animation,
                lineColor: color,
                lineWidth: lineWidth,
                drawLine: true,
                drawDots: false
            )
        )
    }

    func renderContexts(
        from contexts: [ChartPointContext<P>],
        in size: CGSize
    ) -> [ChartPointContext<P>] {
        guard let threshold = downsampling.threshold(for: size, pointCount: contexts.count) else {
            return contexts
        }
        return LTTBDownsampler.downsample(contexts, threshold: threshold)
    }

    func pathPoints(from pts: [CGPoint]) -> [CGPoint] {
        guard let first = pts.first else { return [] }
        var result = [first]
        for i in 1..<pts.count {
            if interpolation == .step {
                result.append(CGPoint(x: pts[i].x, y: pts[i - 1].y))
            }
            result.append(pts[i])
        }
        return result
    }

    private func buildPath(from pts: [CGPoint]) -> Path {
        var path = Path()
        let resolvedPoints = pathPoints(from: pts)
        guard let first = resolvedPoints.first else { return path }
        path.move(to: first)
        for point in resolvedPoints.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}
