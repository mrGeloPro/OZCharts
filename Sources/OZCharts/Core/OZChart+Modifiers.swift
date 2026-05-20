//
//  OZChart+Modifiers.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension OZChart {
    func domain(
        x: ChartDomain? = nil,
        y: ChartDomain? = nil
    ) -> Self {
        var copy = self
        if let x {
            copy.xDomain = x
        }
        if let y {
            copy.yDomain = y
        }
        return copy
    }

    func axes(
        x: [XAxisConfig]? = nil,
        y: [YAxisConfig]? = nil
    ) -> Self {
        var copy = self
        copy.xAxes = x
        copy.yAxes = y
        return copy
    }

    func annotations(
        xRanges: [XRangeAnnotation] = [],
        xyRanges: [XYRangeAnnotation] = [],
        ranges: [RangeAnnotation] = [],
        vertical: [VerticalAnnotation] = [],
        horizontal: [HorizontalAnnotation] = [],
        points: [PointAnnotation<Double, Double>] = [],
        events: [ChartEventMarker] = [],
        customViews: [CustomViewAnnotation<Double, Double>] = []
    ) -> Self {
        var copy = self
        copy.xRangeAnnotations = xRanges
        copy.xyRangeAnnotations = xyRanges
        copy.rangeAnnotations = ranges
        copy.verticalAnnotations = vertical
        copy.horizontalAnnotations = horizontal
        copy.pointAnnotations = points
        copy.eventMarkers = events
        copy.customViewAnnotations = customViews
        return copy
    }

    func axisMarkers(_ markers: [ChartAxisMarker]) -> Self {
        var copy = self
        copy.axisMarkers = markers
        return copy
    }

    func axisMarkers(_ markers: ChartAxisMarker...) -> Self {
        axisMarkers(markers)
    }

    func axisMarkerSelection(
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

    func interaction(_ options: ChartInteractionOptions) -> Self {
        var copy = self
        copy.interactionOptions = options
        return copy
    }

    func selection(_ options: ChartSelectionOptions) -> Self {
        var copy = self
        copy.selectionOptions = options
        return copy
    }

    func selectionDismissal(_ policy: ChartSelectionDismissalPolicy) -> Self {
        var copy = self
        copy.selectionOptions.dismissalPolicy = policy
        return copy
    }

    func selectionPriority(_ priority: ChartSelectionPriority) -> Self {
        var copy = self
        copy.selectionPriority = priority
        return copy
    }

    func annotationSelection(
        _ isEnabled: Bool = true,
        hitboxRadius: CGFloat? = nil,
        overlapping: ChartOverlappingSelectionMode? = nil,
        fallbackToPointSelection: Bool? = nil,
        onChange: (([ChartAnnotationContext]) -> Void)? = nil
    ) -> Self {
        var copy = self
        copy.isAnnotationSelectionEnabled = isEnabled
        copy.annotationHitboxRadius = hitboxRadius
        copy.annotationOverlappingSelectionMode = overlapping
        copy.annotationFallbackToPointSelection = fallbackToPointSelection
        if let onChange {
            copy.onAnnotationSelectionChanged = onChange
        }
        return copy
    }

    func tooltipOptions(_ options: ChartTooltipOptions) -> Self {
        var copy = self
        copy.tooltipOptions = options
        return copy
    }

    func tooltipAnchor(_ anchor: ChartTooltipAnchor) -> Self {
        var copy = self
        copy.tooltipOptions.anchor = anchor
        return copy
    }

    func viewport(_ options: ChartViewportOptions) -> Self {
        var copy = self
        copy.viewportOptions = options
        return copy
    }

    func rendering(_ options: ChartRenderOptions) -> Self {
        var copy = self
        copy.renderOptions = options
        return copy
    }

    func plotBorder(_ style: ChartPlotBorderStyle) -> Self {
        var copy = self
        copy.renderOptions.plotBorderStyle = style
        return copy
    }

    func plotBorder(
        edges: ChartPlotBorderEdges = .all,
        color: Color = .gray.opacity(0.45),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = []
    ) -> Self {
        plotBorder(
            ChartPlotBorderStyle(
                edges: edges,
                color: color,
                lineWidth: lineWidth,
                dash: dash
            )
        )
    }

    func plotInsets(_ insets: ChartInsets) -> Self {
        var copy = self
        copy.plotInsets = insets
        return copy
    }

    func contentInsets(_ insets: ChartInsets) -> Self {
        var copy = self
        copy.contentInsets = insets
        return copy
    }

    func contentInsets(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> Self {
        contentInsets(
            ChartInsets(
                top: top,
                leading: leading,
                bottom: bottom,
                trailing: trailing
            )
        )
    }

    func plotInsets(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> Self {
        plotInsets(
            ChartInsets(
                top: top,
                leading: leading,
                bottom: bottom,
                trailing: trailing
            )
        )
    }

    func presentation(_ preset: ChartPresentationPreset) -> Self {
        var copy = self
        if let theme = preset.theme {
            copy.theme = theme
        }
        copy.interactionOptions = preset.interaction
        copy.selectionOptions = preset.selection
        copy.tooltipOptions = preset.tooltip
        copy.viewportOptions = preset.viewport
        copy.renderOptions = preset.rendering
        if let xAxes = preset.xAxes {
            copy.xAxes = xAxes
        }
        if let yAxes = preset.yAxes {
            copy.yAxes = yAxes
        }
        return copy
    }

    func legend(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12
    ) -> Self {
        legend(ChartLegendOptions(position: position, itemSpacing: spacing))
    }

    func legend(_ options: ChartLegendOptions) -> Self {
        var copy = self
        copy.renderOptions.legendOptions = options
        return copy
    }

    func staticChart() -> Self {
        var copy = self
        copy.interactionOptions = .static
        copy.selectionOptions = .disabled
        copy.viewportOptions.showsZoomControls = false
        return copy
    }

    func hiddenAxes() -> Self {
        var copy = self
        copy.xAxes = [.hidden()]
        copy.yAxes = [.hidden()]
        return copy
    }

    func compactAxes(
        xTickCount: Int = 4,
        yTickCount: Int = 4,
        xPosition: XAxisPosition = .bottom,
        yPosition: YAxisPosition = .leading
    ) -> Self {
        var copy = self
        copy.xAxes = [.compact(position: xPosition, tickCount: xTickCount)]
        copy.yAxes = [.compact(position: yPosition, tickCount: yTickCount)]
        return copy
    }

    func viewportState(_ viewport: Binding<ChartViewportState>) -> Self {
        var copy = self
        copy.viewportBinding = viewport
        return copy
    }

    func selectionState(_ selectionState: Binding<ChartSelectionState>) -> Self {
        var copy = self
        copy.selectionStateBinding = selectionState
        return copy
    }

    @available(*, deprecated, message: "Use onSelection(_:) and read selection.points instead.")
    func onSelectionChanged(
        _ handler: @escaping ([ChartPointContext<Point>]) -> Void
    ) -> Self {
        var copy = self
        copy.onSelectionChanged = handler
        return copy
    }

    @available(*, deprecated, message: "Use onSelection(_:) and read selection.elements instead.")
    func onElementSelectionChanged(
        _ handler: @escaping ([ChartSelectedElement]) -> Void
    ) -> Self {
        var copy = self
        copy.onElementSelectionChanged = handler
        return copy
    }

    func onSelection(
        _ handler: @escaping (ChartSelection<Point>) -> Void
    ) -> Self {
        var copy = self
        copy.onChartSelectionChanged = handler
        return copy
    }

    func elementTooltip<Content: View>(
        @ViewBuilder _ content: @escaping ([ChartSelectedElement]) -> Content
    ) -> Self {
        var copy = self
        copy.elementTooltipContent = { AnyView(content($0.elements)) }
        return copy
    }

    func elementTooltipContext<Content: View>(
        @ViewBuilder _ content: @escaping (ChartElementTooltipContext) -> Content
    ) -> Self {
        var copy = self
        copy.elementTooltipContent = { AnyView(content($0)) }
        return copy
    }

    func onStackedBarSelection(
        _ handler: @escaping ([StackedBarSelection]) -> Void
    ) -> Self {
        onSelection { selection in
            handler(selection.stackedBarSelections)
        }
    }

    func onEmptyTap(
        _ handler: @escaping (CGPoint) -> Void
    ) -> Self {
        var copy = self
        copy.onEmptyTap = handler
        return copy
    }

    func emptyState(
        @ViewBuilder _ content: @escaping () -> some View
    ) -> Self {
        var copy = self
        copy.emptyState = { AnyView(content()) }
        return copy
    }

    func diagnostics(
        onChange: @escaping ([ChartDiagnostic]) -> Void
    ) -> Self {
        var copy = self
        copy.diagnosticsHandler = onChange
        return copy
    }
}
