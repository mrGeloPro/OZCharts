//
//  ContentView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

private enum DemoSeriesID {
    static let viewportSignal = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    static let linkedPrice = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    static let linkedVolume = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!
    static let selectableLine = UUID(uuidString: "10000000-0000-0000-0000-000000000004")!
    static let mixedBars = UUID(uuidString: "10000000-0000-0000-0000-000000000005")!
    static let mixedTrend = UUID(uuidString: "10000000-0000-0000-0000-000000000006")!
    static let donutScore = UUID(uuidString: "10000000-0000-0000-0000-000000000007")!
    static let productLine = UUID(uuidString: "10000000-0000-0000-0000-000000000008")!
    static let violinAccuracy = UUID(uuidString: "10000000-0000-0000-0000-000000000009")!
    static let pointsDistribution = UUID(uuidString: "10000000-0000-0000-0000-000000000010")!
    static let starAchievement = UUID(uuidString: "10000000-0000-0000-0000-000000000011")!
    static let animatedLine = UUID(uuidString: "10000000-0000-0000-0000-000000000012")!
    static let hybridLine = UUID(uuidString: "10000000-0000-0000-0000-000000000013")!
    static let liveTrackingLine = UUID(uuidString: "10000000-0000-0000-0000-000000000014")!
    static let emptyStateLine = UUID(uuidString: "10000000-0000-0000-0000-000000000015")!
}

private enum DemoAnnotationID {
    static let starTooltip = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!

