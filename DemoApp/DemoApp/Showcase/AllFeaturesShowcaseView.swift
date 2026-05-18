//
//  AllFeaturesShowcaseView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

struct AllFeaturesShowcaseView: View {
    @State private var viewport = ChartViewportState.automatic
    @State private var selection = ChartSelectionState.none

    private let signal: [Point2D] = DemoShowcaseData.signal
    private let baseline: [Point2D] = DemoShowcaseData.baseline
    private let volume: [Point2D] = DemoShowcaseData.volume

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("All Features Showcase")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("A single production-style surface combining mixed series, nice ticks, selection, crosshair, annotations, viewport and zoom controls.")
                        .font(.subheadline)
                        .foregroundColor(DemoColors.secondaryText)
                }

                HStack(spacing: 10) {
                    ShowcaseMetricCard(title: "Latency", value: "42 ms", trend: "-12%", color: DemoColors.green)
                    ShowcaseMetricCard(title: "Throughput", value: "18.4k", trend: "+8%", color: DemoColors.cyan)
                    ShowcaseMetricCard(title: "Events", value: "7", trend: "3 hot", color: DemoColors.orange)
                }

                chartPanel

                VStack(alignment: .leading, spacing: 12) {
                    Text("Enabled capabilities")
                        .font(.headline)
                        .foregroundColor(.white)

                    FlowFeatureList(
                        items: [
                            ("AreaSeries", DemoColors.cyan),
                            ("BarSeries", DemoColors.orange),
                            ("LineSeries", DemoColors.green),
                            ("Nice ticks", DemoColors.purple),
                            ("Label collision", DemoColors.pink),
                            ("Crosshair", DemoColors.cyan),
                            ("Shared state", DemoColors.green),
                            ("Selectable annotations", DemoColors.orange),
                            ("Initial viewport", DemoColors.purple),
                            ("Zoom controls", DemoColors.pink)
                        ]
                    )
                }
                .padding(16)
                .background(DemoColors.panel)
                .cornerRadius(16)
            }
            .padding(18)
        }
        .background(DemoColors.background.ignoresSafeArea())
        .navigationTitle("All Features")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var chartPanel: some View {
        AllFeaturesTimelinePanel(
            viewport: $viewport,
            selection: $selection,
            signal: signal,
            baseline: baseline,
            volume: volume,
            visibleRangeText: rangeText(viewport.visibleXDomain)
        )
    }

    private func rangeText(_ range: ClosedRange<Double>?) -> String {
        guard let range else { return "automatic" }
        return "\(String(format: "%.1f", range.lowerBound))...\(String(format: "%.1f", range.upperBound))"
    }
}

private struct AllFeaturesTimelinePanel: View {
    @Binding var viewport: ChartViewportState
    @Binding var selection: ChartSelectionState

