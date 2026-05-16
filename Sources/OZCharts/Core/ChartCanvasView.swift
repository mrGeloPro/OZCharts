//
//  ChartCanvasView.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct ChartCanvasView<
    Point: ChartDataPoint,
    XScale: Scale,
    YScale: Scale,
    TooltipContent: View
>: View
    where XScale.InputType == Double, XScale.OutputType == CGFloat,
    YScale.InputType == Double, YScale.OutputType == CGFloat,
    Point.XValue == Double, Point.YValue == Double {
    let series: [AnyChartSeries<Point>]
    let seriesContexts: [[ChartPointContext<Point>]]
    let renderSeriesContexts: [[ChartPointContext<Point>]]

    let oldSeriesContexts: [[ChartPointContext<Point>]]
    let oldRenderSeriesContexts: [[ChartPointContext<Point>]]
    let animationProgress: CGFloat
    let animationPhase: Int
    let isAnimationActive: Bool
    let animationStyle: ChartAnimationStyle

    let activeXScale: XScale
    let activeYScale: YScale

    let xAxes: [XAxisConfig]
    let yAxes: [YAxisConfig]
    let canvasRenderOrder: [CanvasLayer]

    let xRangeAnnotations: [XRangeAnnotation]
    let xyRangeAnnotations: [XYRangeAnnotation]
    let rangeAnnotations: [RangeAnnotation]
    let verticalAnnotations: [VerticalAnnotation]
    let horizontalAnnotations: [HorizontalAnnotation]
    let visiblePointAnnotations: [PointAnnotation<Double, Double>]

    let violinBackgrounds: [AnyHashable: Path]
    let violinColorMapper: ((AnyHashable) -> Color)?

    let highlightedPoints: [ChartPointContext<Point>]
    let selectedElementContexts: [ChartElementContext]
    let selectedElementStyle: ChartSelectedElementStyle
    let crosshairStyle: ChartCrosshairStyle
    let tooltipPlacement: ChartTooltipPlacement
    let tooltipAnchorPoint: CGPoint?
    let tooltipOffset: CGPoint
    let tooltipPadding: CGFloat
    let tooltipMaxWidth: CGFloat?
    @ViewBuilder let tooltipContent: ([ChartPointContext<Point>]) -> TooltipContent

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in
                    guard size.width > 0, size.height > 0 else { return }

                    for layer in canvasRenderOrder {
                        switch layer {
                        case .grid:
                            GridRenderer.draw(
                                into: &context, size: size,
                                xAxes: xAxes, yAxes: yAxes,
                                activeXScale: activeXScale, activeYScale: activeYScale
                            )

                        case .rangeAnnotations:
                            AnnotationRenderer.drawXRanges(
                                into: &context, size: size,
                                annotations: xRangeAnnotations,
                                activeXScale: activeXScale
                            )

                            AnnotationRenderer.drawXYRanges(
                                into: &context, size: size,
                                annotations: xyRangeAnnotations,
                                activeXScale: activeXScale,
                                activeYScale: activeYScale
                            )

                            AnnotationRenderer.drawRanges(
                                into: &context, size: size,
                                annotations: rangeAnnotations,
                                activeYScale: activeYScale
                            )

                        case .horizontalAnnotations:
                            AnnotationRenderer.drawVertical(
                                into: &context, size: size,
                                annotations: verticalAnnotations,
                                activeXScale: activeXScale
                            )

                            AnnotationRenderer.drawHorizontal(
                                into: &context, size: size,
                                annotations: horizontalAnnotations,
                                activeYScale: activeYScale
                            )

                        case .pointAnnotations:
                            AnnotationRenderer.drawPoints(
                                into: &context, size: size,
                                annotations: visiblePointAnnotations,
                                activeXScale: activeXScale, activeYScale: activeYScale
                            )

                        case .coreChart:
                            for (groupId, path) in violinBackgrounds {
                                let color = violinColorMapper?(groupId) ?? .blue
                                context.fill(path, with: .color(color.opacity(0.4)))
                                context.stroke(path, with: .color(color), lineWidth: 1)
                            }
                            for (index, s) in series.enumerated() {
                                guard index < renderSeriesContexts.count else { continue }
                                guard !s.shouldRenderThroughAnimatableOverlay(isAnimationActive: isAnimationActive) else { continue }
                                s.render(into: &context, contexts: renderSeriesContexts[index], size: size)
                            }
                        }
                    }

                    AnnotationRenderer.drawCrosshair(
                        into: &context,
                        size: size,
                        points: highlightedPoints,
                        style: crosshairStyle
                    )

                    ChartSelectedElementRenderer.draw(
                        into: &context,
                        elements: selectedElementContexts,
                        style: selectedElementStyle
                    )
                }

                ForEach(Array(series.enumerated()), id: \.offset) { index, s in
                    if index < renderSeriesContexts.count, s.shouldRenderThroughAnimatableOverlay(isAnimationActive: isAnimationActive) {
                        let oldCtx = index < oldRenderSeriesContexts.count ? oldRenderSeriesContexts[index] : []
                        let newCtx = renderSeriesContexts[index]

                        s.animatableView(
                            oldContexts: oldCtx,
                            newContexts: newCtx,
                            progress: animationProgress
                        )
                        .id("\(animationPhase)-\(index)")
                    }
                }

                if !highlightedPoints.isEmpty {
                    ChartTooltipOverlay(
                        points: highlightedPoints,
                        anchorOverride: tooltipAnchorPoint,
                        canvasSize: geometry.size,
                        placement: tooltipPlacement,
                        offset: tooltipOffset,
                        padding: tooltipPadding,
                        maxWidth: tooltipMaxWidth,
                        content: tooltipContent
                    )
                }
            }
        }
    }
}

private struct ChartTooltipOverlay<Point: ChartDataPoint, Content: View>: View
    where Point.XValue == Double, Point.YValue == Double {
    let points: [ChartPointContext<Point>]
    let anchorOverride: CGPoint?
    let canvasSize: CGSize
    let placement: ChartTooltipPlacement
    let offset: CGPoint
    let padding: CGFloat
    let maxWidth: CGFloat?
    let content: ([ChartPointContext<Point>]) -> Content

    @State private var tooltipSize: CGSize = .zero

    var body: some View {
        if let anchor = anchorOverride ?? ChartTooltipLayout.anchor(for: points) {
            content(points)
                .frame(maxWidth: maxWidth, alignment: .leading)
                .fixedSize(horizontal: maxWidth == nil, vertical: true)
                .readSize { tooltipSize = $0 }
                .position(
                    ChartTooltipLayout.resolve(
                        anchor: anchor,
                        tooltipSize: tooltipSize,
                        canvasSize: canvasSize,
                        placement: placement,
                        offset: offset,
                        padding: padding
                    ).position
                )
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private extension AnyChartSeries {
    func shouldRenderThroughAnimatableOverlay(isAnimationActive: Bool) -> Bool {
        isAnimationActive && usesAnimatableOverlay && animation.kind != .none
    }
}
