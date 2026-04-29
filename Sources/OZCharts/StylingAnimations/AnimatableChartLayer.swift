//
//  AnimatableChartLayer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct AnimatableChartLayer: View, Animatable {
    public var oldPoints: [CGPoint]
    public var newPoints: [CGPoint]
    public var progress: CGFloat

    public var animationStyle: ChartAnimationStyle
    public var lineColor: Color
    public var lineWidth: CGFloat
    public var drawLine: Bool
    public var drawDots: Bool

    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    // MARK: - Interpolated points (for .morph)

    private var interpolatedPoints: [CGPoint] {
        Self.interpolatedPoints(old: oldPoints, new: newPoints, progress: progress)
    }

    // MARK: - Body

    public var body: some View {
        Canvas { context, size in
            guard !newPoints.isEmpty else { return }
            let strokeStyle = StrokeStyle(lineWidth: lineWidth, lineJoin: .round)

            if drawLine {
                switch animationStyle.kind {
                case .none:
                    context.stroke(linePath(newPoints), with: .color(lineColor), style: strokeStyle)

                case .morph:
                    context.stroke(linePath(interpolatedPoints), with: .color(lineColor), style: strokeStyle)

                case .draw:
                    guard let first = newPoints.first, let last = newPoints.last else { return }
                    let currentX = Self.drawClipMaxX(firstX: first.x, lastX: last.x, progress: progress)
                    var ctx = context
                    ctx.clip(to: Path(CGRect(x: 0, y: 0, width: currentX, height: size.height)))
                    ctx.stroke(linePath(newPoints), with: .color(lineColor), style: strokeStyle)

                case .fade:
                    if !oldPoints.isEmpty {
                        var ctx = context
                        ctx.opacity = 1.0 - progress
                        ctx.stroke(linePath(oldPoints), with: .color(lineColor), style: strokeStyle)
                    }
                    var ctx = context
                    ctx.opacity = progress
                    ctx.stroke(linePath(newPoints), with: .color(lineColor), style: strokeStyle)
                }
            }

            if drawDots {
                let pts = animationStyle.kind == .morph ? interpolatedPoints : newPoints
                var ctx = context
                ctx.opacity = animationStyle.kind == .fade ? progress : 1.0
                for point in pts {
                    let rect = CGRect(
                        x: point.x - lineWidth / 2,
                        y: point.y - lineWidth / 2,
                        width: lineWidth,
                        height: lineWidth
                    )
                    ctx.fill(Path(ellipseIn: rect), with: .color(lineColor))
                }
            }
        }
    }

    // MARK: - Private

    private func linePath(_ pts: [CGPoint]) -> Path {
        var path = Path()
        guard let first = pts.first else { return path }
        path.move(to: first)
        for i in 1..<pts.count { path.addLine(to: pts[i]) }
        return path
    }

    static func interpolatedPoints(old oldPoints: [CGPoint], new newPoints: [CGPoint], progress: CGFloat) -> [CGPoint] {
        let clampedProgress = min(max(progress, 0), 1)
        let maxCount = max(oldPoints.count, newPoints.count)
        guard maxCount > 0 else { return [] }
        return (0..<maxCount).map { i in
            let old = oldPoints.isEmpty
                ? (i < newPoints.count ? newPoints[i] : .zero)
                : (i < oldPoints.count ? oldPoints[i] : oldPoints.last!)
            let new = newPoints.isEmpty
                ? old
                : (i < newPoints.count ? newPoints[i] : newPoints.last!)
            return CGPoint(
                x: old.x + (new.x - old.x) * clampedProgress,
                y: old.y + (new.y - old.y) * clampedProgress
            )
        }
    }

    static func drawClipMaxX(firstX: CGFloat, lastX: CGFloat, progress: CGFloat) -> CGFloat {
        let clampedProgress = min(max(progress, 0), 1)
        return firstX + (lastX - firstX) * clampedProgress
    }
}
