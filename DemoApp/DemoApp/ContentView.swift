//
//  ContentView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

struct ContentView: View {
    var body: some View {
        NavigationView {
            OZDemoHomeView()
        }
    }
}

// MARK: - Viewport Controls Demo

struct ViewportControlsDemoView: View {
    @State private var viewport = ChartViewportState(visibleXDomain: 0...8)

    let data: [Point2D] = (0...24).map { hour in
        Point2D(
            x: Double(hour),
            y: 40 + sin(Double(hour) / 2.3) * 22 + Double(hour % 5) * 3
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            AreaSeries(
                                data: data,
                                color: DemoColors.cyan,
                                fillOpacity: 0.18,
                                baseline: 0,
                                label: "Signal"
                            )
                        ],
                        xDomain: .fixed(0...24),
                        yDomain: .fixed(0...100),
                        xAxes: [
                            XAxisConfig(
                                tickStrategy: .nice,
                                labelCollisionStrategy: .hideOverlapping(minSpacing: 42),
                                tickCount: 8,
                                labelFormatter: { "\(Int($0))h" }
                            )
                        ],
                        yAxes: [
                            YAxisConfig(tickStrategy: .nice, tickCount: 5)
                        ]
                    ) { points in
                        if let point = points.first {
                            Text("\(Int(point.originalPoint.x))h  \(Int(point.originalPoint.y))")
                                .font(.caption.bold())
                                .padding(6)
                                .background(Color.black.opacity(0.78))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    .chartInitialViewport(xWindow: 8, anchor: .leading)
                    .chartViewport($viewport)
                    .chartZoomControls(step: 2)
                    .chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
                    .chartCrosshair(.vertical(color: DemoColors.cyan.opacity(0.75)))
                    .frame(height: 290)

                    DemoLegend(items: [("Signal", DemoColors.cyan)])
                }

                DemoHint(text: "Visible x: \(rangeText(viewport.visibleXDomain))")
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Viewport Controls")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rangeText(_ range: ClosedRange<Double>?) -> String {
        guard let range else { return "automatic" }
        return "\(String(format: "%.1f", range.lowerBound))...\(String(format: "%.1f", range.upperBound))"
    }
}

// MARK: - Linked Charts Demo

struct LinkedChartsDemoView: View {
    @State private var selection = ChartSelectionState.none

    let price: [Point2D] = (0...18).map { index in
        Point2D(x: Double(index), y: 120 + sin(Double(index) / 2) * 18 + Double(index) * 1.8)
    }

