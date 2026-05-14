//
//  AnnotationRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

private struct PendingRangeAnnotationLabel {
    let annotation: RangeAnnotation
    let label: String
    let candidate: ChartLabelCandidate
}

public struct AnnotationRenderer {

    // MARK: - Range bands

    public static func drawRanges<YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [RangeAnnotation],
        activeYScale: YScale
    ) where YScale.InputType == Double, YScale.OutputType == CGFloat {

        var pendingLabels: [PendingRangeAnnotationLabel] = []

        for annotation in annotations {
            let lowerY = size.height - activeYScale.scale(annotation.yRange.lowerBound)
            let upperY = size.height - activeYScale.scale(annotation.yRange.upperBound)
            guard lowerY.isFinite, upperY.isFinite else { continue }

            let minY = min(lowerY, upperY)
            let maxY = max(lowerY, upperY)
            guard maxY >= 0, minY <= size.height else { continue }

            let rect = CGRect(
                x: 0,
                y: max(minY, 0),
                width: size.width,
                height: min(maxY, size.height) - max(minY, 0)
            )
            guard rect.height > 0 else { continue }
            context.fill(Path(rect), with: .color(annotation.color.opacity(annotation.opacity)))

            if annotation.showsLabel, let label = annotation.label {
                let anchor = CGPoint(
                    x: min(max(annotation.labelXPosition, 0), 1) * size.width,
                    y: rect.midY + annotation.labelYOffset
                )
                pendingLabels.append(
                    PendingRangeAnnotationLabel(
                        annotation: annotation,
                        label: label,
                        candidate: ChartLabelCandidate(
                            anchor: anchor,
                            size: ChartTextMetrics.estimatedSize(for: label),
                            priority: 0,
                            preferredPlacements: [.fixed(anchor), .automatic],
                            padding: 4,
                            spacing: 4,
                            canHide: false
                        )
                    )
                )
            }
        }

        let resolvedLabels = ChartLabelCollisionResolver.resolve(
            candidates: pendingLabels.map(\.candidate),
            canvasSize: size
        )
        let resolvedByID = Dictionary(uniqueKeysWithValues: resolvedLabels.map { ($0.id, $0) })

        for pendingLabel in pendingLabels {
            guard let resolved = resolvedByID[pendingLabel.candidate.id], resolved.isVisible else { continue }
            let text = Text(pendingLabel.label)
                .font(pendingLabel.annotation.labelFont)
                .foregroundColor(pendingLabel.annotation.labelColor)
            context.draw(text, at: resolved.position, anchor: .center)
        }
    }

    // MARK: - Horizontal lines

    public static func drawHorizontal<YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [HorizontalAnnotation],
        activeYScale: YScale
    ) where YScale.InputType == Double, YScale.OutputType == CGFloat {

        for annotation in annotations {
            let yPos = size.height - activeYScale.scale(annotation.yValue)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: yPos))
            path.addLine(to: CGPoint(x: size.width, y: yPos))
            context.stroke(
                path,
                with: .color(annotation.color),
                style: StrokeStyle(lineWidth: annotation.lineWidth, dash: annotation.dash)
            )
        }
    }

    // MARK: - Point symbols

    public static func drawPoints<XScale: Scale, YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [PointAnnotation<Double, Double>],
        activeXScale: XScale,
        activeYScale: YScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat,
            YScale.InputType == Double, YScale.OutputType == CGFloat {

        for annotation in annotations {
            let xPos = activeXScale.scale(annotation.x)
            let yPos = size.height - activeYScale.scale(annotation.y)

            guard xPos.isFinite,
                  yPos.isFinite,
                  xPos >= -annotation.size,
                  xPos <= size.width + annotation.size,
                  yPos >= -annotation.size,
                  yPos <= size.height + annotation.size else { continue }

            let rect = CGRect(
                x: xPos - annotation.size / 2,
                y: yPos - annotation.size / 2,
                width: annotation.size,
                height: annotation.size
            )
            let path = annotation.shape.path(in: rect)
            context.fill(path, with: .color(annotation.color))
            context.stroke(path, with: .color(annotation.strokeColor), lineWidth: annotation.strokeWidth)
        }
    }

    // MARK: - Crosshair

    public static func drawCrosshair<Point: ChartDataPoint>(
        into context: inout GraphicsContext,
        size: CGSize,
        points: [ChartPointContext<Point>],
        style: ChartCrosshairStyle
    ) {
        guard style.isVisible,
              size.width > 0,
              size.height > 0,
              let anchor = crosshairAnchor(for: points),
              anchor.x.isFinite,
              anchor.y.isFinite else { return }

        let clampedX = min(max(anchor.x, 0), size.width)
        let clampedY = min(max(anchor.y, 0), size.height)
        let stroke = StrokeStyle(lineWidth: style.lineWidth, dash: style.dash)

        if style.mode == .vertical || style.mode == .both {
            var path = Path()
            path.move(to: CGPoint(x: clampedX, y: 0))
            path.addLine(to: CGPoint(x: clampedX, y: size.height))
            context.stroke(path, with: .color(style.color), style: stroke)
        }

        if style.mode == .horizontal || style.mode == .both {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: clampedY))
            path.addLine(to: CGPoint(x: size.width, y: clampedY))
            context.stroke(path, with: .color(style.color), style: stroke)
        }
    }

    static func crosshairAnchor<Point: ChartDataPoint>(
        for points: [ChartPointContext<Point>]
    ) -> CGPoint? {
        guard !points.isEmpty else { return nil }
        let x = points.map(\.position.x).reduce(0, +) / CGFloat(points.count)
        let y = points.map(\.position.y).reduce(0, +) / CGFloat(points.count)
        return CGPoint(x: x, y: y)
    }
}
