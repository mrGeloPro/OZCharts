//
//  CartesianChartView+Modifiers.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension CartesianChartView {
    func chartGestures(
        horizontalScroll: Bool? = nil,
        horizontalZoom: Bool? = nil,
        verticalScroll: Bool? = nil,
        verticalZoom: Bool? = nil,
        minZoomScale: Double? = nil
    ) -> Self {
        var copy = self
        if let horizontalScroll {
            copy.isHorizontalScrollEnabled = horizontalScroll
        }
        if let horizontalZoom {
            copy.isHorizontalZoomEnabled = horizontalZoom
        }
        if let verticalScroll {
            copy.isVerticalScrollEnabled = verticalScroll
        }
        if let verticalZoom {
            copy.isVerticalZoomEnabled = verticalZoom
        }
        if let minZoomScale {
            copy.minZoomScale = minZoomScale
        }
        return copy
    }

    func chartSelection(
        _ mode: ChartSelectionMode,
        behavior: ChartSelectionBehavior? = nil,
        overlapping: ChartOverlappingSelectionMode? = nil,
        hitboxRadius: CGFloat? = nil,
        clearsOnEnd: Bool? = nil,
        onChange: (([ChartPointContext<Point>]) -> Void)? = nil
    ) -> Self {
        var copy = self
        copy.selectionMode = mode
        if let behavior {
            copy.selectionBehavior = behavior
        }
        if let overlapping {
            copy.overlappingSelectionMode = overlapping
        }
        if let hitboxRadius {
            copy.hitboxRadius = hitboxRadius
        }
        if let clearsOnEnd {
            copy.clearsSelectionOnGestureEnd = clearsOnEnd
        }
        if let onChange {
            copy.onSelectionChanged = onChange
        }
        return copy
    }

    func chartAnnotationSelection(
        _ isEnabled: Bool = true,
        hitboxRadius: CGFloat? = nil,
        overlapping: ChartOverlappingSelectionMode? = nil,
        onChange: (([ChartAnnotationContext]) -> Void)? = nil
    ) -> Self {
        var copy = self
        copy.isAnnotationSelectionEnabled = isEnabled
        if let hitboxRadius {
            copy.annotationHitboxRadius = hitboxRadius
        }
        if let overlapping {
            copy.annotationOverlappingSelectionMode = overlapping
        }
        if let onChange {
            copy.onAnnotationSelectionChanged = onChange
        }
        return copy
    }

    func chartElementSelection(
        onChange: @escaping ([ChartSelectedElement]) -> Void
    ) -> Self {
        var copy = self
        copy.onElementSelectionChanged = onChange
        return copy
    }

    func chartSelectedElementStyle(_ style: ChartSelectedElementStyle) -> Self {
        var copy = self
        copy.selectedElementStyle = style
        return copy
    }

    func chartAnnotationTooltip<Content: View>(
        @ViewBuilder content: @escaping ([ChartAnnotationContext]) -> Content
    ) -> Self {
        var copy = self
        copy.annotationTooltipContent = { AnyView(content($0)) }
        return copy
    }

    func chartCrosshair(_ style: ChartCrosshairStyle) -> Self {
        var copy = self
        copy.crosshairStyle = style
        return copy
    }

    func chartTooltipOffset(_ offset: CGPoint) -> Self {
        var copy = self
        copy.tooltipOffset = offset
        return copy
    }

    func chartTooltipOffset(x: CGFloat = 0, y: CGFloat = -20) -> Self {
        chartTooltipOffset(CGPoint(x: x, y: y))
    }

    func chartTooltipPlacement(
        _ placement: ChartTooltipPlacement,
        padding: CGFloat? = nil
    ) -> Self {
        var copy = self
        copy.tooltipPlacement = placement
        if let padding {
            copy.tooltipPadding = padding
        }
        return copy
    }

    func chartTooltipMaxWidth(_ maxWidth: CGFloat?) -> Self {
        var copy = self
        copy.tooltipMaxWidth = maxWidth
        return copy
    }

    func chartLiveTracking(_ isEnabled: Bool = true) -> Self {
        var copy = self
        copy.liveTrackingMode = isEnabled ? .followLatest() : .disabled
        copy.isLiveTrackingEnabled = copy.liveTrackingMode.isEnabled
        return copy
    }

    func chartLiveTracking(_ mode: ChartLiveTrackingMode) -> Self {
        var copy = self
        copy.liveTrackingMode = mode
        copy.isLiveTrackingEnabled = mode.isEnabled
        return copy
    }

    func chartInitialViewport(_ viewport: ChartInitialViewport?) -> Self {
        var copy = self
        copy.initialViewport = viewport
        return copy
    }

    func chartInitialViewport(
        x: ClosedRange<Double>? = nil,
        y: ClosedRange<Double>? = nil
    ) -> Self {
        chartInitialViewport(ChartInitialViewport(x: x, y: y))
    }

    func chartInitialViewport(
        xWindow length: Double,
        anchor: ChartViewportAnchor = .leading
    ) -> Self {
        chartInitialViewport(.xWindow(length: length, anchor: anchor))
    }

    func chartInitialViewport(
        yWindow length: Double,
        anchor: ChartViewportAnchor = .leading
    ) -> Self {
        chartInitialViewport(.yWindow(length: length, anchor: anchor))
    }

    func chartViewport(_ viewport: Binding<ChartViewportState>) -> Self {
        var copy = self
        copy.viewportBinding = viewport
        return copy
    }

    func chartSelectionState(_ selectionState: Binding<ChartSelectionState>) -> Self {
        var copy = self
        copy.selectionStateBinding = selectionState
        return copy
    }

    func chartZoomControls(
        _ isVisible: Bool = true,
        step: Double = 2
    ) -> Self {
        var copy = self
        copy.showsZoomControls = isVisible
        copy.zoomControlStep = step
        return copy
    }

    func chartLegend(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12
    ) -> Self {
        var copy = self
        copy.legendPosition = position
        copy.legendSpacing = spacing
        return copy
    }

    func chartLegend<LegendContent: View>(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12,
        @ViewBuilder content: @escaping ([ChartLegendItem]) -> LegendContent
    ) -> Self {
        var copy = chartLegend(position, spacing: spacing)
        copy.customLegendContent = { AnyView(content($0)) }
        return copy
    }

    func chartCanvasRenderOrder(_ order: [CanvasLayer]) -> Self {
        var copy = self
        copy.canvasRenderOrder = order
        return copy
    }

    func chartEmptyState<EmptyContent: View>(
        @ViewBuilder _ content: @escaping () -> EmptyContent
    ) -> Self {
        var copy = self
        copy.emptyState = { AnyView(content()) }
        return copy
    }

    func chartAccessibility(
        label: String,
        summary: String? = nil,
        selectedValueFormatter: @escaping ([ChartPointContext<Point>]) -> String? = { points in
            guard let point = points.first else { return nil }
            return "Selected x \(point.originalPoint.x), y \(point.originalPoint.y)"
        },
        selectedElementFormatter: @escaping ([ChartSelectedElement]) -> String? = { elements in
            guard let element = elements.first else { return nil }
            if let label = element.label {
                return "Selected \(label)"
            }
            return element.value.map { "Selected value \($0)" }
        }
    ) -> Self {
        var copy = self
        copy.accessibilityDescriptor = ChartAccessibilityDescriptor(
            label: label,
            summary: summary,
            selectedValueFormatter: selectedValueFormatter,
            selectedElementFormatter: selectedElementFormatter
        )
        return copy
    }
}
