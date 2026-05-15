//
//  SelectableAnnotationsDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

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
