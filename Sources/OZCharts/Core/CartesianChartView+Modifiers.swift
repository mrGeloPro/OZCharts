//
//  CartesianChartView+Modifiers.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension CartesianChartView {
    func chartPresentation(_ preset: ChartPresentationPreset) -> Self {
        var copy = self
        copy = copy.chartInteractionOptions(preset.interaction)
        copy = copy.chartSelectionOptions(preset.selection)
        copy = copy.chartTooltipOptions(preset.tooltip)
        copy = copy.chartViewportOptions(preset.viewport)
        copy = copy.chartRenderOptions(preset.rendering)
        if let xAxes = preset.xAxes {
            copy.xAxes = xAxes
        }
        if let yAxes = preset.yAxes {
            copy.yAxes = yAxes
        }
        return copy
    }

    func chartInteractionOptions(_ options: ChartInteractionOptions) -> Self {
        var copy = self
        copy.isHorizontalScrollEnabled = options.isHorizontalScrollEnabled
        copy.isVerticalScrollEnabled = options.isVerticalScrollEnabled
        copy.isHorizontalZoomEnabled = options.isHorizontalZoomEnabled
        copy.isVerticalZoomEnabled = options.isVerticalZoomEnabled
        copy.minZoomScale = options.minZoomScale
        return copy
    }

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

    func chartSelectionOptions(_ options: ChartSelectionOptions) -> Self {
        var copy = self
        copy.selectionMode = options.mode
        copy.selectionBehavior = options.behavior
        copy.selectionActivation = options.activation
        copy.nearestSelectionPolicy = options.nearestSelectionPolicy
        copy.overlappingSelectionMode = options.overlappingSelectionMode
        copy.hitboxRadius = options.hitboxRadius
        copy.selectionDismissalPolicy = options.dismissalPolicy
        return copy
    }

    func chartSelectionPriority(_ priority: ChartSelectionPriority) -> Self {
        var copy = self
        copy.selectionPriority = priority
        return copy
    }

    func chartSelection(
        _ mode: ChartSelectionMode,
        behavior: ChartSelectionBehavior? = nil,
        overlapping: ChartOverlappingSelectionMode? = nil,
        hitboxRadius: CGFloat? = nil,
        dismissalPolicy: ChartSelectionDismissalPolicy? = nil,
        activation: ChartSelectionActivation? = nil,
        nearestSelectionPolicy: ChartNearestSelectionPolicy? = nil,
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
        if let dismissalPolicy {
            copy.selectionDismissalPolicy = dismissalPolicy
        }
        if let activation {
            copy.selectionActivation = activation
        }
        if let nearestSelectionPolicy {
            copy.nearestSelectionPolicy = nearestSelectionPolicy
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
        fallbackToPointSelection: Bool? = nil,
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
        if let fallbackToPointSelection {
            copy.annotationFallbackToPointSelection = fallbackToPointSelection
        }
        if let onChange {
            copy.onAnnotationSelectionChanged = onChange
        }
        return copy
    }

    @available(*, deprecated, message: "Use chartSelectionChanged(_:) and read selection.elements instead.")
    func chartElementSelection(
        onChange: @escaping ([ChartSelectedElement]) -> Void
    ) -> Self {
        var copy = self
        copy.onElementSelectionChanged = onChange
        return copy
    }

    func chartSelectionChanged(
        _ onChange: @escaping (ChartSelection<Point>) -> Void
    ) -> Self {
        var copy = self
        copy.onChartSelectionChanged = onChange
        return copy
    }

    func chartSelectedElementStyle(_ style: ChartSelectedElementStyle) -> Self {
        var copy = self
        copy.selectedElementStyle = style
        return copy
    }

    func chartAnnotationTooltip(
        @ViewBuilder content: @escaping ([ChartAnnotationContext]) -> some View
    ) -> Self {
        var copy = self
        copy.annotationTooltipContent = { AnyView(content($0)) }
        return copy
    }

    func chartElementTooltip(
        @ViewBuilder content: @escaping ([ChartSelectedElement]) -> some View
    ) -> Self {
        var copy = self
        copy.elementTooltipContent = { AnyView(content($0.elements)) }
        return copy
    }

    func chartElementTooltipContext(
        @ViewBuilder content: @escaping (ChartElementTooltipContext) -> some View
    ) -> Self {
        var copy = self
        copy.elementTooltipContent = { AnyView(content($0)) }
        return copy
    }

    func chartElementTooltipIfNeeded(
        _ content: ((ChartElementTooltipContext) -> AnyView)?
    ) -> Self {
        var copy = self
        copy.elementTooltipContent = content
        return copy
    }

    func chartTooltipOptions(_ options: ChartTooltipOptions) -> Self {
        var copy = self
        copy.tooltipPlacement = options.placement
        copy.tooltipAnchor = options.anchor
        copy.tooltipOffset = options.offset
        copy.tooltipPadding = options.padding
        copy.tooltipMaxWidth = options.maxWidth
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

    func chartTooltipAnchor(_ anchor: ChartTooltipAnchor) -> Self {
        var copy = self
        copy.tooltipAnchor = anchor
        return copy
    }

    func chartSelectionDismissalPolicy(_ policy: ChartSelectionDismissalPolicy) -> Self {
        var copy = self
        copy.selectionDismissalPolicy = policy
        return copy
    }

    func chartTooltipMaxWidth(_ maxWidth: CGFloat?) -> Self {
        var copy = self
        copy.tooltipMaxWidth = maxWidth
        return copy
    }

    func chartViewportOptions(_ options: ChartViewportOptions) -> Self {
        var copy = self
        copy.liveTrackingMode = options.liveTrackingMode
        copy.isLiveTrackingEnabled = options.liveTrackingMode.isEnabled
        copy.initialViewport = options.initialViewport
        copy.showsZoomControls = options.showsZoomControls
        copy.zoomControlStep = options.zoomControlStep
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

    func chartRenderOptions(_ options: ChartRenderOptions) -> Self {
        var copy = self
        copy.legendOptions = options.legendOptions
        copy.selectedElementStyle = options.selectedElementStyle
        copy.canvasRenderOrder = options.canvasRenderOrder
        copy.plotBorderStyle = options.plotBorderStyle
        return copy
    }

    func chartLegend(_ options: ChartLegendOptions) -> Self {
        var copy = self
        copy.legendOptions = options
        return copy
    }

    func chartLegend(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12
    ) -> Self {
        var copy = self
        copy.legendOptions = ChartLegendOptions(position: position, itemSpacing: spacing)
        return copy
    }

    func chartLegend(
        _ options: ChartLegendOptions,
        @ViewBuilder content: @escaping ([ChartLegendItem]) -> some View
    ) -> Self {
        var copy = chartLegend(options)
        copy.customLegendContent = { AnyView(content($0)) }
        return copy
    }

    func chartLegend(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12,
        @ViewBuilder content: @escaping ([ChartLegendItem]) -> some View
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

    func chartPlotBorder(_ style: ChartPlotBorderStyle) -> Self {
        var copy = self
        copy.plotBorderStyle = style
        return copy
    }

    func chartPlotBorder(
        edges: ChartPlotBorderEdges = .all,
        color: Color = .gray.opacity(0.45),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = []
    ) -> Self {
        chartPlotBorder(
            ChartPlotBorderStyle(
                edges: edges,
                color: color,
                lineWidth: lineWidth,
                dash: dash
            )
        )
    }

    func chartPlotInsets(_ insets: ChartInsets) -> Self {
        var copy = self
        copy.plotInsets = insets
        return copy
    }

    func chartContentInsets(_ insets: ChartInsets) -> Self {
        var copy = self
        copy.contentInsets = insets
        return copy
    }

    func chartContentInsets(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> Self {
        chartContentInsets(
            ChartInsets(
                top: top,
                leading: leading,
                bottom: bottom,
                trailing: trailing
            )
        )
    }

    func chartPlotInsets(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> Self {
        chartPlotInsets(
            ChartInsets(
                top: top,
                leading: leading,
                bottom: bottom,
                trailing: trailing
            )
        )
    }

    func chartAxisMarkers(_ markers: [ChartAxisMarker]) -> Self {
        var copy = self
        copy.axisMarkers = markers
        return copy
    }

    func chartAxisMarkers(_ markers: ChartAxisMarker...) -> Self {
        chartAxisMarkers(markers)
    }

    func chartAxisMarkerSelection(
        _ isEnabled: Bool = true,
        hitboxRadius: CGFloat = 20,
        overlapping: ChartOverlappingSelectionMode = .cycle,
        onChange: @escaping ([ChartAxisMarkerContext]) -> Void = { _ in }
    ) -> Self {
        var copy = self
        copy.axisMarkerSelectionOptions = ChartAxisMarkerSelectionOptions(
            isEnabled: isEnabled,
            hitboxRadius: hitboxRadius,
            overlappingMode: overlapping
        )
        copy.onAxisMarkerSelectionChanged = onChange
        return copy
    }

    func chartEmptyState(
        @ViewBuilder _ content: @escaping () -> some View
    ) -> Self {
        var copy = self
        copy.emptyState = { AnyView(content()) }
        return copy
    }

    func chartEmptyTap(
        _ onTap: @escaping (CGPoint) -> Void
    ) -> Self {
        var copy = self
        copy.onEmptyTap = onTap
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

    func chartDiagnostics(
        onChange: @escaping ([ChartDiagnostic]) -> Void
    ) -> Self {
        var copy = self
        copy.onDiagnosticsChanged = onChange
        return copy
    }
}