    let volume: [Point2D] = (0...18).map { index in
        Point2D(x: Double(index), y: 30 + Double((index * 17) % 45))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                linkedChart(
                    title: "Price",
                    tint: DemoColors.green,
                    series: AreaSeries(
                        data: price,
                        color: DemoColors.green,
                        fillOpacity: 0.18,
                        baseline: 90,
                        label: "Price"
                    ).eraseToAnyChartSeries(),
                    yDomain: 80...180,
                    valueSuffix: "$"
                )

                linkedChart(
                    title: "Volume",
                    tint: DemoColors.orange,
                    series: BarSeries(
                        data: volume,
                        color: DemoColors.orange,
                        label: "Volume",
                        barWidth: 10
                    ).eraseToAnyChartSeries(),
                    yDomain: 0...90,
                    valueSuffix: ""
                )
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Linked Charts")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func linkedChart(
        title: String,
        tint: Color,
        series: AnyChartSeries<Point2D>,
        yDomain: ClosedRange<Double>,
        valueSuffix: String
    ) -> some View {
        DemoChartPanel {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            CartesianChartView(
                series: [series],
                xDomain: .fixed(0...18),
                yDomain: .fixed(yDomain),
                xAxes: [XAxisConfig(tickStrategy: .nice, tickCount: 7)],
                yAxes: [YAxisConfig(tickStrategy: .nice, tickCount: 4)]
            ) { points in
                if let point = points.first {
                    Text("\(Int(point.originalPoint.y))\(valueSuffix)")
                        .font(.caption.bold())
                        .padding(6)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            .chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
            .chartSelectionState($selection)
            .chartCrosshair(.vertical(color: tint.opacity(0.75)))
            .frame(height: 220)
        }
    }
}

// MARK: - Selectable Annotations Demo

struct SelectableAnnotationsDemoView: View {
    let data: [Point2D] = [
        Point2D(x: 0, y: 30),
        Point2D(x: 2, y: 70),
        Point2D(x: 4, y: 48),
        Point2D(x: 6, y: 86),
        Point2D(x: 8, y: 58)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [LineSeries(data: data, color: DemoColors.cyan, lineWidth: 3)],
                        xDomain: .fixed(0...8),
                        yDomain: .fixed(0...100),
                        pointAnnotations: [
                            PointAnnotation(
                                x: 6,
                                y: 86,
                                label: "Peak event",
                                shape: .star,
                                color: .yellow,
                                size: 22,
                                strokeColor: .white,
                                strokeWidth: 2,
                                isSelectable: true
                            )
                        ],
                        customViewAnnotations: [
                            CustomViewAnnotation(
                                x: 4,
                                y: 48,
                                label: "Recovery marker",
                                isSelectable: true
                            ) {
                                Image(systemName: "flag.fill")
                                    .foregroundColor(DemoColors.pink)
                            }
                        ]
                    ) { _ in EmptyView() }
                    .chartAnnotationSelection(hitboxRadius: 30, overlapping: .cycle)
                    .chartAnnotationTooltip { annotations in
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(annotations) { annotation in
                                Text(annotation.label ?? "Event")
                                    .font(.caption.bold())
                                Text("x \(Int(annotation.x)), y \(Int(annotation.y))")
                                    .font(.caption2)
                            }
                        }
                        .padding(8)
                        .background(Color.black.opacity(0.82))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .chartTooltipPlacement(.automatic, padding: 12)
                    .frame(height: 340)
                }

                DemoHint(text: "Tap the star or flag to show annotation details.")
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Selectable Annotations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Area and Bar Demo

struct AreaAndBarDemoView: View {
    let trend: [Point2D] = [
        Point2D(x: 0, y: 20),
        Point2D(x: 1, y: 32),
        Point2D(x: 2, y: 46),
        Point2D(x: 3, y: 38),
        Point2D(x: 4, y: 62),
        Point2D(x: 5, y: 76)
    ]

    let bars: [Point2D] = [
        Point2D(x: 0, y: 18),
        Point2D(x: 1, y: 22),
        Point2D(x: 2, y: 34),
        Point2D(x: 3, y: 28),
        Point2D(x: 4, y: 48),
        Point2D(x: 5, y: 52)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            BarSeries(
                                data: bars,
                                color: DemoColors.purple.opacity(0.65),
                                label: "Volume",
                                barWidth: 18
                            ).eraseToAnyChartSeries(),
                            AreaSeries(
                                data: trend,
                                color: DemoColors.cyan,
                                fillOpacity: 0.16,
                                baseline: 0,
                                label: "Trend",
                                lineWidth: 3
                            ).eraseToAnyChartSeries()
                        ],
                        xDomain: .fixed(0...5),
                        yDomain: .fixed(0...90),
                        xAxes: [
                            XAxisConfig(
                                tickStrategy: .nice,
                                labelCollisionStrategy: .hideOverlapping(minSpacing: 36),
                                tickCount: 6
                            )
                        ],
                        yAxes: [
                            YAxisConfig(tickStrategy: .nice, tickCount: 5)
                        ]
                    ) { points in
                        if let point = points.first {
                            Text("\(Int(point.originalPoint.y))")
                                .font(.caption.bold())
                                .padding(6)
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    .chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
                    .chartCrosshair(.vertical(color: DemoColors.cyan.opacity(0.75)))
                    .frame(height: 300)

                    DemoLegend(items: [
                        ("Volume", DemoColors.purple),
                        ("Trend", DemoColors.cyan)
                    ])
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Area + Bar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Donut Demo

struct DonutScoreDemoView: View {
    let mockData: [Point2D] = [
        Point2D(x: 0, y: 85.2),
        Point2D(x: 1, y: 11.3),
        Point2D(x: 2, y: 3.5)
    ]

    let legend: [(String, Double, Color)] = [
        ("Basic", 85.2, DemoColors.purple),
        ("Bonus", 11.3, DemoColors.pink),
        ("Streak", 3.5, .yellow)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            DonutSeries(
                                data: mockData,
                                colors: legend.map(\.2),
                                thickness: 34,
                                gapAngle: .degrees(6),
                                startAngle: .degrees(-90),
                                lineCap: .butt
                            )
                        ],
                        xScale: LinearScale(domain: 0...1),
                        yScale: LinearScale(domain: 0...1),
                        xAxes: [],
                        yAxes: [],
                        isHorizontalScrollEnabled: false,
                        isHorizontalZoomEnabled: false,
                        isVerticalScrollEnabled: false,
                        isVerticalZoomEnabled: false
                    ) { _ in EmptyView() }
                    .frame(height: 290)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(legend, id: \.0) { item in
                            HStack(spacing: 10) {
                                Circle().fill(item.2).frame(width: 10, height: 10)
                                Text("\(item.0) - \(String(format: "%.1f", item.1))%")
                                    .foregroundColor(.white)
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Total Score")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Line & Empty State Demo

struct HeightDemoView: View {
    @State private var mockData: [Point2D] = [
        Point2D(x: 1, y: 2.0), Point2D(x: 3, y: 4.0), Point2D(x: 5, y: 2.9),
        Point2D(x: 7, y: 4.0), Point2D(x: 9, y: 4.9), Point2D(x: 12, y: 9.0),
        Point2D(x: 14, y: 6.2), Point2D(x: 16, y: 4.0), Point2D(x: 18, y: 5.0),
        Point2D(x: 19, y: 4.0)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(
                                data: mockData,
                                color: DemoColors.purple,
                                lineWidth: 3
                            )
                        ],
                        xScale: LinearScale(domain: 1...20),
                        yScale: LinearScale(domain: 0...10),
                        xAxes: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: false,
                                tickCount: 10,
                                labelFormatter: { "\(Int($0))s" },
                                showAxisLine: true
                            )
                        ],
                        yAxes: [
                            YAxisConfig(
                                position: .leading,
                                gridColor: .gray.opacity(0.25),
                                gridLineDash: [4, 4],
                                tickCount: 6,
                                labelFormatter: { "\(Int($0))" },
                                showAxisLine: true
                            )
                        ],
                        emptyState: {
                            AnyView(
                                VStack(spacing: 12) {
                                    Image(systemName: "chart.xyaxis.line")
                                        .font(.system(size: 40))
                                        .foregroundColor(DemoColors.secondaryText)
                                    Text("No Data Available")
                                        .font(.headline)
                                        .foregroundColor(DemoColors.secondaryText)
                                }
                            )
                        }
                    ) { points in
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(points, id: \.originalPoint.id) { pointContext in
                                Text("\(String(format: "%.1f", pointContext.originalPoint.y))")
                                    .foregroundColor(.white)
                                    .font(.caption).bold()
                            }
                        }
                        .padding(6)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(6)
                    }
                    .frame(height: 330)
                }

                DemoActionButton(
                    title: mockData.isEmpty ? "Load Data" : "Clear Data",
                    color: mockData.isEmpty ? DemoColors.green : DemoColors.pink
                ) {
                    withAnimation {
                        if mockData.isEmpty {
                            mockData = [
                                Point2D(x: 1, y: 2.0), Point2D(x: 3, y: 4.0), Point2D(x: 5, y: 2.9),
                                Point2D(x: 7, y: 4.0), Point2D(x: 9, y: 4.9), Point2D(x: 12, y: 9.0),
                                Point2D(x: 14, y: 6.2), Point2D(x: 16, y: 4.0), Point2D(x: 18, y: 5.0),
                                Point2D(x: 19, y: 4.0)
                            ]
                        } else {
                            mockData = []
                        }
                    }
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Height")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Violin Demo

enum ViolinGroup: Hashable { case result, best }

struct AccuracyDemoView: View {
    let mockData: [GroupedPoint2D<ViolinGroup>] = (0...150).map { i in
        let group: ViolinGroup = i % 2 == 0 ? .result : .best
        let x = group == .result ? Double.random(in: 10...48) : Double.random(in: 52...90)
        let y = Double.random(in: 0...1) > 0.3 ? Double.random(in: 100...140) : Double.random(in: 80...200)
        return GroupedPoint2D(x: x, y: y, group: group)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            ViolinSeries(
                                data: mockData,
                                centerX: 50,
                                maxHalfWidth: 40,
                                sideMapper: { $0 == .result ? .left : .right },
                                colorMapper: { $0 == .result ? DemoColors.cyan : DemoColors.purple }
                            )
                        ],
                        xScale: LinearScale(domain: 0...100),
                        yScale: LinearScale(domain: 60...240),
                        xAxes: [
                            XAxisConfig(position: .bottom, tickCount: 0, labelFormatter: { _ in "" })
                        ],
                        yAxes: [
                            YAxisConfig(position: .leading, tickCount: 7, labelFormatter: { "\(Int($0))" }),
                            YAxisConfig(position: .trailing, tickCount: 7, labelFormatter: { bpm in
                                if bpm == 0 { return "0" }
                                let ms = 60000.0 / bpm
                                return "\(Int(ms))"
                            })
                        ],
                        horizontalAnnotations: [
                            HorizontalAnnotation(yValue: 120, label: "Target 120 BPM", color: .yellow)
                        ],
                        isHorizontalScrollEnabled: false,
                        isHorizontalZoomEnabled: false,
                        isVerticalScrollEnabled: true,
                        isVerticalZoomEnabled: true
                    ) { _ in EmptyView() }
                    .frame(height: 390)

                    DemoLegend(items: [
                        ("Result", DemoColors.cyan),
                        ("Best", DemoColors.purple)
                    ])
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Accuracy Overview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SystemRandomSource {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func uniform() -> Double { Double(next() % 10_000) / 10_000.0 }
    /// Box-Muller → approx ~N(0,1)
    mutating func gauss() -> Double {
        let u1 = max(1e-9, uniform())
        let u2 = uniform()
        return sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
    }
}

// MARK: - Stacked Area Demo

struct PointsDistributionDemoView: View {
    struct LayerData {
        let basic:  [Point2D]
        let bonus:  [Point2D]
        let streak: [Point2D]
    }

    let layers: LayerData = {
        var basic:  [Point2D] = []
        var bonus:  [Point2D] = []
        var streak: [Point2D] = []
        let xValues: [Double] = [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 13, 14, 17, 19, 21, 23, 25, 27, 28, 30, 32]

        for (i, x) in xValues.enumerated() {
            let basicY  = 60 + Double(i) * 18
            let bonusY  = basicY + 40 + Double(i) * 3
            let streakY = bonusY + 35 + Double(i) * 2
            basic.append(Point2D(x: x, y: basicY))
            bonus.append(Point2D(x: x, y: bonusY))
            streak.append(Point2D(x: x, y: streakY))
        }
        return LayerData(basic: basic, bonus: bonus, streak: streak)
    }()

    let legend: [(String, Color)] = [
        ("Basic", DemoColors.cyan),
        ("Bonus", DemoColors.purple),
        ("Streak", .yellow)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(
                                data: layers.streak,
                                color: .yellow,
                                lineWidth: 3,
                                interpolation: .step,
                                area: AreaStyle(fillColor: .yellow, fillOpacity: 0.35),
                                zIndex: 0
                            ),
                            LineSeries(
                                data: layers.bonus,
                                color: DemoColors.purple,
                                lineWidth: 3,
                                interpolation: .step,
                                area: AreaStyle(fillColor: DemoColors.purple, fillOpacity: 0.55),
                                zIndex: 1
                            ),
                            LineSeries(
                                data: layers.basic,
                                color: DemoColors.cyan,
                                lineWidth: 3,
                                interpolation: .step,
                                area: AreaStyle(fillColor: DemoColors.cyan, fillOpacity: 0.45),
                                zIndex: 2
                            )
                        ],
                        xScale: LinearScale(domain: 0...32),
                        yScale: LinearScale(domain: 0...700),
                        xAxes: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: false,
                                tickCount: 7,
                                labelFormatter: { "\(Int($0))s" },
                                showAxisLine: true
                            )
                        ],
                        yAxes: [
                            YAxisConfig(
                                position: .leading,
                                gridColor: .gray.opacity(0.2),
                                gridLineDash: [4, 4],
                                tickCount: 8,
                                labelFormatter: { "\(Int($0))" },
                                showAxisLine: true
                            )
                        ]
                    ) { _ in EmptyView() }
                    .frame(height: 330)

