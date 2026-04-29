//
//  DemoShowcaseViews.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

struct OZDemoHomeView: View {
    private let showcaseRoutes: [DemoRoute] = [
        DemoRoute(
            title: "All Features",
            subtitle: "Selection, crosshair, viewport, annotations, area and bars",
            icon: "sparkles",
            tint: DemoColors.cyan,
            destination: AnyView(AllFeaturesShowcaseView())
        ),
        DemoRoute(
            title: "Live Telemetry",
            subtitle: "Streaming data with live tracking",
            icon: "waveform.path.ecg",
            tint: DemoColors.green,
            destination: AnyView(LiveTrackingDemoView())
        ),
        DemoRoute(
            title: "Linked Charts",
            subtitle: "Shared selection across multiple charts",
            icon: "link",
            tint: DemoColors.orange,
            destination: AnyView(LinkedChartsDemoView())
        ),
        DemoRoute(
            title: "Selectable Events",
            subtitle: "Tap overlapping markers and custom annotations",
            icon: "cursorarrow.click.2",
            tint: DemoColors.pink,
            destination: AnyView(SelectableAnnotationsDemoView())
        )
    ]

    private let catalogRoutes: [DemoRoute] = [
        DemoRoute(title: "Line and Empty State", subtitle: "Axes, tooltip and no-data UI", icon: "chart.xyaxis.line", tint: DemoColors.purple, destination: AnyView(HeightDemoView())),
        DemoRoute(title: "Area + Bar", subtitle: "Mixed cartesian composition", icon: "chart.bar.xaxis", tint: DemoColors.cyan, destination: AnyView(AreaAndBarDemoView())),
        DemoRoute(title: "Viewport Controls", subtitle: "Initial zoom, scroll and programmatic zoom", icon: "plus.magnifyingglass", tint: DemoColors.green, destination: AnyView(ViewportControlsDemoView())),
        DemoRoute(title: "Animation", subtitle: "Draw, morph and fade transitions", icon: "play.circle.fill", tint: DemoColors.orange, destination: AnyView(AnimationShowcaseView())),
        DemoRoute(title: "Hybrid Layers", subtitle: "Lines, symbols and custom views", icon: "square.3.layers.3d", tint: DemoColors.pink, destination: AnyView(HybridChartDemoView())),
        DemoRoute(title: "Donut Score", subtitle: "Polar composition and custom legend", icon: "circle.dotted", tint: DemoColors.purple, destination: AnyView(DonutScoreDemoView())),
        DemoRoute(title: "Violin Accuracy", subtitle: "Distribution density and dual axes", icon: "chart.dots.scatter", tint: DemoColors.cyan, destination: AnyView(AccuracyDemoView())),
        DemoRoute(title: "Stacked Area", subtitle: "Layered step interpolation", icon: "chart.line.uptrend.xyaxis", tint: DemoColors.green, destination: AnyView(PointsDistributionDemoView())),
        DemoRoute(title: "Stacked Bar", subtitle: "Grouped horizontal bars", icon: "chart.bar.fill", tint: DemoColors.orange, destination: AnyView(StarAchievementDemoView())),
        DemoRoute(title: "Event Stack", subtitle: "Multi-layer event markers", icon: "square.stack.3d.up.fill", tint: DemoColors.pink, destination: AnyView(EventStackDemoView()))
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero

                MetricsStrip()

                DemoSectionHeader(
                    title: "Showcase",
                    subtitle: "Start here to see the 2.0 surface working together."
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: 12)], spacing: 12) {
                    ForEach(showcaseRoutes) { route in
                        DemoRouteCard(route: route, style: .featured)
                    }
                }

                DemoSectionHeader(
                    title: "Examples Catalog",
                    subtitle: "Focused screens for each chart type and interaction."
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: 12)], spacing: 12) {
                    ForEach(catalogRoutes) { route in
                        DemoRouteCard(route: route, style: .compact)
                    }
                }
            }
            .padding(18)
        }
        .background(DemoColors.background.ignoresSafeArea())
        .navigationTitle("OZCharts")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        NavigationLink(destination: AllFeaturesShowcaseView()) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OZCharts 2.0")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("Production-style charting for live data, analytics, events and rich interactions.")
                            .font(.subheadline)
                            .foregroundColor(DemoColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 12)

                    Image(systemName: "arrow.up.right")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DemoColors.cyan)
                        .frame(width: 36, height: 36)
                        .background(DemoColors.surface)
                        .clipShape(Circle())
                }

                ShowcaseHeroChart()
                    .frame(height: 176)
                    .allowsHitTesting(false)

                HStack(spacing: 8) {
                    FeaturePill(title: "Area", color: DemoColors.cyan)
                    FeaturePill(title: "Bars", color: DemoColors.orange)
                    FeaturePill(title: "Events", color: DemoColors.pink)
                    FeaturePill(title: "Live", color: DemoColors.green)
                }
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.15, blue: 0.20),
                        Color(red: 0.07, green: 0.08, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DemoColors.border, lineWidth: 1)
            )
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

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
        .chartViewport($viewport)
        .chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
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
                color: DemoColors.orange.opacity(0.55),
                label: "Volume",
                barWidth: 9,
                cornerRadius: 2,
                zIndex: 0
            ).eraseToAnyChartSeries(),
            AreaSeries(
                data: baseline,
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

private struct ShowcaseHeroChart: View {
    var body: some View {
        CartesianChartView(
            series: [
                BarSeries(
                    data: DemoShowcaseData.heroVolume,
                    color: DemoColors.orange.opacity(0.5),
                    barWidth: 7
                ).eraseToAnyChartSeries(),
                AreaSeries(
                    data: DemoShowcaseData.heroSignal,
                    color: DemoColors.cyan,
                    fillOpacity: 0.18,
                    baseline: 0,
                    lineWidth: 2
                ).eraseToAnyChartSeries(),
                LineSeries(
                    data: DemoShowcaseData.heroSignal,
                    color: DemoColors.green,
                    lineWidth: 2
                ).eraseToAnyChartSeries()
            ],
            xDomain: .fixed(0...14),
            yDomain: .fixed(0...110),
            xAxes: [],
            yAxes: [],
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .chartCrosshair(.hidden)
    }
}

private struct DemoRoute: Identifiable {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AnyView

    var id: String { title }
}

private enum DemoRouteCardStyle {
    case featured
    case compact
}

private struct DemoRouteCard: View {
    let route: DemoRoute
    let style: DemoRouteCardStyle

    var body: some View {
        NavigationLink(destination: route.destination) {
            VStack(alignment: .leading, spacing: style == .featured ? 14 : 10) {
                HStack {
                    Image(systemName: route.icon)
                        .font(.headline)
                        .foregroundColor(route.tint)
                        .frame(width: 34, height: 34)
                        .background(route.tint.opacity(0.14))
                        .clipShape(Circle())

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(DemoColors.secondaryText)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(route.title)
                        .font(style == .featured ? .headline : .subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(route.subtitle)
                        .font(.caption)
                        .foregroundColor(DemoColors.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(minHeight: style == .featured ? 132 : 118, alignment: .topLeading)
            .padding(14)
            .background(DemoColors.panel)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DemoColors.border, lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

private struct DemoSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(DemoColors.secondaryText)
        }
    }
}

private struct MetricsStrip: View {
    var body: some View {
        HStack(spacing: 10) {
            ShowcaseMetricCard(title: "Series", value: "8", trend: "types", color: DemoColors.cyan)
            ShowcaseMetricCard(title: "Input", value: "Touch", trend: "zoom", color: DemoColors.green)
            ShowcaseMetricCard(title: "Release", value: "2.0", trend: "ready", color: DemoColors.orange)
        }
    }
}

private struct ShowcaseMetricCard: View {
    let title: String
    let value: String
    let trend: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundColor(DemoColors.secondaryText)
                .lineLimit(1)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
            Text(trend)
                .font(.caption2.weight(.bold))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(14)
    }
}

private struct FeaturePill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .cornerRadius(999)
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

private enum DemoShowcaseData {
    static let heroSignal: [Point2D] = (0...14).map { index in
        let x = Double(index)
        return Point2D(x: x, y: 42 + sin(x / 1.7) * 16 + Double(index % 4) * 7)
    }

    static let heroVolume: [Point2D] = (0...14).map { index in
        Point2D(x: Double(index), y: 18 + Double((index * 13) % 48))
    }

    static let signal: [Point2D] = (0...24).map { index in
        let x = Double(index)
        return Point2D(x: x, y: 58 + sin(x / 2.0) * 22 + Double((index * 5) % 17))
    }

    static let baseline: [Point2D] = (0...24).map { index in
        let x = Double(index)
        return Point2D(x: x, y: 46 + cos(x / 2.6) * 10 + Double(index % 6) * 3)
    }

    static let volume: [Point2D] = (0...24).map { index in
        Point2D(x: Double(index), y: 15 + Double((index * 19) % 70))
    }
}

enum DemoColors {
    static let background = Color(red: 0.045, green: 0.052, blue: 0.070)
    static let panel = Color(red: 0.075, green: 0.088, blue: 0.115)
    static let surface = Color(red: 0.105, green: 0.122, blue: 0.155)
    static let border = Color.white.opacity(0.08)
    static let secondaryText = Color.white.opacity(0.62)

    static let cyan = Color(red: 0.17, green: 0.82, blue: 0.94)
    static let green = Color(red: 0.32, green: 0.86, blue: 0.54)
    static let orange = Color(red: 1.00, green: 0.62, blue: 0.24)
    static let pink = Color(red: 1.00, green: 0.36, blue: 0.58)
    static let purple = Color(red: 0.62, green: 0.49, blue: 1.00)
}

struct DemoChartPanel<Content: View>: View {
    let minHeight: CGFloat?
    @ViewBuilder let content: Content

    init(minHeight: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .padding(16)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DemoColors.border, lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct DemoLegend: View {
    let items: [(String, Color)]

    var body: some View {
        HStack(spacing: 18) {
            ForEach(items, id: \.0) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.1)
                        .frame(width: 10, height: 10)
                    Text(item.0)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DemoHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(DemoColors.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
    }
}

struct DemoActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func demoScreenBackground() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoColors.background.ignoresSafeArea())
    }
}
