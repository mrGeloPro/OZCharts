//
//  LinkedChartsDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
            .chartSelection(.nearestX, behavior: .tapAndDrag, dismissalPolicy: .persistent)
            .chartSelectionState($selection)
            .chartCrosshair(.vertical(color: tint.opacity(0.75)))
            .frame(height: 220)
        }
    }
}
