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
    @State private var selectedSegment: ChartSelectedElement?

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
                    OZDonutChart(
                        mockData,
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
                        segmentLabelMapper: { point in
                            let index = Int(point.x)
                            return legend.indices.contains(index) ? legend[index].0 : nil
                        },
                        thickness: 38,
                        gapAngle: .degrees(9),
                        startAngle: .degrees(-90),
                        lineCap: .butt
                    )
                    .onSelection { selection in
                        selectedSegment = selection.primaryElement
                    }
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

                    if let selectedSegment {
                        Text("\(selectedSegment.label ?? "Segment") - \(String(format: "%.1f", selectedSegment.value ?? 0))%")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 2)
                    }
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Total Score")
        .navigationBarTitleDisplayMode(.inline)
    }
}
