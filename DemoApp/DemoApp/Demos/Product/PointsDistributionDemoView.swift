//
//  PointsDistributionDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
                    OZChart(layers.stacked)
                        .stackedArea(
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
                        .domain(x: .fixed(0...32), y: .fixed(0...640))
                        .axes(
                            x: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: false,
                                tickCount: 7,
                                labelFormatter: { "\(Int($0))s" },
                                showAxisLine: true
                            )
                            ],
                            y: [
                            YAxisConfig(
                                position: .leading,
                                explicitValues: [0, 100, 200, 300, 400, 500, 600],
                                gridColor: .gray.opacity(0.2),
                                gridLineDash: [4, 4],
                                labelFormatter: { "\(Int($0))" },
                                showAxisLine: true
                            )
                            ]
                        )
                        .staticChart()
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
