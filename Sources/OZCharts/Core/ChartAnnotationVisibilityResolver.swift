//
//  ChartAnnotationVisibilityResolver.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

enum ChartAnnotationVisibilityResolver {
    static func visiblePointAnnotations(
        _ annotations: [PointAnnotation<Double, Double>],
        xDomain: ClosedRange<Double>,
        bufferFraction: Double = 0.1
    ) -> [PointAnnotation<Double, Double>] {
        let buffer = (xDomain.upperBound - xDomain.lowerBound) * bufferFraction
        return annotations.filter {
            $0.x >= (xDomain.lowerBound - buffer) &&
                $0.x <= (xDomain.upperBound + buffer)
        }
    }

    static func visibleCustomViewAnnotations(
        _ annotations: [CustomViewAnnotation<Double, Double>],
        xDomain: ClosedRange<Double>,
        yDomain: ClosedRange<Double>
    ) -> [CustomViewAnnotation<Double, Double>] {
        annotations.filter {
            $0.x >= xDomain.lowerBound &&
                $0.x <= xDomain.upperBound &&
                $0.y >= yDomain.lowerBound &&
                $0.y <= yDomain.upperBound
        }
    }

    static func position<XScale: Scale, YScale: Scale>(
        x: Double,
        y: Double,
        xScale: XScale,
        yScale: YScale,
        canvasSize: CGSize
    ) -> CGPoint where
        XScale.InputType == Double,
        XScale.OutputType == CGFloat,
        YScale.InputType == Double,
        YScale.OutputType == CGFloat {
        CGPoint(
            x: xScale.scale(x),
            y: canvasSize.height - yScale.scale(y)
        )
    }

    static func isValidCanvasPosition(
        _ position: CGPoint,
        canvasSize: CGSize
    ) -> Bool {
        canvasSize.width > 0 &&
            canvasSize.height > 0 &&
            position.x.isFinite &&
            position.y.isFinite &&
            position.x >= 0 &&
            position.x <= canvasSize.width &&
            position.y >= 0 &&
            position.y <= canvasSize.height
    }
}
