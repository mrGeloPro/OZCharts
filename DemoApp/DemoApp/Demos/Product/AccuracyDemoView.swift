//
//  AccuracyDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
                    OZChart(mockData)
                        .violin(
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
                        .domain(x: .fixed(0...100), y: .fixed(330...900))
                        .axes(
                            x: [
                            XAxisConfig(position: .bottom, tickCount: 0, labelFormatter: { _ in "" }, height: 34, title: "ΔT distributions", titleColor: .white)
                            ],
                            y: [
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
                            ]
                        )
                        .annotations(
                            ranges: [
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
                            horizontal: [
                            HorizontalAnnotation(yValue: 500, label: "Target 120 bpm", color: .yellow)
                            ]
                        )
                        .interaction(ChartInteractionOptions(
                            isHorizontalScrollEnabled: false,
                            isVerticalScrollEnabled: true,
                            isHorizontalZoomEnabled: false,
                            isVerticalZoomEnabled: true
                        ))
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
