//
//  DonutScoreDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
