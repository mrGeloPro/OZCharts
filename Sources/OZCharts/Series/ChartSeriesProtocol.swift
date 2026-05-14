//
//  ChartSeriesProtocol.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Protocol

public protocol ChartSeriesProtocol: Identifiable {
    associatedtype Point: ChartDataPoint where Point.XValue == Double, Point.YValue == Double
    var id: UUID { get }
    var data: [Point] { get }
    var zIndex: Int { get }
    var animation: ChartAnimationStyle { get }
    var usesAnimatableOverlay: Bool { get }
    var legendItem: ChartLegendItem? { get }
    var legendItems: [ChartLegendItem] { get }

    func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<Point>],
        size: CGSize
    )

    func selectionElements(
        contexts: [ChartPointContext<Point>],
        size: CGSize
    ) -> [ChartElementContext]
    
    @ViewBuilder
    func animatableView(
        oldContexts: [ChartPointContext<Point>],
        newContexts: [ChartPointContext<Point>],
        progress: CGFloat
    ) -> AnyView
}

public struct AnyChartSeries<Point: ChartDataPoint>: Identifiable
where Point.XValue == Double, Point.YValue == Double {
    public let id: UUID
    public let data: [Point]
    public let zIndex: Int
    public let animation: ChartAnimationStyle
    public let legendItem: ChartLegendItem?
    public let legendItems: [ChartLegendItem]

    private let renderBody: (inout GraphicsContext, [ChartPointContext<Point>], CGSize) -> Void
    private let selectionElementsBody: ([ChartPointContext<Point>], CGSize) -> [ChartElementContext]
    private let animatableBody: ([ChartPointContext<Point>], [ChartPointContext<Point>], CGFloat) -> AnyView
    public let usesAnimatableOverlay: Bool

    public init<S: ChartSeriesProtocol>(_ series: S) where S.Point == Point {
        self.id = series.id
        self.data = series.data
        self.zIndex = series.zIndex
        self.animation = series.animation
        self.legendItem = series.legendItem
        self.legendItems = series.legendItems
        self.usesAnimatableOverlay = series.usesAnimatableOverlay
        self.renderBody = { context, contexts, size in
            series.render(into: &context, contexts: contexts, size: size)
        }
        self.selectionElementsBody = { contexts, size in
            series.selectionElements(contexts: contexts, size: size)
        }
        self.animatableBody = { oldContexts, newContexts, progress in
            series.animatableView(
                oldContexts: oldContexts,
                newContexts: newContexts,
                progress: progress
            )
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<Point>],
        size: CGSize
    ) {
        renderBody(&context, contexts, size)
    }

    public func animatableView(
        oldContexts: [ChartPointContext<Point>],
        newContexts: [ChartPointContext<Point>],
        progress: CGFloat
    ) -> AnyView {
        animatableBody(oldContexts, newContexts, progress)
    }

    public func selectionElements(
        contexts: [ChartPointContext<Point>],
        size: CGSize
    ) -> [ChartElementContext] {
        selectionElementsBody(contexts, size)
    }
}

public extension ChartSeriesProtocol {
    var usesAnimatableOverlay: Bool { false }
    var legendItem: ChartLegendItem? { nil }
    var legendItems: [ChartLegendItem] { legendItem.map { [$0] } ?? [] }

    func selectionElements(
        contexts: [ChartPointContext<Point>],
        size: CGSize
    ) -> [ChartElementContext] {
        []
    }

    func animatableView(
        oldContexts: [ChartPointContext<Point>],
        newContexts: [ChartPointContext<Point>],
        progress: CGFloat
    ) -> AnyView {
        AnyView(EmptyView())
    }

    func eraseToAnyChartSeries() -> AnyChartSeries<Point> {
        AnyChartSeries(self)
    }
}
