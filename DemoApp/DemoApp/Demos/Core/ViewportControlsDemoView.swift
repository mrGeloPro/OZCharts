//
//  ViewportControlsDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