    static func starScore(row: Int) -> UUID {
        switch row {
        case 0: return UUID(uuidString: "20000000-0000-0000-0000-000000000010")!
        case 1: return UUID(uuidString: "20000000-0000-0000-0000-000000000011")!
        case 2: return UUID(uuidString: "20000000-0000-0000-0000-000000000012")!
        default: return UUID(uuidString: "20000000-0000-0000-0000-000000000013")!
        }
    }
}

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
                                id: DemoSeriesID.viewportSignal,
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
                        id: DemoSeriesID.linkedPrice,
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
                        id: DemoSeriesID.linkedVolume,
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
                        series: [LineSeries(data: data, id: DemoSeriesID.selectableLine, color: DemoColors.cyan, lineWidth: 3)],
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
                                id: DemoSeriesID.mixedBars,
                                color: DemoColors.purple.opacity(0.65),
                                label: "Volume",
                                barWidth: 18
                            ).eraseToAnyChartSeries(),
                            AreaSeries(
                                data: trend,
                                id: DemoSeriesID.mixedTrend,
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
        ("Basic", 85.2, DemoColors.cyan),
        ("Bonus", 11.3, DemoColors.purple),
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
                                id: DemoSeriesID.donutScore,
                                colors: legend.map(\.2),
                                segmentStyles: [
                                    DonutSegmentStyle(
                                        fill: .gradient([DemoColors.cyan, DemoColors.cyan.opacity(0.78)]),
                                        shadow: ChartShadowStyle(color: DemoColors.cyan.opacity(0.28), radius: 8)
                                    ),
                                    DonutSegmentStyle(
                                        fill: .gradient([DemoColors.purple, DemoColors.purple.opacity(0.78)]),
                                        explodedOffset: 10
                                    ),
                                    DonutSegmentStyle(
                                        fill: .gradient([.yellow, DemoColors.orange]),
                                        explodedOffset: 12
                                    )
                                ],
                                thickness: 38,
                                gapAngle: .degrees(9),
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
                    .frame(height: 260)

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
                                id: DemoSeriesID.productLine,
                                color: DemoColors.purple,
                                lineWidth: 4,
                                interpolation: .monotone,
                                strokeStyle: .gradient([DemoColors.purple, DemoColors.pink], startPoint: .leading, endPoint: .trailing),
                                shadow: ChartShadowStyle(color: DemoColors.purple.opacity(0.36), radius: 8),
                                area: AreaStyle(
                                    fillStyle: .gradient([DemoColors.purple.opacity(0.34), DemoColors.purple.opacity(0.02)]),
                                    baseline: 0
                                )
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
                        },
                        tooltipContent: { points in
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
                    )
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
    let mockData: [GroupedPoint2D<ViolinGroup>] = {
        var rng = SystemRandomSource(seed: 7_120)
        var points: [GroupedPoint2D<ViolinGroup>] = []

        for i in 0..<72 {
            let core = 500 + rng.gauss() * 42
            let tail = rng.uniform() > 0.72 ? 650 + rng.gauss() * 70 : core
            let y = min(900, max(330, tail))
            let x = 50 - 5 - rng.uniform() * 22
            points.append(GroupedPoint2D(id: UUID(uuidString: "00000000-0000-0000-0000-\(String(format: "%012d", i))")!, x: x, y: y, group: .result))
        }

        for i in 0..<48 {
            let core = 462 + rng.gauss() * 30
            let tail = rng.uniform() > 0.82 ? 545 + rng.gauss() * 24 : core
            let y = min(900, max(330, tail))
            let x = 50 + 5 + rng.uniform() * 20
            points.append(GroupedPoint2D(id: UUID(uuidString: "00000000-0000-0000-0001-\(String(format: "%012d", i))")!, x: x, y: y, group: .best))
        }

        return points
    }()

    private let deltaTicks: [Double] = [330, 400, 500, 600, 700, 800, 900]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            ViolinSeries(
                                data: mockData,
                                id: DemoSeriesID.violinAccuracy,
                                centerX: 50,
                                maxHalfWidth: 40,
                                sideMapper: { $0 == .result ? .left : .right },
                                colorMapper: { $0 == .result ? DemoColors.cyan : DemoColors.purple },
                                fillStyleMapper: { group in
                                    group == .result
                                        ? .gradient([DemoColors.cyan.opacity(0.58), DemoColors.cyan.opacity(0.24)], startPoint: .leading, endPoint: .trailing)
                                        : .gradient([DemoColors.purple.opacity(0.58), DemoColors.purple.opacity(0.24)], startPoint: .trailing, endPoint: .leading)
                                },
                                shadow: ChartShadowStyle(color: DemoColors.cyan.opacity(0.18), radius: 8)
                            )
                        ],
                        xScale: LinearScale(domain: 0...100),
                        yScale: LinearScale(domain: 330...900),
                        xAxes: [
                            XAxisConfig(position: .bottom, tickCount: 0, labelFormatter: { _ in "" }, height: 34, title: "ΔT distributions", titleColor: .white)
                        ],
                        yAxes: [
                            YAxisConfig(position: .leading, explicitValues: deltaTicks, labelFormatter: { "\(Int($0))" }, width: 62, title: "ΔT (ms)", titleColor: .white),
                            YAxisConfig(
                                position: .trailing,
                                explicitValues: deltaTicks,
                                axisTransform: AxisTransform { delta in
                                    Int(delta.rounded()) == 330 ? 200 : 60_000 / delta
                                },
                                labelFormatter: { "\(Int($0))" },
                                width: 74,
                                title: "Rhythm (bpm)",
                                titleColor: .white
                            )
                        ],
                        rangeAnnotations: [
                            RangeAnnotation(
                                yRange: 496...504,
                                label: "Target 120 bpm",
                                color: .yellow,
                                opacity: 0,
                                labelColor: .yellow,
                                labelFont: .caption2.weight(.semibold),
                                showsLabel: true,
                                labelXPosition: 0.62,
                                labelAnchor: .leading,
                                labelYOffset: -16
                            )
                        ],
                        horizontalAnnotations: [
                            HorizontalAnnotation(yValue: 500, label: "Target 120 bpm", color: .yellow)
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

enum PointsLayer: Hashable { case basic, bonus, streak }

struct PointsDistributionDemoView: View {
    struct LayerData {
        let basic:  [Point2D]
        let bonus:  [Point2D]
        let streak: [Point2D]
        let stacked: [GroupedPoint2D<PointsLayer>]
    }

    let layers: LayerData = {
        var basic:  [Point2D] = []
        var bonus:  [Point2D] = []
        var streak: [Point2D] = []
        var stacked: [GroupedPoint2D<PointsLayer>] = []
        let xValues: [Double] = [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 13, 14, 17, 19, 21, 23, 25, 27, 28, 30, 32]

        for (i, x) in xValues.enumerated() {
            let basicY  = 60 + Double(i) * 18
            let bonusDelta = 40 + Double(i) * 3
            let streakDelta = 35 + Double(i) * 2
            let bonusY  = basicY + bonusDelta
            let streakY = bonusY + streakDelta
            basic.append(Point2D(x: x, y: basicY))
            bonus.append(Point2D(x: x, y: bonusY))
            streak.append(Point2D(x: x, y: streakY))
            stacked.append(GroupedPoint2D(x: x, y: basicY, group: .basic))
            stacked.append(GroupedPoint2D(x: x, y: bonusDelta, group: .bonus))
            stacked.append(GroupedPoint2D(x: x, y: streakDelta, group: .streak))
        }
        return LayerData(basic: basic, bonus: bonus, streak: streak, stacked: stacked)
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
                            StackedAreaSeries(
                                data: layers.stacked,
                                id: DemoSeriesID.pointsDistribution,
                                stackOrder: [.basic, .bonus, .streak],
                                colorMapper: { layer in
                                    switch layer {
                                    case .basic: return DemoColors.cyan
                                    case .bonus: return DemoColors.purple
                                    case .streak: return .yellow
                                    }
                                },
                                fillStyleMapper: { layer in
                                    switch layer {
                                    case .basic:
                                        return .gradient([DemoColors.cyan.opacity(0.36), DemoColors.cyan.opacity(0.10)])
                                    case .bonus:
                                        return .gradient([DemoColors.purple.opacity(0.38), DemoColors.purple.opacity(0.12)])
                                    case .streak:
                                        return .gradient([Color.yellow.opacity(0.34), DemoColors.orange.opacity(0.10)])
                                    }
                                },
                                interpolation: .step,
                                lineWidth: 3,
                                shadow: ChartShadowStyle(color: DemoColors.cyan.opacity(0.16), radius: 6)
                            )
                        ],
                        xScale: LinearScale(domain: 0...32),
                        yScale: LinearScale(domain: 0...640),
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
                                explicitValues: [0, 100, 200, 300, 400, 500, 600],
                                gridColor: .gray.opacity(0.2),
                                gridLineDash: [4, 4],
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

enum StarType: Hashable { case s1, s2, s3, remainder }

struct StarAchievementDemoView: View {
    @State private var selectedElement: ChartSelectedElement?

    private let tooltipContentWidth: CGFloat = 156
    private let tooltipHorizontalPadding: CGFloat = 10
    private let tooltipCanvasPadding: CGFloat = 6
    private let tooltipArrowInset: CGFloat = 16

    /// y=0 Current, y=1 Last, y=2 Average, y=3 High score.
    let mockData: [GroupedPoint2D<StarType>] = [
        // Current
        GroupedPoint2D(x: 12, y: 0, group: .s1),
        GroupedPoint2D(x: 20, y: 0, group: .s2),
        GroupedPoint2D(x: 23, y: 0, group: .s3),
        GroupedPoint2D(x: 0, y: 0, group: .remainder),
        // Last
        GroupedPoint2D(x: 10, y: 1, group: .s1),
        GroupedPoint2D(x: 18, y: 1, group: .s2),
        GroupedPoint2D(x: 14, y: 1, group: .s3),
        GroupedPoint2D(x: 43, y: 1, group: .remainder),
        // Average
        GroupedPoint2D(x: 13, y: 2, group: .s1),
        GroupedPoint2D(x: 22, y: 2, group: .s2),
        GroupedPoint2D(x: 18, y: 2, group: .s3),
        GroupedPoint2D(x: 32, y: 2, group: .remainder),
        // High score
        GroupedPoint2D(x: 10, y: 3, group: .s1),
        GroupedPoint2D(x: 20, y: 3, group: .s2),
        GroupedPoint2D(x: 40, y: 3, group: .s3),
        GroupedPoint2D(x: 16, y: 3, group: .remainder)
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
                                id: DemoSeriesID.starAchievement,
                                stackOrder: [.s1, .s2, .s3, .remainder],
                                colorMapper: { star in
                                    switch star {
                                    case .s1: return .yellow
                                    case .s2: return Color(red: 1.00, green: 0.72, blue: 0.00)
                                    case .s3: return DemoColors.orange
                                    case .remainder: return DemoColors.surface
                                    }
                                },
                                fillStyleMapper: { star in
                                    switch star {
                                    case .s1: return .gradient([.yellow, Color.yellow.opacity(0.86)], startPoint: .leading, endPoint: .trailing)
                                    case .s2: return .gradient([Color.yellow.opacity(0.92), DemoColors.orange], startPoint: .leading, endPoint: .trailing)
                                    case .s3: return .gradient([DemoColors.orange, Color.orange], startPoint: .leading, endPoint: .trailing)
                                    case .remainder:
                                        return .stripes(
                                            foreground: Color.white.opacity(0.12),
                                            background: DemoColors.surface.opacity(0.70),
                                            lineWidth: 3,
                                            spacing: 9
                                        )
                                    }
                                },
                                barHeight: 26,
                                cornerRadius: 3,
                                segmentGap: 2
                            )
                        ],
                        xScale: LinearScale(domain: 0...100),
                        yScale: LinearScale(domain: -0.8...3.8),
                        xAxes: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: false,
                                explicitValues: stride(from: 0.0, through: 90.0, by: 10.0).map { $0 },
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
                                labelFormatter: { [yLabels] v in yLabels[Int(v.rounded())] ?? "" },
                                width: 78,
                                showAxisLine: true,
                                customLabelBuilder: { [yLabels] value in
                                    let index = Int(value.rounded())
                                    let title = yLabels[index] ?? ""
                                    let display = index == 3 ? "High\nscore" : title
                                    return AnyView(
                                        Text(display)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: true, vertical: true)
                                    )
                                }
                            )
                        ],
                        customViewAnnotations: starAnnotations,
                        isHorizontalScrollEnabled: false,
                        isHorizontalZoomEnabled: false,
                        isVerticalScrollEnabled: false,
                        isVerticalZoomEnabled: false
                    ) { _ in
                        EmptyView()
                    }
                    .chartSelection(.none, behavior: .tapAndDrag, clearsOnEnd: false)
                    .chartElementSelection { elements in
                        selectedElement = elements.first
                    }
                    .frame(height: 340)

                    DemoLegend(items: [
                        ("Star 1", .yellow),
                        ("Star 2", Color(red: 1.00, green: 0.72, blue: 0.00)),
                        ("Star 3", DemoColors.orange)
                    ])
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Star Achievement")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var starAnnotations: [CustomViewAnnotation<Double, Double>] {
        var annotations = scoreLabels
        if let tooltipAnnotation {
            annotations.append(tooltipAnnotation)
        }
        return annotations
    }

    private var scoreLabels: [CustomViewAnnotation<Double, Double>] {
        totals.map { row, score in
            CustomViewAnnotation(id: DemoAnnotationID.starScore(row: row), x: 94, y: Double(row)) {
                Text(String(format: "%.2f", score))
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .fixedSize()
            }
        }
    }

    private var tooltipAnnotation: CustomViewAnnotation<Double, Double>? {
        guard
            let selectedElement,
            let rowValue = selectedElement.y,
            let pointID = selectedElement.pointID,
            let selectedPoint = mockData.first(where: { $0.id == pointID })
        else { return nil }

        let row = Int(rowValue.rounded())
        let placement = tooltipPlacement(for: row)
        let geometry = tooltipGeometry(
            for: selectedElement,
            targetX: segmentCenterX(row: row, group: selectedPoint.group)
        )
        return CustomViewAnnotation(
            id: DemoAnnotationID.starTooltip,
            x: geometry.centerX,
            y: Double(row),
            placement: placement.chartPlacement,
            collisionPriority: 100,
            avoidsCollisions: false,
            padding: 6
        ) {
            StarAchievementTooltip(
                rowTitle: yLabels[row] ?? "Result",
                lines: selectedStarLines(for: row),
                arrowEdge: placement.arrowEdge,
                arrowXOffset: geometry.arrowXOffset
            )
        }
    }

    private func selectedStarLines(for row: Int) -> [String] {
        let segments = visibleSegments(for: row, includingRemainder: false)
        var cumulative = 0.0

        return segments.enumerated().map { index, item in
            cumulative += item.value
            let title = starTitle(for: item.group)
            let minutesValue = index == 0 ? item.value / 10 : cumulative / 10
            let suffix = index == 0 ? "" : " (total)"
            return "\(title): \(String(format: "%.2f", minutesValue))min\(suffix)"
        }
    }

    private func tooltipPlacement(for row: Int) -> StarTooltipPlacement {
        switch row {
        case 0, 1: return .above
        default: return .below
        }
    }

    private func segmentCenterX(row: Int, group selectedGroup: StarType) -> Double {
        var cursor = 0.0
        for segment in visibleSegments(for: row, includingRemainder: true) {
            let center = cursor + segment.value / 2
            if segment.group == selectedGroup {
                return center
            }
            cursor += segment.value
        }
        return 50
    }

    private func tooltipGeometry(for element: ChartSelectedElement, targetX: Double) -> StarTooltipGeometry {
        guard
            let value = element.value,
            value > 0,
            element.bounds.width > 0
        else {
            return StarTooltipGeometry(centerX: targetX, arrowXOffset: 0)
        }

        let pointsPerDomainUnit = element.bounds.width / CGFloat(value)
        let canvasWidth = max(pointsPerDomainUnit * 100, 1)
        let targetPixelX = element.position.x
        let halfTooltipWidth = (tooltipContentWidth + tooltipHorizontalPadding * 2) / 2
        let minCenterX = tooltipCanvasPadding + halfTooltipWidth
        let maxCenterX = max(minCenterX, canvasWidth - tooltipCanvasPadding - halfTooltipWidth)
        let centerPixelX = min(max(targetPixelX, minCenterX), maxCenterX)
        let maxArrowOffset = max(0, halfTooltipWidth - tooltipArrowInset)
        let arrowXOffset = min(max(targetPixelX - centerPixelX, -maxArrowOffset), maxArrowOffset)
        let centerX = Double(centerPixelX / canvasWidth * 100)
        return StarTooltipGeometry(centerX: centerX, arrowXOffset: arrowXOffset)
    }

    private func visibleSegments(for row: Int, includingRemainder: Bool) -> [(group: StarType, value: Double)] {
        mockData
            .filter { Int($0.y.rounded()) == row && (includingRemainder || $0.group != .remainder) }
            .sorted { lhs, rhs in
                starOrder(lhs.group) < starOrder(rhs.group)
            }
            .map { ($0.group, $0.x) }
    }

    private func starTitle(for star: StarType) -> String {
        switch star {
        case .s1: return "Star 1"
        case .s2: return "Star 2"
        case .s3: return "Star 3"
        case .remainder: return ""
        }
    }

    private func starOrder(_ star: StarType) -> Int {
        switch star {
        case .s1: return 0
        case .s2: return 1
        case .s3: return 2
        case .remainder: return 3
        }
    }
}

