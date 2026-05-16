//
//  OZDonutChart.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct OZDonutChart<Point: ChartDataPoint, CenterContent: View>: View
    where Point.XValue == Double, Point.YValue == Double {
    private var data: [Point]
    private var id: UUID
    private var colors: [Color]
    private var segmentStyles: [DonutSegmentStyle]
    private var label: String?
    private var segmentLabelMapper: ((Point) -> String?)?
    private var thickness: CGFloat
    private var gapAngle: Angle
    private var startAngle: Angle
    private var lineCap: CGLineCap
    private var animation: ChartAnimationStyle
    private var theme: ChartTheme
    private var renderOptions: ChartRenderOptions
    private var selectionOptions: ChartSelectionOptions
    private var selectedElementHandler: ([ChartSelectedElement]) -> Void
    private var chartSelectionHandler: (ChartSelection<Point>) -> Void
    private var centerContent: () -> CenterContent

    public init(
        _ data: [Point],
        id: UUID? = nil,
        colors: [Color],
        segmentStyles: [DonutSegmentStyle] = [],
        label: String? = nil,
        segmentLabelMapper: ((Point) -> String?)? = nil,
        thickness: CGFloat = 40,
        gapAngle: Angle = .degrees(6),
        startAngle: Angle = .degrees(-90),
        lineCap: CGLineCap = .butt,
        animation: ChartAnimationStyle = .none,
        theme: ChartTheme = .dashboard,
        @ViewBuilder center: @escaping () -> CenterContent
    ) {
        self.data = data
        self.id = id ?? UUID()
        self.colors = colors
        self.segmentStyles = segmentStyles
        self.label = label
        self.segmentLabelMapper = segmentLabelMapper
        self.thickness = thickness
        self.gapAngle = gapAngle
        self.startAngle = startAngle
        self.lineCap = lineCap
        self.animation = animation
        self.theme = theme
        self.renderOptions = .dashboard(legend: label == nil ? .hidden : .bottom)
        self.selectionOptions = .disabled
        self.selectedElementHandler = { _ in }
        self.chartSelectionHandler = { _ in }
        self.centerContent = center
    }

    public var body: some View {
        ZStack {
            CartesianChartView(
                series: [
                    DonutSeries(
                        data: data,
                        id: id,
                        colors: colors,
                        segmentStyles: segmentStyles,
                        label: label,
                        segmentLabelMapper: segmentLabelMapper,
                        thickness: thickness,
                        gapAngle: gapAngle,
                        startAngle: startAngle,
                        lineCap: lineCap,
                        animation: animation
                    )
                ],
                xDomain: .fixed(0...1),
                yDomain: .fixed(0...1),
                theme: theme,
                xAxes: [.hidden()],
                yAxes: [.hidden()],
                selectionMode: selectionOptions.mode,
                selectionBehavior: selectionOptions.behavior,
                overlappingSelectionMode: selectionOptions.overlappingSelectionMode,
                clearsSelectionOnGestureEnd: selectionOptions.clearsSelectionOnGestureEnd,
                onElementSelectionChanged: selectedElementHandler
            ) { _ in
                EmptyView()
            }
            .chartInteractionOptions(.static)
            .chartSelectionOptions(selectionOptions)
            .chartSelectionChanged(chartSelectionHandler)
            .chartRenderOptions(renderOptions)

            centerContent()
                .allowsHitTesting(false)
        }
    }

    public func legend(
        _ position: ChartLegendPosition = .bottom,
        spacing: CGFloat = 12
    ) -> Self {
        legend(ChartLegendOptions(position: position, itemSpacing: spacing))
    }

    public func legend(_ options: ChartLegendOptions) -> Self {
        var copy = self
        copy.renderOptions.legendOptions = options
        return copy
    }

    public func selection(_ options: ChartSelectionOptions = .elementTap) -> Self {
        var copy = self
        copy.selectionOptions = options
        return copy
    }

    @available(*, deprecated, message: "Use selection(_:) to configure behavior and onSelection(_:) to read selection.elements instead.")
    public func selection(
        _ options: ChartSelectionOptions = .elementTap,
        onChange: @escaping ([ChartSelectedElement]) -> Void
    ) -> Self {
        var copy = self
        copy.selectionOptions = options
        copy.selectedElementHandler = onChange
        return copy
    }

    public func onSelection(
        _ onChange: @escaping (ChartSelection<Point>) -> Void
    ) -> Self {
        var copy = self
        copy.chartSelectionHandler = onChange
        return copy
    }

    public func rendering(_ options: ChartRenderOptions) -> Self {
        var copy = self
        copy.renderOptions = options
        return copy
    }

    public func selectedElementStyle(_ style: ChartSelectedElementStyle) -> Self {
        var copy = self
        copy.renderOptions.selectedElementStyle = style
        return copy
    }

    public func center<Content: View>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> OZDonutChart<Point, Content> {
        var copy = OZDonutChart<Point, Content>(
            data,
            id: id,
            colors: colors,
            segmentStyles: segmentStyles,
            label: label,
            segmentLabelMapper: segmentLabelMapper,
            thickness: thickness,
            gapAngle: gapAngle,
            startAngle: startAngle,
            lineCap: lineCap,
            animation: animation,
            theme: theme,
            center: content
        )
        copy.renderOptions = renderOptions
        copy.selectionOptions = selectionOptions
        copy.selectedElementHandler = selectedElementHandler
        copy.chartSelectionHandler = chartSelectionHandler
        return copy
    }
}

public extension OZDonutChart where CenterContent == EmptyView {
    init(
        _ data: [Point],
        id: UUID? = nil,
        colors: [Color],
        segmentStyles: [DonutSegmentStyle] = [],
        label: String? = nil,
        segmentLabelMapper: ((Point) -> String?)? = nil,
        thickness: CGFloat = 40,
        gapAngle: Angle = .degrees(6),
        startAngle: Angle = .degrees(-90),
        lineCap: CGLineCap = .butt,
        animation: ChartAnimationStyle = .none,
        theme: ChartTheme = .dashboard
    ) {
        self.init(
            data,
            id: id,
            colors: colors,
            segmentStyles: segmentStyles,
            label: label,
            segmentLabelMapper: segmentLabelMapper,
            thickness: thickness,
            gapAngle: gapAngle,
            startAngle: startAngle,
            lineCap: lineCap,
            animation: animation,
            theme: theme
        ) {
            EmptyView()
        }
    }
}
