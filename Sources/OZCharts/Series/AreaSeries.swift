//
//  AreaSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct AreaSeries<P: ChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id = UUID()
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle
    public var usesAnimatableOverlay: Bool { true }
    public var label: String?

    public var color: Color
    public var fillColor: Color
    public var fillOpacity: Double
    public var baseline: Double?
    public var lineWidth: CGFloat
    public var interpolation: LineInterpolation
    public var downsampling: ChartDownsampling

    public init(
        data: [P],
        color: Color,
        fillColor: Color? = nil,
        fillOpacity: Double = 0.22,
        baseline: Double? = nil,
        label: String? = nil,
        lineWidth: CGFloat = 2,
        interpolation: LineInterpolation = .linear,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.data = data
        self.color = color
        self.fillColor = fillColor ?? color
        self.fillOpacity = fillOpacity
        self.baseline = baseline
        self.label = label
        self.lineWidth = lineWidth
        self.interpolation = interpolation
        self.downsampling = downsampling
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: fillColor, symbol: .square)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        lineSeries.render(into: &context, contexts: contexts, size: size)
    }

    public func animatableView(
        oldContexts: [ChartPointContext<P>],
        newContexts: [ChartPointContext<P>],
        progress: CGFloat
    ) -> AnyView {
        lineSeries.animatableView(
            oldContexts: oldContexts,
            newContexts: newContexts,
            progress: progress
        )
    }

    private var lineSeries: LineSeries<P> {
        LineSeries(
            data: data,
            color: color,
            lineWidth: lineWidth,
            interpolation: interpolation,
            area: AreaStyle(
                fillColor: fillColor,
                fillOpacity: fillOpacity,
                baseline: baseline
            ),
            downsampling: downsampling,
            animation: animation,
            zIndex: zIndex
        )
    }
}
