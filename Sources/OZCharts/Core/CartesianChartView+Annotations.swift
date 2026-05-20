//
//  CartesianChartView+Annotations.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension CartesianChartView {
    var visiblePointAnnotations: [PointAnnotation<Double, Double>] {
        ChartAnnotationVisibilityResolver.visiblePointAnnotations(
            pointAnnotations,
            xDomain: store.activeXScale.domain
        )
    }

    var visibleCustomViewAnnotations: [CustomViewAnnotation<Double, Double>] {
        ChartAnnotationVisibilityResolver.visibleCustomViewAnnotations(
            customViewAnnotations,
            xDomain: store.activeXScale.domain,
            yDomain: store.activeYScale.domain
        )
    }

    func resolvedCustomViewAnnotations(
        in canvasSize: CGSize
    ) -> [UUID: ChartResolvedLabel] {
        let candidates = visibleCustomViewAnnotations.compactMap { annotation -> ChartLabelCandidate? in
            let anchor = annotationPosition(x: annotation.x, y: annotation.y)
            guard isValidCanvasPosition(anchor) else { return nil }
            let measuredSize = customAnnotationSizes[annotation.id] ?? CGSize(width: 1, height: 1)
            return ChartLabelCandidate(
                id: annotation.id,
                anchor: anchor,
                size: measuredSize,
                priority: annotation.collisionPriority,
                preferredPlacements: [annotation.placement],
                padding: annotation.padding,
                spacing: 6,
                canHide: annotation.avoidsCollisions
            )
        }

        let resolved = ChartLabelCollisionResolver.resolve(
            candidates: candidates,
            canvasSize: canvasSize
        )
        return Dictionary(uniqueKeysWithValues: resolved.map { ($0.id, $0) })
    }

    var selectableAnnotationContexts: [ChartAnnotationContext] {
        pointAnnotationContexts + customViewAnnotationContexts
    }

    var pointAnnotationContexts: [ChartAnnotationContext] {
        visiblePointAnnotations.compactMap { annotation in
            guard annotation.isSelectable else { return nil }
            let position = annotationPosition(x: annotation.x, y: annotation.y)
            guard isValidCanvasPosition(position) else { return nil }
            return ChartAnnotationContext(
                id: annotation.id,
                kind: .point,
                x: annotation.x,
                y: annotation.y,
                position: position,
                label: annotation.label,
                hitboxRadius: annotation.hitboxRadius ?? max(annotation.size / 2, annotationHitboxRadius)
            )
        }
    }

    var customViewAnnotationContexts: [ChartAnnotationContext] {
        visibleCustomViewAnnotations.compactMap { annotation in
            guard annotation.isSelectable else { return nil }
            let position = annotationPosition(x: annotation.x, y: annotation.y)
            guard isValidCanvasPosition(position) else { return nil }
            return ChartAnnotationContext(
                id: annotation.id,
                kind: .customView,
                x: annotation.x,
                y: annotation.y,
                position: position,
                label: annotation.label,
                hitboxRadius: annotation.hitboxRadius
            )
        }
    }

    func annotationPosition(x: Double, y: Double) -> CGPoint {
        ChartAnnotationVisibilityResolver.position(
            x: x,
            y: y,
            xScale: store.activeXScale,
            yScale: store.activeYScale,
            canvasSize: store.canvasSize
        )
    }

    func isValidCanvasPosition(_ position: CGPoint) -> Bool {
        ChartAnnotationVisibilityResolver.isValidCanvasPosition(
            position,
            canvasSize: store.canvasSize
        )
    }
}
