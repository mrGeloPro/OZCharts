//
//  BarSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct BarLayout {
    let rect: CGRect
}

public struct BarSeries<P: ChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id = UUID()
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle
    public var label: String?

    public var color: Color
    public var barWidth: CGFloat
    public var cornerRadius: CGFloat
    public var baseline: Double

    public init(
        data: [P],
        color: Color = .blue,
        label: String? = nil,
        barWidth: CGFloat = 14,
        cornerRadius: CGFloat = 3,
        baseline: Double = 0,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.data = data
        self.color = color
        self.label = label
        self.barWidth = barWidth
        self.cornerRadius = cornerRadius
        self.baseline = baseline
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: color, symbol: .square)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        for layout in barLayouts(contexts: contexts) {
            let path = Path(roundedRect: layout.rect, cornerRadius: cornerRadius)
            context.fill(path, with: .color(color))
        }
    }

    func barLayouts(contexts: [ChartPointContext<P>]) -> [BarLayout] {
        contexts.compactMap { context in
            let baselineY = context.scaleY(baseline)
            let valueY = context.position.y
            guard baselineY.isFinite, valueY.isFinite else { return nil }

            let top = min(baselineY, valueY)
            let height = abs(baselineY - valueY)
            guard height > 0 else { return nil }

            return BarLayout(
                rect: CGRect(
                    x: context.position.x - barWidth / 2,
                    y: top,
                    width: barWidth,
                    height: height
                )
            )
        }
    }
}
