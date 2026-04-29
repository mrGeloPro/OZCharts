//
//  DonutSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct DonutSeries<P: ChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id = UUID()
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle
    public var label: String?

    public var colors: [Color]
    public var thickness: CGFloat
    public var gapAngle: Angle
    public var startAngle: Angle
    public var lineCap: CGLineCap

    public init(
        data: [P],
        colors: [Color],
        label: String?                    = nil,
        thickness: CGFloat             = 40,
        gapAngle: Angle                = .degrees(6),
        startAngle: Angle              = .degrees(-90),
        lineCap: CGLineCap             = .butt,
        animation: ChartAnimationStyle = .none,
        zIndex: Int                    = 0
    ) {
        self.data       = data
        self.label      = label
        self.colors     = colors
        self.thickness  = thickness
        self.gapAngle   = gapAngle
        self.startAngle = startAngle
        self.lineCap    = lineCap
        self.animation  = animation
        self.zIndex     = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: colors.first ?? .gray, symbol: .circle)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        let values = data.map { $0.y }
        let total  = values.reduce(0, +)
        guard total > 0 else { return }

        let center  = CGPoint(x: size.width / 2, y: size.height / 2)
        let outerR  = min(size.width, size.height) / 2 - 2
        let radius  = outerR - thickness / 2

        let totalGapRad = gapAngle.radians * Double(values.count)
        let available   = 2 * Double.pi - totalGapRad
        guard available > 0 else { return }

        var currentRad = startAngle.radians

        for (index, value) in values.enumerated() {
            let delta = (value / total) * available
            let segmentStart = currentRad + gapAngle.radians / 2
            let segmentEnd   = segmentStart + delta

            var path = Path()
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .radians(segmentStart),
                endAngle:   .radians(segmentEnd),
                clockwise: false
            )

            let color = colors[safe: index] ?? .gray
            context.stroke(
                path,
                with: .color(color),
                style: StrokeStyle(lineWidth: thickness, lineCap: lineCap)
            )

            currentRad += delta + gapAngle.radians
        }
    }
}
