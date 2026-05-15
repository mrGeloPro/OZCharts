//
//  HeightDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