    let signal: [Point2D]
    let baseline: [Point2D]
    let volume: [Point2D]
    let visibleRangeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            timelineChart
                .frame(height: 300)
            DemoLegend(items: [
                ("Volume", DemoColors.orange),
                ("Baseline", DemoColors.cyan),
                ("Signal", DemoColors.green)
            ])
        }
        .padding(16)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DemoColors.border, lineWidth: 1)
        )
        .cornerRadius(18)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Operations Timeline")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Visible x: \(visibleRangeText)")
                    .font(.caption)
                    .foregroundColor(DemoColors.secondaryText)
            }

            Spacer()

            Image(systemName: "slider.horizontal.3")
                .foregroundColor(DemoColors.cyan)
                .frame(width: 34, height: 34)
                .background(DemoColors.surface)
                .clipShape(Circle())
        }
    }

    private var timelineChart: some View {
        CartesianChartView(
            series: timelineSeries,
            xDomain: .fixed(0...24),
            yDomain: .fixed(0...120),
            xAxes: xAxes,
            yAxes: yAxes,
            horizontalAnnotations: horizontalAnnotations,
            pointAnnotations: pointAnnotations,
            customViewAnnotations: customAnnotations
        ) { points in
            TimelinePointTooltip(points: points)
        }
        .chartInitialViewport(xWindow: 8, anchor: .trailing)
        .chartGestures(verticalScroll: false, verticalZoom: false)
        .chartViewport($viewport)
        .chartSelectionOptions(.scrollSafeNearestX)
        .chartSelectionState($selection)
        .chartAnnotationSelection(hitboxRadius: 30, overlapping: .cycle)
        .chartAnnotationTooltip { annotations in
            TimelineAnnotationTooltip(annotations: annotations)
        }
        .chartTooltipPlacement(.automatic, padding: 12)
        .chartCrosshair(.both(color: DemoColors.cyan.opacity(0.7), lineWidth: 1, dash: [3, 5]))
        .chartZoomControls(step: 2)
    }

    private var timelineSeries: [AnyChartSeries<Point2D>] {
        [
            BarSeries(
                data: volume,
                id: DemoShowcaseSeriesID.timelineVolume,
                color: DemoColors.orange.opacity(0.55),
                label: "Volume",
                barWidth: 9,
                cornerRadius: 2,
                zIndex: 0
            ).eraseToAnyChartSeries(),
            AreaSeries(
                data: baseline,
                id: DemoShowcaseSeriesID.timelineBaseline,
                color: DemoColors.cyan,
                fillColor: DemoColors.cyan,
                fillOpacity: 0.14,
                baseline: 0,
                label: "Baseline",
                lineWidth: 2,
                interpolation: .step,
                zIndex: 1
            ).eraseToAnyChartSeries(),
            LineSeries(
                data: signal,
                id: DemoShowcaseSeriesID.timelineSignal,
                color: DemoColors.green,
                lineWidth: 3,
                interpolation: .linear,
                animation: .morph(),
                zIndex: 2
            ).eraseToAnyChartSeries()
        ]
    }

    private var xAxes: [XAxisConfig] {
        [
            XAxisConfig(
                tickStrategy: .nice,
                labelCollisionStrategy: .hideOverlapping(minSpacing: 42),
                tickCount: 8,
                labelFormatter: { "\(Int($0))h" }
            )
        ]
    }

    private var yAxes: [YAxisConfig] {
        [
            YAxisConfig(
                tickStrategy: .nice,
                tickCount: 5,
                labelFormatter: { "\(Int($0))" }
            )
        ]
    }

    private var pointAnnotations: [PointAnnotation<Double, Double>] {
        [
            PointAnnotation(
                x: 12,
                y: 91,
                label: "Deployment",
                shape: .star,
                color: DemoColors.orange,
                size: 20,
                strokeColor: .white,
                strokeWidth: 1.5,
                isSelectable: true
            ),
            PointAnnotation(
                x: 17,
                y: 101,
                label: "Peak load",
                shape: .circle,
                color: DemoColors.pink,
                size: 16,
                strokeColor: .white,
                strokeWidth: 1.5,
                isSelectable: true
            )
        ]
    }

    private var horizontalAnnotations: [HorizontalAnnotation] {
        [
            HorizontalAnnotation(yValue: 80, label: "Target", color: DemoColors.purple)
        ]
    }

    private var customAnnotations: [CustomViewAnnotation<Double, Double>] {
        [
            CustomViewAnnotation(
                x: 20,
                y: 70,
                label: "Alert",
                isSelectable: true
            ) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(DemoColors.orange)
            }
        ]
    }
}

private struct TimelinePointTooltip: View {
    let points: [ChartPointContext<Point2D>]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(points, id: \.originalPoint.id) { point in
                Text("x \(Int(point.originalPoint.x))  y \(Int(point.originalPoint.y))")
                    .font(.caption.bold())
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.84))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

private struct TimelineAnnotationTooltip: View {
    let annotations: [ChartAnnotationContext]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(annotations) { annotation in
                Text(annotation.label ?? "Event")
                    .font(.caption.bold())
                Text("x \(Int(annotation.x)), y \(Int(annotation.y))")
                    .font(.caption2)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.84))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

private struct FlowFeatureList: View {
    let items: [(String, Color)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.0) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.1)
                        .frame(width: 7, height: 7)
                    Text(item.0)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(DemoColors.surface)
                .cornerRadius(10)
            }
        }
    }
}
