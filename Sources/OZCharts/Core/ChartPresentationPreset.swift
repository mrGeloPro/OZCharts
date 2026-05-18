//
//  ChartPresentationPreset.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public struct ChartPresentationPreset {
    public var theme: ChartTheme?
    public var interaction: ChartInteractionOptions
    public var selection: ChartSelectionOptions
    public var tooltip: ChartTooltipOptions
    public var viewport: ChartViewportOptions
    public var rendering: ChartRenderOptions
    public var xAxes: [XAxisConfig]?
    public var yAxes: [YAxisConfig]?

    public init(
        theme: ChartTheme? = nil,
        interaction: ChartInteractionOptions = .automatic,
        selection: ChartSelectionOptions = ChartSelectionOptions(),
        tooltip: ChartTooltipOptions = .automatic,
        viewport: ChartViewportOptions = .automatic,
        rendering: ChartRenderOptions = .automatic,
        xAxes: [XAxisConfig]? = nil,
        yAxes: [YAxisConfig]? = nil
    ) {
        self.theme = theme
        self.interaction = interaction
        self.selection = selection
        self.tooltip = tooltip
        self.viewport = viewport
        self.rendering = rendering
        self.xAxes = xAxes
        self.yAxes = yAxes
    }

    public static func dashboardCompact(
        legend: ChartLegendPosition = .bottom,
        xPosition: XAxisPosition = .bottom,
        yPosition: YAxisPosition = .leading,
        xTickCount: Int = 4,
        yTickCount: Int = 4
    ) -> ChartPresentationPreset {
        ChartPresentationPreset(
            theme: .dashboard,
            interaction: .static,
            selection: .disabled,
            rendering: .dashboard(legend: legend, spacing: 10),
            xAxes: [.compact(position: xPosition, tickCount: xTickCount)],
            yAxes: [.compact(position: yPosition, tickCount: yTickCount)]
        )
    }

    public static func sparkline(
        theme: ChartTheme = .dashboard
    ) -> ChartPresentationPreset {
        ChartPresentationPreset(
            theme: theme,
            interaction: .static,
            selection: .disabled,
            rendering: ChartRenderOptions(
                legendPosition: .hidden,
                legendSpacing: 0,
                selectedElementStyle: .hidden,
                canvasRenderOrder: [.rangeAnnotations, .horizontalAnnotations, .coreChart]
            ),
            xAxes: [.hidden()],
            yAxes: [.hidden()]
        )
    }

    public static func staticReport(
        theme: ChartTheme = .default,
        legend: ChartLegendPosition = .bottom,
        xPosition: XAxisPosition = .bottom,
        yPosition: YAxisPosition = .leading,
        xTickCount: Int = 5,
        yTickCount: Int = 5
    ) -> ChartPresentationPreset {
        ChartPresentationPreset(
            theme: theme,
            interaction: .static,
            selection: .disabled,
            rendering: ChartRenderOptions(
                legendPosition: legend,
                legendSpacing: 12,
                selectedElementStyle: .hidden
            ),
            xAxes: [theme.xAxis(position: xPosition, tickCount: xTickCount)],
            yAxes: [theme.yAxis(position: yPosition, tickCount: yTickCount)]
        )
    }

    public static func interactiveExploration(
        theme: ChartTheme = .default,
        legend: ChartLegendPosition = .bottom,
        selection: ChartSelectionOptions = .nearestX,
        showsZoomControls: Bool = true
    ) -> ChartPresentationPreset {
        ChartPresentationPreset(
            theme: theme,
            interaction: .automatic,
            selection: selection,
            tooltip: .automatic,
            viewport: ChartViewportOptions(showsZoomControls: showsZoomControls),
            rendering: ChartRenderOptions(legendPosition: legend)
        )
    }

    public static func productCard(
        theme: ChartTheme = .dashboard,
        legend: ChartLegendPosition = .bottom,
        selection: ChartSelectionOptions = .scrollSafeNearestX,
        tooltip: ChartTooltipOptions = .hitPoint(
            offset: CGPoint(x: 0, y: -16),
            padding: 10,
            maxWidth: 240
        ),
        plotBorder: ChartPlotBorderStyle = .hidden
    ) -> ChartPresentationPreset {
        ChartPresentationPreset(
            theme: theme,
            interaction: .horizontal,
            selection: selection,
            tooltip: tooltip,
            viewport: ChartViewportOptions(showsZoomControls: false),
            rendering: ChartRenderOptions(
                legend: ChartLegendOptions.dashboard(position: legend),
                selectedElementStyle: .product,
                plotBorderStyle: plotBorder
            )
        )
    }

    public static func denseEventTimeline(
        theme: ChartTheme = .dashboard,
        xPosition: XAxisPosition = .top,
        yPosition: YAxisPosition = .trailing
    ) -> ChartPresentationPreset {
        ChartPresentationPreset(
            theme: theme,
            interaction: ChartInteractionOptions(
                isHorizontalScrollEnabled: true,
                isVerticalScrollEnabled: false,
                isHorizontalZoomEnabled: true,
                isVerticalZoomEnabled: false,
                minZoomScale: 0.05
            ),
            selection: .nearestX,
            tooltip: ChartTooltipOptions(
                placement: .automatic,
                offset: CGPoint(x: 0, y: -16),
                padding: 10,
                maxWidth: 240
            ),
            viewport: ChartViewportOptions(showsZoomControls: true),
            rendering: .dashboard(legend: .bottom, spacing: 10),
            xAxes: [.compact(position: xPosition, tickCount: 5)],
            yAxes: [.compact(position: yPosition, tickCount: 5)]
        )
    }
}
