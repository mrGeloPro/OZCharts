//
//  OZChart+Tooltip.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension OZChart {
    func tooltip<Content: View>(
        @ViewBuilder _ content: @escaping ([ChartPointContext<Point>]) -> Content
    ) -> OZChart<Point, Content> {
        var copy = OZChart<Point, Content>(
            sourceData,
            xDomain: xDomain,
            yDomain: yDomain,
            theme: theme,
            tooltip: content
        )
        copy.series = series
        copy.xAxes = xAxes
        copy.yAxes = yAxes
        copy.xRangeAnnotations = xRangeAnnotations
        copy.xyRangeAnnotations = xyRangeAnnotations
        copy.rangeAnnotations = rangeAnnotations
        copy.verticalAnnotations = verticalAnnotations
        copy.horizontalAnnotations = horizontalAnnotations
        copy.pointAnnotations = pointAnnotations
        copy.eventMarkers = eventMarkers
        copy.customViewAnnotations = customViewAnnotations
        copy.axisMarkers = axisMarkers
        copy.axisMarkerSelectionOptions = axisMarkerSelectionOptions
        copy.interactionOptions = interactionOptions
        copy.selectionOptions = selectionOptions
        copy.selectionPriority = selectionPriority
        copy.isAnnotationSelectionEnabled = isAnnotationSelectionEnabled
        copy.annotationHitboxRadius = annotationHitboxRadius
        copy.annotationOverlappingSelectionMode = annotationOverlappingSelectionMode
        copy.annotationFallbackToPointSelection = annotationFallbackToPointSelection
        copy.tooltipOptions = tooltipOptions
        copy.viewportOptions = viewportOptions
        copy.renderOptions = renderOptions
        copy.contentInsets = contentInsets
        copy.plotInsets = plotInsets
        copy.emptyState = emptyState
        copy.diagnosticsHandler = diagnosticsHandler
        copy.onSelectionChanged = onSelectionChanged
        copy.onElementSelectionChanged = onElementSelectionChanged
        copy.onChartSelectionChanged = onChartSelectionChanged
        copy.elementTooltipContent = elementTooltipContent
        copy.onAnnotationSelectionChanged = onAnnotationSelectionChanged
        copy.onAxisMarkerSelectionChanged = onAxisMarkerSelectionChanged
        copy.onEmptyTap = onEmptyTap
        copy.viewportBinding = viewportBinding
        copy.selectionStateBinding = selectionStateBinding
        return copy
    }
}

public extension OZChart where TooltipContent == EmptyView {
    init(
        _ data: [Point],
        xDomain: ChartDomain = .auto(),
        yDomain: ChartDomain = .auto(padding: 0.12),
        theme: ChartTheme = .default
    ) {
        self.init(
            data,
            xDomain: xDomain,
            yDomain: yDomain,
            theme: theme
        ) { _ in
            EmptyView()
        }
    }
}