private struct StarTooltipGeometry {
    let centerX: Double
    let arrowXOffset: CGFloat
}

private enum StarTooltipPlacement {
    case above
    case below

    var chartPlacement: ChartLabelPlacement {
        switch self {
        case .above: return .top
        case .below: return .bottom
        }
    }

    var arrowEdge: StarTooltipArrowEdge {
        switch self {
        case .above: return .bottom
        case .below: return .top
        }
    }
}

private enum StarTooltipArrowEdge {
    case top
    case bottom
}

private struct StarAchievementTooltip: View {
    let rowTitle: String
    let lines: [String]
    let arrowEdge: StarTooltipArrowEdge
    let arrowXOffset: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(rowTitle)
                .font(.caption2.weight(.bold))
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.caption2.weight(.semibold))
            }
        }
        .frame(width: 156, alignment: .leading)
        .chartCalloutStyle(.productLight)
        .overlay(alignment: arrowEdge == .top ? .top : .bottom) {
            TooltipTriangle(pointsTo: arrowEdge)
                .fill(Color.white)
                .frame(width: 14, height: 8)
                .offset(x: arrowXOffset, y: arrowEdge == .top ? -7 : 7)
        }
    }
}

private struct TooltipTriangle: Shape {
    let pointsTo: StarTooltipArrowEdge

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch pointsTo {
        case .top:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .bottom:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
        path.closeSubpath()
        return path
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
                                id: DemoSeriesID.animatedLine,
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
                            LineSeries(data: mockData, id: DemoSeriesID.hybridLine, color: DemoColors.cyan, lineWidth: 4)
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
    @State private var viewport = ChartViewportState.automatic
    @State private var pausedBehavior = ChartLiveTrackingPausedBehavior.freezeVisibleWindow

    private let visibleWindow: Double = 20
    private let historyWindow: Double = 120

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(data: data, id: DemoSeriesID.liveTrackingLine, color: DemoColors.green, lineWidth: 3)
                        ],
                        xScale: LinearScale(domain: fullDomain),
                        yScale: LinearScale(domain: 0...100),
                        isLiveTrackingEnabled: true,
                        liveTrackingMode: .followLatest(
                            pauseOnUserInteraction: true,
                            pausedBehavior: pausedBehavior
                        ),
                        initialViewport: .xWindow(length: visibleWindow, anchor: .trailing),
                        viewport: $viewport,
                        emptyState: {
                            AnyView(
                                VStack(spacing: 10) {
                                    ProgressView()
                                    Text("Waiting for signal...")
                                        .font(.subheadline)
                                }
                                .foregroundColor(DemoColors.secondaryText)
                            )
                        },
                        tooltipContent: { points in
                            if let p = points.last {
                                Text("\(Int(p.originalPoint.y))%")
                                    .bold()
                                    .padding(4)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                    )
                    .frame(height: 330)
                }

