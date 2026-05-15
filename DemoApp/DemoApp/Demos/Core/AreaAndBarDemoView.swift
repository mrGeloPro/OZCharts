//
//  AreaAndBarDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
