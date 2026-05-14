//
//  CartesianChartView+Convenience.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension CartesianChartView where XScale == LinearScale, YScale == LinearScale {
    init(
        series: [AnyChartSeries<Point>],
        xDomain: ChartDomain = .auto(),
        yDomain: ChartDomain = .auto(padding: 0.12),
        theme: ChartTheme = .default,
        xAxes: [XAxisConfig]? = nil,
        yAxes: [YAxisConfig]? = nil,
        rangeAnnotations: [RangeAnnotation] = [],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Double, Double>] = [],
        eventMarkers: [ChartEventMarker] = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        initialViewport: ChartInitialViewport? = nil,
        viewport: Binding<ChartViewportState>? = nil,
        selectionState: Binding<ChartSelectionState>? = nil,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior = .tap,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        clearsSelectionOnGestureEnd: Bool = true,
        crosshairStyle: ChartCrosshairStyle = .hidden,
        tooltipPlacement: ChartTooltipPlacement = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)? = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) {
        let resolvedDomains = resolveChartDomains(
            series: series,
            xDomain: xDomain,
            yDomain: yDomain,
            rangeAnnotations: rangeAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations + eventMarkers.map(\.pointAnnotation),
            customViewAnnotations: customViewAnnotations
        )

        self.init(
            series: series,
            xScale: LinearScale(domain: resolvedDomains.x),
            yScale: LinearScale(domain: resolvedDomains.y),
            xAxes: xAxes ?? [theme.xAxis()],
            yAxes: yAxes ?? [theme.yAxis()],
            rangeAnnotations: rangeAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            initialViewport: initialViewport,
            viewport: viewport,
            selectionState: selectionState,
            selectionMode: selectionMode,
            selectionBehavior: selectionBehavior,
            overlappingSelectionMode: overlappingSelectionMode,
            clearsSelectionOnGestureEnd: clearsSelectionOnGestureEnd,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            canvasRenderOrder: canvasRenderOrder,
            emptyState: emptyState,
            tooltipContent: tooltipContent
        )
    }

    init<S: ChartSeriesProtocol>(
        series: [S],
        xDomain: ChartDomain = .auto(),
        yDomain: ChartDomain = .auto(padding: 0.12),
        theme: ChartTheme = .default,
        xAxes: [XAxisConfig]? = nil,
        yAxes: [YAxisConfig]? = nil,
        rangeAnnotations: [RangeAnnotation] = [],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Double, Double>] = [],
        eventMarkers: [ChartEventMarker] = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        initialViewport: ChartInitialViewport? = nil,
        viewport: Binding<ChartViewportState>? = nil,
        selectionState: Binding<ChartSelectionState>? = nil,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior = .tap,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        clearsSelectionOnGestureEnd: Bool = true,
        crosshairStyle: ChartCrosshairStyle = .hidden,
        tooltipPlacement: ChartTooltipPlacement = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)? = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) where S.Point == Point {
        self.init(
            series: series.map(AnyChartSeries.init),
            xDomain: xDomain,
            yDomain: yDomain,
            theme: theme,
            xAxes: xAxes,
            yAxes: yAxes,
            rangeAnnotations: rangeAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            initialViewport: initialViewport,
            viewport: viewport,
            selectionState: selectionState,
            selectionMode: selectionMode,
            selectionBehavior: selectionBehavior,
            overlappingSelectionMode: overlappingSelectionMode,
            clearsSelectionOnGestureEnd: clearsSelectionOnGestureEnd,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            canvasRenderOrder: canvasRenderOrder,
            emptyState: emptyState,
            tooltipContent: tooltipContent
        )
    }
}

private func resolveChartDomains<Point: ChartDataPoint>(
    series: [AnyChartSeries<Point>],
    xDomain: ChartDomain,
    yDomain: ChartDomain,
    rangeAnnotations: [RangeAnnotation],
    horizontalAnnotations: [HorizontalAnnotation],
    pointAnnotations: [PointAnnotation<Double, Double>],
    customViewAnnotations: [CustomViewAnnotation<Double, Double>]
) -> (x: ClosedRange<Double>, y: ClosedRange<Double>)
where Point.XValue == Double, Point.YValue == Double {
    let data = series.flatMap(\.data)

    let xValues = data.map(\.x) +
        pointAnnotations.map(\.x) +
        customViewAnnotations.map(\.x)

    let yValues = data.map(\.y) +
        rangeAnnotations.flatMap { [$0.yRange.lowerBound, $0.yRange.upperBound] } +
        horizontalAnnotations.map(\.yValue) +
        pointAnnotations.map(\.y) +
        customViewAnnotations.map(\.y)

    return (
        x: xDomain.resolve(values: xValues),
        y: yDomain.resolve(values: yValues)
    )
}
