//
//  HybridChartDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
