//
//  CartesianChartView+Layout.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension CartesianChartView {
    @ViewBuilder
    var legendView: some View {
        let items = series.flatMap(\.legendItems)
        if !items.isEmpty {
            if let customLegendContent {
                customLegendContent(items)
            } else {
                ChartLegendView(items: items, options: legendOptions)
            }
        }
    }

    @ViewBuilder
    func chartWithLegend(layoutInsets: ChartInsets) -> some View {
        switch legendPosition {
        case .hidden:
            chartContent(layoutInsets: layoutInsets)

        case .top:
            VStack(alignment: .leading, spacing: legendSpacing) {
                legendView
                chartContent(layoutInsets: layoutInsets)
            }

        case .bottom:
            VStack(alignment: .leading, spacing: legendSpacing) {
                chartContent(layoutInsets: layoutInsets)
                legendView
            }

        case .leading:
            HStack(alignment: .top, spacing: legendSpacing) {
                legendView
                chartContent(layoutInsets: layoutInsets)
            }

        case .trailing:
            HStack(alignment: .top, spacing: legendSpacing) {
                chartContent(layoutInsets: layoutInsets)
                legendView
            }
        }
    }

    func chartContent(layoutInsets: ChartInsets) -> some View {
        let resolvedLayoutInsets = layoutInsets.adding(plotInsets)
        let tooltipOverflowAllowance = ChartTooltipOverflowAllowance(
            leading: measuredYAxisWidth(position: .leading),
            trailing: measuredYAxisWidth(position: .trailing)
        )

        return HStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(yAxes.indices, id: \.self) { i in
                    if yAxes[i].position == .leading {
                        YAxisView(scale: store.activeYScale, config: yAxes[i])
                            .frame(width: measuredWidth(for: yAxes[i]))
                    }
                }
            }
            .padding(.top, resolvedLayoutInsets.top)
            .padding(.bottom, resolvedLayoutInsets.bottom)

            VStack(spacing: 0) {
                ForEach(xAxes.indices, id: \.self) { i in
                    if xAxes[i].position == .top {
                        XAxisView(scale: store.activeXScale, config: xAxes[i])
                            .padding(.leading, plotInsets.leading)
                            .padding(.trailing, plotInsets.trailing)
                            .frame(height: measuredHeight(for: xAxes[i]))
                    }
                }

                GeometryReader { geometry in
                    let plotSize = resolvedPlotSize(in: geometry.size)
                    ZStack {
                        chartCanvasView
                        chartGestureHandler
                        customViewAnnotationLayer(in: plotSize)
                        annotationTooltipLayer(in: plotSize)
                        elementTooltipLayer(in: plotSize, overflowAllowance: tooltipOverflowAllowance)
                        zoomControlsLayer
                    }
                    .frame(width: plotSize.width, height: plotSize.height)
                    .padding(plotInsets.edgeInsets)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .onAppear {
                        syncBaseScales()
                        store.canvasSize = plotSize
                        publishDiagnostics(plotAreaSize: plotSize, layoutInsets: resolvedLayoutInsets)
                        restoreBoundViewportOrInitialize()
                        publishViewportState()
                        handledSeriesChangeSignature = seriesChangeSignature
                        store.queueUpdate(
                            series: series,
                            in: plotSize,
                            animate: false,
                            coalesce: false
                        )
                        applyBoundSelectionState(boundSelectionState)
                    }
                    .onChange(of: geometry.size) { newSize in
                        let newPlotSize = resolvedPlotSize(in: newSize)
                        store.canvasSize = newPlotSize
                        publishDiagnostics(plotAreaSize: newPlotSize, layoutInsets: resolvedLayoutInsets)
                        store.queueUpdate(
                            series: series,
                            in: newPlotSize,
                            animate: false,
                            coalesce: false
                        )
                        applyBoundSelectionState(boundSelectionState)
                    }
                    .onChange(of: plotInsets) { _ in
                        let newPlotSize = resolvedPlotSize(in: geometry.size)
                        store.canvasSize = newPlotSize
                        publishDiagnostics(plotAreaSize: newPlotSize, layoutInsets: resolvedLayoutInsets)
                        store.queueUpdate(
                            series: series,
                            in: newPlotSize,
                            animate: false,
                            coalesce: false
                        )
                        applyBoundSelectionState(boundSelectionState)
                    }
                }

                ForEach(xAxes.indices, id: \.self) { i in
                    if xAxes[i].position == .bottom {
                        XAxisView(scale: store.activeXScale, config: xAxes[i])
                            .padding(.leading, plotInsets.leading)
                            .padding(.trailing, plotInsets.trailing)
                            .frame(height: measuredHeight(for: xAxes[i]))
                    }
                }
            }
            .zIndex(1)

            HStack(spacing: 0) {
                ForEach(yAxes.indices, id: \.self) { i in
                    if yAxes[i].position == .trailing {
                        YAxisView(scale: store.activeYScale, config: yAxes[i])
                            .frame(width: measuredWidth(for: yAxes[i]))
                    }
                }
            }
            .padding(.top, resolvedLayoutInsets.top)
            .padding(.bottom, resolvedLayoutInsets.bottom)
        }
        .overlay(alignment: .topLeading) {
            ChartAxisMarkerOverlay(
                markers: axisMarkers,
                xScale: store.activeXScale,
                yScale: store.activeYScale,
                plotOrigin: CGPoint(
                    x: resolvedLayoutInsets.leading,
                    y: resolvedLayoutInsets.top
                ),
                plotSize: store.canvasSize,
                markerSizes: $axisMarkerSizes,
                compactMarkerSizes: $axisMarkerCompactSizes,
                selectionOptions: axisMarkerSelectionOptions,
                selectedIDs: Set(highlightedAxisMarkers.map(\.id)),
                onMarkerTap: handleAxisMarkerTap
            )
            .allowsHitTesting(axisMarkerSelectionOptions.isEnabled)
        }
        .padding(contentInsets.edgeInsets)
    }

    var chartCanvasView: some View {
        ChartCanvasView(
            series: series.sorted { $0.zIndex < $1.zIndex },
            seriesContexts: store.seriesContexts,
            renderSeriesContexts: store.renderSeriesContexts,
            oldSeriesContexts: store.oldSeriesContexts,
            oldRenderSeriesContexts: store.oldRenderSeriesContexts,
            animationProgress: store.animationProgress,
            animationPhase: store.animationPhase,
            isAnimationActive: store.isAnimationActive,
            animationStyle: series.first?.animation ?? .none,
            activeXScale: store.activeXScale,
            activeYScale: store.activeYScale,
            xAxes: xAxes,
            yAxes: yAxes,
            canvasRenderOrder: canvasRenderOrder,
            xRangeAnnotations: xRangeAnnotations,
            xyRangeAnnotations: xyRangeAnnotations,
            rangeAnnotations: rangeAnnotations,
            verticalAnnotations: verticalAnnotations,
            horizontalAnnotations: horizontalAnnotations,
            visiblePointAnnotations: visiblePointAnnotations,
            violinBackgrounds: store.violinBackgrounds,
            violinColorMapper: nil,
            highlightedPoints: store.highlightedPoints,
            selectedElementContexts: store.selectedElementContexts,
            selectedElementStyle: selectedElementStyle,
            plotBorderStyle: plotBorderStyle,
            crosshairStyle: crosshairStyle,
            tooltipPlacement: tooltipPlacement,
            tooltipAnchorPoint: resolvedTooltipAnchorPoint,
            tooltipOffset: tooltipOffset,
            tooltipPadding: tooltipPadding,
            tooltipMaxWidth: tooltipMaxWidth,
            tooltipContent: tooltipContent
        )
    }

    var chartGestureHandler: some View {
        ChartGestureHandler(
            config: ChartGestureConfig(
                isHorizontalScrollEnabled: isHorizontalScrollEnabled,
                isVerticalScrollEnabled: isVerticalScrollEnabled,
                isHorizontalZoomEnabled: isHorizontalZoomEnabled,
                isVerticalZoomEnabled: isVerticalZoomEnabled,
                hitboxRadius: hitboxRadius,
                selectionBehavior: selectionBehavior,
                selectionDismissalPolicy: selectionDismissalPolicy,
                selectionActivation: selectionActivation
            ),
            onEvent: { handleGestureEvent($0) }
        )
    }

    @ViewBuilder
    func customViewAnnotationLayer(in canvasSize: CGSize) -> some View {
        let resolvedAnnotations = resolvedCustomViewAnnotations(in: canvasSize)
        ForEach(visibleCustomViewAnnotations) { annotation in
            if let resolved = resolvedAnnotations[annotation.id], resolved.isVisible {
                annotation.content
                    .fixedSize()
                    .readSize { customAnnotationSizes[annotation.id] = $0 }
                    .position(resolved.position)
            } else {
                annotation.content
                    .fixedSize()
                    .hidden()
                    .readSize { customAnnotationSizes[annotation.id] = $0 }
            }
        }
    }

    @ViewBuilder
    func annotationTooltipLayer(in canvasSize: CGSize) -> some View {
        if !highlightedAnnotations.isEmpty {
            ChartAnnotationTooltipOverlay(
                annotations: highlightedAnnotations,
                canvasSize: canvasSize,
                placement: tooltipPlacement,
                anchorOverride: resolvedAnnotationTooltipAnchorPoint,
                offset: tooltipOffset,
                padding: tooltipPadding,
                maxWidth: tooltipMaxWidth,
                content: annotationTooltipContent,
                onDiagnosticsChanged: publishTooltipDiagnostics
            )
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    func elementTooltipLayer(
        in canvasSize: CGSize,
        overflowAllowance: ChartTooltipOverflowAllowance
    ) -> some View {
        if !store.selectedElements.isEmpty {
            ChartElementTooltipOverlay(
                elements: store.selectedElements,
                canvasSize: canvasSize,
                placement: tooltipPlacement,
                anchorOverride: resolvedTooltipAnchorPoint,
                offset: tooltipOffset,
                padding: tooltipPadding,
                maxWidth: tooltipMaxWidth,
                overflowAllowance: overflowAllowance,
                content: elementTooltipContent,
                onDiagnosticsChanged: publishTooltipDiagnostics
            )
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    var zoomControlsLayer: some View {
        if showsZoomControls {
            ChartViewportControls(
                onZoomIn: { applyProgrammaticZoom(magnification: zoomControlStep) },
                onZoomOut: { applyProgrammaticZoom(magnification: 1 / zoomControlStep) },
                onReset: { resetViewportFromControls() }
            )
            .padding(8)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topTrailing
            )
        }
    }

    func measuredHeight(for axis: XAxisConfig) -> CGFloat {
        ChartLayoutEngine.measuredHeight(for: axis, labelSampleLimit: 12)
    }

    func measuredWidth(for axis: YAxisConfig) -> CGFloat {
        ChartLayoutEngine.measuredWidth(for: axis, labelSampleLimit: 12)
    }

    func measuredYAxisWidth(position: YAxisPosition) -> CGFloat {
        yAxes
            .filter { $0.position == position }
            .map { measuredWidth(for: $0) }
            .reduce(0, +)
    }

    func resolvedPlotSize(in availableSize: CGSize) -> CGSize {
        ChartPlotSizing.plotSize(in: availableSize, plotInsets: plotInsets)
    }

    func totalCanvasSize(
        plotAreaSize: CGSize?,
        layoutInsets: ChartInsets?
    ) -> CGSize? {
        ChartPlotSizing.totalCanvasSize(
            plotAreaSize: plotAreaSize,
            layoutInsets: layoutInsets
        )
    }
}
