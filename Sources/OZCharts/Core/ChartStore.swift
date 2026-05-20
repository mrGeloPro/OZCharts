//
//  ChartStore.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

@MainActor
public final class ChartStore<
    Point: ChartDataPoint,
    XScale: Scale,
    YScale: Scale
>: ObservableObject
    where XScale.InputType == Point.XValue, XScale.OutputType == CGFloat,
    YScale.InputType == Point.YValue, YScale.OutputType == CGFloat,
    Point.XValue == Double, Point.YValue == Double {
    // MARK: - Published State

    @Published public var activeXScale: XScale
    @Published public var activeYScale: YScale

    @Published public var seriesContexts: [[ChartPointContext<Point>]] = []
    @Published public var renderSeriesContexts: [[ChartPointContext<Point>]] = []
    @Published public var oldSeriesContexts: [[ChartPointContext<Point>]] = []
    @Published public var oldRenderSeriesContexts: [[ChartPointContext<Point>]] = []
    @Published public var animationProgress: CGFloat = 1.0
    @Published public var animationPhase: Int = 0
    @Published public var isAnimationActive = false

    @Published public var highlightedPoints: [ChartPointContext<Point>] = []
    @Published public var selectedElements: [ChartSelectedElement] = []
    @Published public var selectedElementContexts: [ChartElementContext] = []
    @Published public var selectableElements: [ChartElementContext] = []
    @Published public var violinBackgrounds: [AnyHashable: Path] = [:]

    @Published public var viewport = ChartViewport()

    // MARK: - Scale State

    public var baseXScale: XScale
    public var baseYScale: YScale
    public var canvasSize: CGSize = .zero

    // MARK: - Internal State

    var layoutCoalescingIntervalNanoseconds: UInt64 = 16_000_000
    var updateCounter: Int = 0
    var layoutTask: Task<Void, Never>?
    var selectionCycleIDs: [UUID] = []
    var selectionCycleIndex: Int = 0
    var currentSeriesIDs: [UUID] = []
    var pointInteractionIndex: ChartPointInteractionIndex<Point>?

    public init(xScale: XScale, yScale: YScale) {
        self.baseXScale = xScale
        self.baseYScale = yScale
        self.activeXScale = xScale
        self.activeYScale = yScale
    }

    public func updateBaseScales(xScale: XScale, yScale: YScale) {
        baseXScale = xScale
        baseYScale = yScale
    }

    deinit {
        layoutTask?.cancel()
    }
}