                    DemoLegend(items: legend)
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Points Distribution")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stacked Bar Demo

enum StarType: Hashable { case s1, s2, s3 }

struct StarAchievementDemoView: View {
    /// y=0 Current, y=1 Last, y=2 Average, y=3 High score.
    let mockData: [GroupedPoint2D<StarType>] = [
        // Current
        GroupedPoint2D(x: 12, y: 0, group: .s1),
        GroupedPoint2D(x: 20, y: 0, group: .s2),
        GroupedPoint2D(x: 23, y: 0, group: .s3),
        // Last
        GroupedPoint2D(x: 10, y: 1, group: .s1),
        GroupedPoint2D(x: 18, y: 1, group: .s2),
        GroupedPoint2D(x: 14, y: 1, group: .s3),
        // Average
        GroupedPoint2D(x: 13, y: 2, group: .s1),
        GroupedPoint2D(x: 22, y: 2, group: .s2),
        GroupedPoint2D(x: 18, y: 2, group: .s3),
        // High score
        GroupedPoint2D(x: 10, y: 3, group: .s1),
        GroupedPoint2D(x: 20, y: 3, group: .s2),
        GroupedPoint2D(x: 40, y: 3, group: .s3)
    ]

    let yLabels: [Int: String] = [0: "Current", 1: "Last", 2: "Average", 3: "High score"]
    let totals:  [Int: Double] = [0: 5.50, 1: 4.20, 2: 5.10, 3: 4.40]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            StackedBarSeries(
                                data: mockData,
                                stackOrder: [.s1, .s2, .s3],
                                colorMapper: { star in
                                    switch star {
                                    case .s1: return .yellow
                                    case .s2: return DemoColors.orange
                                    case .s3: return DemoColors.purple.opacity(0.55)
                                    }
                                },
                                barHeight: 26,
                                cornerRadius: 3,
                                segmentGap: 2
                            )
                        ],
                        xScale: LinearScale(domain: 0...90),
                        yScale: LinearScale(domain: -0.8...3.8),
                        xAxes: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: false,
                                tickCount: 10,
                                labelFormatter: { "\(Int($0))" },
                                showAxisLine: true
                            )
                        ],
                        yAxes: [
                            YAxisConfig(
                                position: .leading,
                                showGrid: false,
                                explicitValues: [0, 1, 2, 3],
                                tickCount: 4,
                                labelFormatter: { [yLabels] v in
                                    yLabels[Int(v.rounded())] ?? ""
                                },
                                width: 78,
                                showAxisLine: true
                            )
                        ],
                        isHorizontalScrollEnabled: false,
                        isHorizontalZoomEnabled: false,
                        isVerticalScrollEnabled: false,
                        isVerticalZoomEnabled: false
                    ) { _ in EmptyView() }
                    .frame(height: 340)

                    DemoLegend(items: [
                        ("Star 1", .yellow),
                        ("Star 2", DemoColors.orange),
                        ("Star 3", DemoColors.purple)
                    ])
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Star Achievement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Animation Showcase

