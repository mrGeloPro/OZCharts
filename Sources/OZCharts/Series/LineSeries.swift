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
    case monotone
}

// MARK: - AreaStyle

public struct AreaStyle {
    public var fillColor: Color?
    public var fillStyle: ChartFillStyle?
    public var fillOpacity: Double
    public var baseline: Double?

    public init(
        fillColor: Color? = nil,
        fillStyle: ChartFillStyle? = nil,
        fillOpacity: Double = 0.2,
        baseline: Double? = nil
    ) {
        self.fillColor = fillColor
        self.fillStyle = fillStyle
        self.fillOpacity = fillOpacity
        self.baseline = baseline
    }
}

// MARK: - LineSeries

public struct LineSeries<P: ChartDataPoint>: ChartSeriesProtocol
    where P.XValue == Double, P.YValue == Double {
    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var label: String?

    public var color: Color
    public var lineWidth: CGFloat
    public var dash: [CGFloat]
    public var dashPhase: CGFloat
    public var lineCap: CGLineCap
    public var interpolation: LineInterpolation
    public var strokeStyle: ChartFillStyle?
    public var shadow: ChartShadowStyle?

    public var area: AreaStyle?
    public var animation: ChartAnimationStyle
    public var usesAnimatableOverlay: Bool {
        true
    }

    public var downsampling: ChartDownsampling

    public init(
        data: [P],
        id: UUID = UUID(),
        color: Color,
        label: String? = nil,
        lineWidth: CGFloat = 2,
        dash: [CGFloat] = [],
        dashPhase: CGFloat = 0,
        lineCap: CGLineCap = .round,
        interpolation: LineInterpolation = .linear,
        strokeStyle: ChartFillStyle? = nil,
        shadow: ChartShadowStyle? = nil,
        area: AreaStyle? = nil,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.id = id
        self.data = data
        self.label = label
        self.color = color
        self.lineWidth = lineWidth
        self.dash = dash
        self.dashPhase = dashPhase
        self.lineCap = lineCap
        self.interpolation = interpolation
        self.strokeStyle = strokeStyle
        self.shadow = shadow
        self.area = area
        self.downsampling = downsampling
        self.animation = animation
        self.zIndex = zIndex
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
        let pts = sorted.map(\.position)

        if let area {
            var areaPath = buildPath(from: pts)
            let baselineY = area.baseline.map { sorted.first?.scaleY($0) ?? size.height } ?? size.height
            areaPath.addLine(to: CGPoint(x: pts.last!.x, y: baselineY))
            areaPath.addLine(to: CGPoint(x: pts.first!.x, y: baselineY))
            areaPath.closeSubpath()
            let rect = CGRect(origin: .zero, size: size)
            let fillStyle = area.fillStyle ?? .color((area.fillColor ?? color).opacity(area.fillOpacity))
            context.fill(areaPath, with: fillStyle, in: rect)
        }

        let linePath = buildPath(from: pts)
        let shading = (strokeStyle ?? .color(color)).shading(in: CGRect(origin: .zero, size: size))
        let style = StrokeStyle(lineWidth: lineWidth, lineCap: lineCap, dash: dash, dashPhase: dashPhase)
        if let shadow {
            context.drawLayer { layer in
                layer.addFilter(.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y))
                layer.stroke(linePath, with: shading, style: style)
            }
        } else {
            context.stroke(linePath, with: shading, style: style)
        }
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

    public func renderContexts(
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
        for i in 1 ..< pts.count {
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
        switch interpolation {
        case .linear, .step:
            for point in resolvedPoints.dropFirst() {
                path.addLine(to: point)
            }
        case .monotone:
            for segment in monotoneSegments(from: resolvedPoints) {
                path.addCurve(to: segment.end, control1: segment.control1, control2: segment.control2)
            }
        }
        return path
    }

    struct CubicSegment: Equatable {
        let control1: CGPoint
        let control2: CGPoint
        let end: CGPoint
    }

    func monotoneSegments(from pts: [CGPoint]) -> [CubicSegment] {
        guard pts.count > 1 else { return [] }

        let count = pts.count
        var deltas = Array(repeating: CGFloat.zero, count: count - 1)
        for index in 0 ..< (count - 1) {
            let dx = pts[index + 1].x - pts[index].x
            guard dx != 0 else {
                deltas[index] = 0
                continue
            }
            deltas[index] = (pts[index + 1].y - pts[index].y) / dx
        }

        var tangents = Array(repeating: CGFloat.zero, count: count)
        tangents[0] = deltas[0]
        tangents[count - 1] = deltas[count - 2]

        if count > 2 {
            for index in 1 ..< (count - 1) {
                if deltas[index - 1] * deltas[index] <= 0 {
                    tangents[index] = 0
                } else {
                    tangents[index] = (deltas[index - 1] + deltas[index]) / 2
                }
            }
        }

        for index in 0 ..< (count - 1) {
            guard deltas[index] != 0 else {
                tangents[index] = 0
                tangents[index + 1] = 0
                continue
            }

            let alpha = tangents[index] / deltas[index]
            let beta = tangents[index + 1] / deltas[index]
            let distance = hypot(alpha, beta)
            if distance > 3 {
                let tau = 3 / distance
                tangents[index] = tau * alpha * deltas[index]
                tangents[index + 1] = tau * beta * deltas[index]
            }
        }

        return (0 ..< (count - 1)).map { index in
            let dx = pts[index + 1].x - pts[index].x
            return CubicSegment(
                control1: CGPoint(
                    x: pts[index].x + dx / 3,
                    y: pts[index].y + tangents[index] * dx / 3
                ),
                control2: CGPoint(
                    x: pts[index + 1].x - dx / 3,
                    y: pts[index + 1].y - tangents[index + 1] * dx / 3
                ),
                end: pts[index + 1]
            )
        }
    }
}
