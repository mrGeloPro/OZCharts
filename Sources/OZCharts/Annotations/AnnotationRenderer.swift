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

    // MARK: - X range bands

    public static func drawXRanges<XScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [XRangeAnnotation],
        activeXScale: XScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat {

        for annotation in annotations {
            let lowerX = activeXScale.scale(annotation.xRange.lowerBound)
            let upperX = activeXScale.scale(annotation.xRange.upperBound)
            guard lowerX.isFinite, upperX.isFinite else { continue }

            let minX = min(lowerX, upperX)
            let maxX = max(lowerX, upperX)
            guard maxX >= 0, minX <= size.width else { continue }

            let rect = CGRect(
                x: max(minX, 0),
                y: 0,
                width: min(maxX, size.width) - max(minX, 0),
                height: size.height
            )
            guard rect.width > 0 else { continue }
            context.fill(Path(rect), with: .color(annotation.color.opacity(annotation.opacity)))
        }
    }

    // MARK: - XY range regions

    public static func drawXYRanges<XScale: Scale, YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [XYRangeAnnotation],
        activeXScale: XScale,
        activeYScale: YScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat,
            YScale.InputType == Double, YScale.OutputType == CGFloat {

        for annotation in annotations {
            let lowerX = activeXScale.scale(annotation.xRange.lowerBound)
            let upperX = activeXScale.scale(annotation.xRange.upperBound)
            let lowerY = size.height - activeYScale.scale(annotation.yRange.lowerBound)
            let upperY = size.height - activeYScale.scale(annotation.yRange.upperBound)
            guard lowerX.isFinite, upperX.isFinite, lowerY.isFinite, upperY.isFinite else { continue }

            let minX = min(lowerX, upperX)
            let maxX = max(lowerX, upperX)
            let minY = min(lowerY, upperY)
            let maxY = max(lowerY, upperY)
            guard maxX >= 0, minX <= size.width, maxY >= 0, minY <= size.height else { continue }

            let rect = CGRect(
                x: max(minX, 0),
                y: max(minY, 0),
                width: min(maxX, size.width) - max(minX, 0),
                height: min(maxY, size.height) - max(minY, 0)
            )
            guard rect.width > 0, rect.height > 0 else { continue }
            context.fill(Path(rect), with: .color(annotation.color.opacity(annotation.opacity)))
        }
    }

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
                let labelSize = ChartTextMetrics.estimatedSize(for: label)
                let anchorPoint = CGPoint(
                    x: min(max(annotation.labelXPosition, 0), 1) * size.width,
                    y: rect.midY + annotation.labelYOffset
                )
                let center = AnnotationLabelLayout.center(
                    forAnchorPoint: anchorPoint,
                    size: labelSize,
                    anchor: annotation.labelAnchor
                )
                pendingLabels.append(
                    PendingRangeAnnotationLabel(
                        annotation: annotation,
                        label: label,
                        candidate: ChartLabelCandidate(
                            anchor: center,
                            size: labelSize,
                            priority: 0,
                            preferredPlacements: [.fixed(center), .automatic],
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

    // MARK: - Vertical lines

    public static func drawVertical<XScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [VerticalAnnotation],
        activeXScale: XScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat {

        for annotation in annotations {
            let xPos = activeXScale.scale(annotation.xValue)
            guard xPos.isFinite, xPos >= 0, xPos <= size.width else { continue }

            var path = Path()
            path.move(to: CGPoint(x: xPos, y: 0))
            path.addLine(to: CGPoint(x: xPos, y: size.height))
            context.stroke(
                path,
                with: .color(annotation.color),
                style: StrokeStyle(lineWidth: annotation.lineWidth, dash: annotation.dash)
            )
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

            let radius = annotation.size / 2
            let maxX = max(radius, size.width - radius)
            let maxY = max(radius, size.height - radius)
            let clampedX = min(max(xPos, radius), maxX)
            let clampedY = min(max(yPos, radius), maxY)
            let rect = CGRect(
                x: clampedX - radius,
                y: clampedY - radius,
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

enum AnnotationLabelLayout {
    static func center(
        forAnchorPoint point: CGPoint,
        size: CGSize,
        anchor: UnitPoint
    ) -> CGPoint {
        CGPoint(
            x: point.x + (0.5 - anchor.x) * size.width,
            y: point.y + (0.5 - anchor.y) * size.height
        )
    }
}
