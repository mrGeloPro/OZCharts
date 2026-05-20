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
        xRangeAnnotations: [XRangeAnnotation] = [],
        xyRangeAnnotations: [XYRangeAnnotation] = [],
        rangeAnnotations: [RangeAnnotation] = [],
        verticalAnnotations: [VerticalAnnotation] = [],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Double, Double>] = [],
        eventMarkers: [ChartEventMarker] = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        axisMarkers: [ChartAxisMarker] = [],
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        liveTrackingMode: ChartLiveTrackingMode? = nil,
        initialViewport: ChartInitialViewport? = nil,
        viewport: Binding<ChartViewportState>? = nil,
        selectionState: Binding<ChartSelectionState>? = nil,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior = .tap,
        selectionActivation: ChartSelectionActivation = .immediate,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient,
        crosshairStyle: ChartCrosshairStyle = .hidden,
        tooltipPlacement: ChartTooltipPlacement = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        onChartSelectionChanged: @escaping (ChartSelection<Point>) -> Void = { _ in },
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart],
        emptyState: (() -> AnyView)? = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) {
        let resolvedDomains = resolveChartDomains(
            series: series,
            xDomain: xDomain,
            yDomain: yDomain,
            xRangeAnnotations: xRangeAnnotations,
            xyRangeAnnotations: xyRangeAnnotations,
            rangeAnnotations: rangeAnnotations,
            verticalAnnotations: verticalAnnotations,
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
            xRangeAnnotations: xRangeAnnotations,
            xyRangeAnnotations: xyRangeAnnotations,
            rangeAnnotations: rangeAnnotations,
            verticalAnnotations: verticalAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            axisMarkers: axisMarkers,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            liveTrackingMode: liveTrackingMode,
            initialViewport: initialViewport,
            viewport: viewport,
            selectionState: selectionState,
            selectionMode: selectionMode,
            selectionBehavior: selectionBehavior,
            selectionActivation: selectionActivation,
            nearestSelectionPolicy: nearestSelectionPolicy,
            overlappingSelectionMode: overlappingSelectionMode,
            selectionDismissalPolicy: selectionDismissalPolicy,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            onChartSelectionChanged: onChartSelectionChanged,
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
        xRangeAnnotations: [XRangeAnnotation] = [],
        xyRangeAnnotations: [XYRangeAnnotation] = [],
        rangeAnnotations: [RangeAnnotation] = [],
        verticalAnnotations: [VerticalAnnotation] = [],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Double, Double>] = [],
        eventMarkers: [ChartEventMarker] = [],
        customViewAnnotations: [CustomViewAnnotation<Double, Double>] = [],
        axisMarkers: [ChartAxisMarker] = [],
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        liveTrackingMode: ChartLiveTrackingMode? = nil,
        initialViewport: ChartInitialViewport? = nil,
        viewport: Binding<ChartViewportState>? = nil,
        selectionState: Binding<ChartSelectionState>? = nil,
        selectionMode: ChartSelectionMode = .pointsInRadius,
        selectionBehavior: ChartSelectionBehavior = .tap,
        selectionActivation: ChartSelectionActivation = .immediate,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient,
        crosshairStyle: ChartCrosshairStyle = .hidden,
        tooltipPlacement: ChartTooltipPlacement = .automatic,
        onSelectionChanged: @escaping ([ChartPointContext<Point>]) -> Void = { _ in },
        onElementSelectionChanged: @escaping ([ChartSelectedElement]) -> Void = { _ in },
        onChartSelectionChanged: @escaping (ChartSelection<Point>) -> Void = { _ in },
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
            xRangeAnnotations: xRangeAnnotations,
            xyRangeAnnotations: xyRangeAnnotations,
            rangeAnnotations: rangeAnnotations,
            verticalAnnotations: verticalAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            eventMarkers: eventMarkers,
            customViewAnnotations: customViewAnnotations,
            axisMarkers: axisMarkers,
            isHorizontalScrollEnabled: isHorizontalScrollEnabled,
            isHorizontalZoomEnabled: isHorizontalZoomEnabled,
            isVerticalScrollEnabled: isVerticalScrollEnabled,
            isVerticalZoomEnabled: isVerticalZoomEnabled,
            isLiveTrackingEnabled: isLiveTrackingEnabled,
            liveTrackingMode: liveTrackingMode,
            initialViewport: initialViewport,
            viewport: viewport,
            selectionState: selectionState,
            selectionMode: selectionMode,
            selectionBehavior: selectionBehavior,
            selectionActivation: selectionActivation,
            nearestSelectionPolicy: nearestSelectionPolicy,
            overlappingSelectionMode: overlappingSelectionMode,
            selectionDismissalPolicy: selectionDismissalPolicy,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            onSelectionChanged: onSelectionChanged,
            onElementSelectionChanged: onElementSelectionChanged,
            onChartSelectionChanged: onChartSelectionChanged,
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
    xRangeAnnotations: [XRangeAnnotation],
    xyRangeAnnotations: [XYRangeAnnotation],
    rangeAnnotations: [RangeAnnotation],
    verticalAnnotations: [VerticalAnnotation],
    horizontalAnnotations: [HorizontalAnnotation],
    pointAnnotations: [PointAnnotation<Double, Double>],
    customViewAnnotations: [CustomViewAnnotation<Double, Double>]
) -> (x: ClosedRange<Double>, y: ClosedRange<Double>)
where Point.XValue == Double, Point.YValue == Double {
    let data = series.flatMap(\.data)

    let xValues = data.map(\.x) +
        xRangeAnnotations.flatMap { [$0.xRange.lowerBound, $0.xRange.upperBound] } +
        xyRangeAnnotations.flatMap { [$0.xRange.lowerBound, $0.xRange.upperBound] } +
        verticalAnnotations.map(\.xValue) +
        pointAnnotations.map(\.x) +
        customViewAnnotations.map(\.x)

    let yValues = data.map(\.y) +
        xyRangeAnnotations.flatMap { [$0.yRange.lowerBound, $0.yRange.upperBound] } +
        rangeAnnotations.flatMap { [$0.yRange.lowerBound, $0.yRange.upperBound] } +
        horizontalAnnotations.map(\.yValue) +
        pointAnnotations.map(\.y) +
        customViewAnnotations.map(\.y)

    return (
        x: xDomain.resolve(values: xValues),
        y: yDomain.resolve(values: yValues)
    )
}