                Picker("Paused Behavior", selection: $pausedBehavior) {
                    Text("Freeze").tag(ChartLiveTrackingPausedBehavior.freezeVisibleWindow)
                    Text("Delayed").tag(ChartLiveTrackingPausedBehavior.preserveTrailingOffset)
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    DemoHint(text: statusText)

                    if viewport.liveTrackingStatus == .pausedByUser {
                        DemoActionButton(
                            title: "Jump to Latest",
                            color: DemoColors.green,
                            action: { viewport.requestJumpToLatest() }
                        )
                        .frame(maxWidth: 180)
                    }
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

    var statusText: String {
        switch viewport.liveTrackingStatus {
        case .inactive:
            return "Live tracking inactive"
        case .followingLatest:
            return "Live"
        case .pausedByUser:
            return pausedBehavior == .freezeVisibleWindow ? "Viewing frozen history" : "Viewing delayed live"
        }
    }

    var fullDomain: ClosedRange<Double> {
        let upperBound = max(counter, visibleWindow)
        let lowerBound = max(0, upperBound - historyWindow)
        return lowerBound...upperBound
    }

    func toggleTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                let newPoint = Point2D(x: counter, y: Double.random(in: 40...80))
                data.append(newPoint)
                counter += 0.5
                data.removeAll { $0.x < fullDomain.lowerBound }
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
                            LineSeries(data: mockData, id: DemoSeriesID.emptyStateLine, color: DemoColors.secondaryText.opacity(0.7), lineWidth: 2)
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