enum AnimationStyleTag: String, Hashable, CaseIterable {
    case draw, morph, fade, none

    var style: ChartAnimationStyle {
        switch self {
        case .draw:  return .draw(.linear(duration: 3.0))
        case .morph: return .morph()
        case .fade:  return .fade()
        case .none:  return .none
        }
    }

    var label: String {
        switch self {
        case .draw:  return "Draw"
        case .morph: return "Morph"
        case .fade:  return "Fade"
        case .none:  return "None"
        }
    }
}

struct AnimationShowcaseView: View {
    @State private var useAltData = false
    @State private var selectedStyleTag: AnimationStyleTag = .draw

    let data1: [Point2D] = [
        Point2D(x: 0, y: 50), Point2D(x: 1, y: 120), Point2D(x: 2, y: 80),
        Point2D(x: 3, y: 150), Point2D(x: 4, y: 90), Point2D(x: 5, y: 180)
    ]

    let data2: [Point2D] = [
        Point2D(x: 0, y: 180), Point2D(x: 1.5, y: 60), Point2D(x: 2, y: 140),
        Point2D(x: 2.5, y: 70), Point2D(x: 4, y: 160), Point2D(x: 5, y: 40)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Picker("Animation Style", selection: $selectedStyleTag) {
                    ForEach(AnimationStyleTag.allCases, id: \.self) { tag in
                        Text(tag.label).tag(tag)
                    }
                }
                .pickerStyle(.segmented)

                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(
                                data: useAltData ? data2 : data1,
                                color: DemoColors.cyan,
                                lineWidth: 4,
                                animation: selectedStyleTag.style
                            )
                        ],
                        xScale: LinearScale(domain: 0...5),
                        yScale: LinearScale(domain: 0...200),
                        xAxes: [XAxisConfig(showGrid: false)],
                        yAxes: [YAxisConfig(gridColor: .white.opacity(0.1), gridLineWidth: 1)]
                    ) { points in
                        if let firstPoint = points.first {
                            Text("\(Int(firstPoint.originalPoint.y)) Value")
                                .font(.caption).bold()
                                .padding(8)
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(height: 340)
                }

                DemoActionButton(title: "Toggle Data", color: DemoColors.cyan) {
                    useAltData.toggle()
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Animations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hybrid Demo

struct HybridChartDemoView: View {
    let mockData: [Point2D] = [
        Point2D(x: 0, y: 40), Point2D(x: 2, y: 150), Point2D(x: 4, y: 80),
        Point2D(x: 6, y: 190), Point2D(x: 8, y: 110), Point2D(x: 10, y: 160)
    ]

    let markers: [PointAnnotation<Double, Double>] = [
        PointAnnotation(x: 2, y: 150, shape: .circle, color: DemoColors.green, size: 12),
        PointAnnotation(x: 6, y: 190, shape: .star, color: .yellow, size: 20, strokeColor: .white, strokeWidth: 2)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    Text("Layered Composition")
                        .font(.headline)
                        .foregroundColor(.white)

                    CartesianChartView(
                        series: [
                            LineSeries(data: mockData, color: DemoColors.cyan, lineWidth: 4)
                        ],
                        xScale: LinearScale(domain: 0...10),
                        yScale: LinearScale(domain: 0...250),
                        xAxes: [XAxisConfig(showGrid: false)],
                        yAxes: [YAxisConfig(gridColor: .gray.opacity(0.2))],
                        pointAnnotations: markers,
                        customViewAnnotations: [
                            CustomViewAnnotation(x: 6, y: 215) {
                                VStack(spacing: 2) {
                                    Image(systemName: "crown.fill").foregroundColor(.yellow)
                                    Text("NEW RECORD")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.yellow)
                                }
                            },
                            CustomViewAnnotation(x: 4, y: 60) {
                                Image(systemName: "arrow.down.circle.fill").foregroundColor(DemoColors.pink)
                            }
                        ]
                    ) { points in
                        if let p = points.first {
                            Text("Value: \(Int(p.originalPoint.y))")
                                .font(.caption).bold()
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                    .frame(height: 350)
                }

                DemoChartPanel {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Cyan line: Core data", systemImage: "line.diagonal")
                        Label("Yellow star: Milestone reached", systemImage: "star.fill")
                        Label("Custom icons: Event markers", systemImage: "flame.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(DemoColors.secondaryText)
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Hybrid View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Live Telemetry

struct LiveTrackingDemoView: View {
    @State private var data: [Point2D] = []
    @State private var timer: Timer?
    @State private var counter: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(data: data, color: DemoColors.green, lineWidth: 3)
                        ],
                        xScale: LinearScale(domain: visibleDomain),
                        yScale: LinearScale(domain: 0...100),
                        isLiveTrackingEnabled: true,
                        emptyState: {
                            AnyView(
                                VStack(spacing: 10) {
                                    ProgressView()
                                    Text("Waiting for signal...")
                                        .font(.subheadline)
                                }
                                .foregroundColor(DemoColors.secondaryText)
                            )
                        }
                    ) { points in
                        if let p = points.last {
                            Text("\(Int(p.originalPoint.y))%")
                                .bold()
                                .padding(4)
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 330)
                }

                DemoActionButton(
                    title: timer == nil ? "Start Telemetry" : "Stop",
                    color: timer == nil ? DemoColors.green : DemoColors.pink,
                    action: toggleTimer
                )
                .frame(maxWidth: 260)
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Live Telemetry")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopTimer()
        }
    }

    var visibleDomain: ClosedRange<Double> {
        let upperBound = max(counter, 20)
        return (upperBound - 20)...upperBound
    }

    func toggleTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                let newPoint = Point2D(x: counter, y: Double.random(in: 40...80))
                data.append(newPoint)
                counter += 0.5
                if data.count > 100 { data.removeFirst() }
            }
        } else {
            stopTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Event Stacking

struct EventStackDemoView: View {
    let mockData: [Point2D] = (0...10).map { Point2D(x: Double($0), y: Double.random(in: 10...50)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(data: mockData, color: DemoColors.secondaryText.opacity(0.7), lineWidth: 2)
                        ],
                        xScale: LinearScale(domain: 0...10),
                        yScale: LinearScale(domain: 0...100),
                        customViewAnnotations: [
                            CustomViewAnnotation(x: 5, y: 50) { InteractiveStackView() }
                        ]
                    )  { _ in EmptyView() }
                    .frame(height: 350)
                }

                DemoHint(text: "Tap the icon to cycle through stacked events.")
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Event Stacking")
        .navigationBarTitleDisplayMode(.inline)
    }

    struct InteractiveStackView: View {
        @State private var topIndex = 0
        let icons = ["sun.max.fill", "cloud.rain.fill", "bolt.fill"]
        let colors: [Color] = [.yellow, DemoColors.cyan, DemoColors.purple]

        var body: some View {
            ZStack {
                ForEach(0..<icons.count, id: \.self) { i in
                    Image(systemName: icons[i])
                        .font(.title)
                        .foregroundColor(colors[i])
                        .offset(x: i == topIndex ? 0 : CGFloat(i * 3), y: i == topIndex ? 0 : CGFloat(i * 3))
                        .opacity(i == topIndex ? 1 : 0.3)
                        .scaleEffect(i == topIndex ? 1.2 : 0.8)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    topIndex = (topIndex + 1) % icons.count
                }
            }
        }
    }
}
