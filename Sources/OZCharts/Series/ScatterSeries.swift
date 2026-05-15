//
//  ScatterSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ScatterSeries

public struct ScatterSeries<P: ChartDataPoint>: ChartSeriesProtocol
    where P.XValue == Double, P.YValue == Double {
    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle
    public var usesAnimatableOverlay: Bool {
        true
    }

    public var label: String?

    public var color: Color
    public var pointSize: CGFloat
    public var symbol: ChartSymbolShape
    public var strokeColor: Color?
    public var strokeWidth: CGFloat

    public init(
        data: [P],
        id: UUID = UUID(),
        color: Color = .purple,
        label: String? = nil,
        pointSize: CGFloat = 8,
        symbol: ChartSymbolShape = .circle,
        strokeColor: Color? = Color.black.opacity(0.3),
        strokeWidth: CGFloat = 1,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.id = id
        self.data = data
        self.label = label
        self.color = color
        self.pointSize = pointSize
        self.symbol = symbol
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: color, symbol: .circle)
        }
    }

    public var layoutSignature: ChartSeriesSignature {
        ChartSeriesSignature(
            kind: String(reflecting: Self.self),
            values: [
                Double(pointSize),
                Double(strokeWidth)
            ],
            tokens: [
                "symbol:\(symbol)",
                "hasStroke:\(strokeColor != nil)",
                "animation:\(animation.kind)"
            ]
        )
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size _: CGSize
    ) {
        for ctx in contexts {
            let rect = CGRect(
                x: ctx.position.x - pointSize / 2,
                y: ctx.position.y - pointSize / 2,
                width: pointSize, height: pointSize
            )
            let path = symbol.path(in: rect)
            context.fill(path, with: .color(color))
            if let sc = strokeColor {
                context.stroke(path, with: .color(sc), lineWidth: strokeWidth)
            }
        }
    }

    public func animatableView(oldContexts: [ChartPointContext<P>], newContexts: [ChartPointContext<P>], progress: CGFloat) -> AnyView {
        if animation.kind == .none { return AnyView(EmptyView()) }
        return AnyView(
            AnimatableChartLayer(
                oldPoints: oldContexts.map(\.position),
                newPoints: newContexts.map(\.position),
                progress: progress,
                animationStyle: animation,
                lineColor: color,
                lineWidth: pointSize,
                drawLine: false,
                drawDots: true
            )
        )
    }
}

// MARK: - Dummy Animations for Static Series

public extension StackedBarSeries {
    func animatableView(oldContexts _: [ChartPointContext<P>], newContexts _: [ChartPointContext<P>], progress _: CGFloat) -> AnyView {
        AnyView(EmptyView())
    }
}

public extension BarSeries {
    func animatableView(oldContexts _: [ChartPointContext<P>], newContexts _: [ChartPointContext<P>], progress _: CGFloat) -> AnyView {
        AnyView(EmptyView())
    }
}

public extension ViolinSeries {
    func animatableView(oldContexts _: [ChartPointContext<P>], newContexts _: [ChartPointContext<P>], progress _: CGFloat) -> AnyView {
        AnyView(EmptyView())
    }
}

public extension DonutSeries {
    func animatableView(oldContexts _: [ChartPointContext<P>], newContexts _: [ChartPointContext<P>], progress _: CGFloat) -> AnyView {
        AnyView(EmptyView())
    }
}
