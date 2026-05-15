//
//  AnimationShowcaseView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

// MARK: - Animation Showcase

enum AnimationStyleTag: String, Hashable, CaseIterable {
    case draw, morph, fade, none

    var style: ChartAnimationStyle {
        switch self {
        case .draw:  return .draw(.linear(duration: 3.0))
        case .morph: return .morph()
        case .fade:  return .fade()
        case .none:  return .none
        }
    }

    var label: String {
        switch self {
        case .draw:  return "Draw"
        case .morph: return "Morph"
        case .fade:  return "Fade"
        case .none:  return "None"
        }
    }
}

struct AnimationShowcaseView: View {
    @State private var useAltData = false
    @State private var selectedStyleTag: AnimationStyleTag = .draw

    let data1: [Point2D] = [
        Point2D(x: 0, y: 50), Point2D(x: 1, y: 120), Point2D(x: 2, y: 80),
        Point2D(x: 3, y: 150), Point2D(x: 4, y: 90), Point2D(x: 5, y: 180)
    ]

    let data2: [Point2D] = [
        Point2D(x: 0, y: 180), Point2D(x: 1.5, y: 60), Point2D(x: 2, y: 140),
        Point2D(x: 2.5, y: 70), Point2D(x: 4, y: 160), Point2D(x: 5, y: 40)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Picker("Animation Style", selection: $selectedStyleTag) {
                    ForEach(AnimationStyleTag.allCases, id: \.self) { tag in
                        Text(tag.label).tag(tag)
                    }
                }
                .pickerStyle(.segmented)

                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(
                                data: useAltData ? data2 : data1,
                                id: DemoSeriesID.animatedLine,
                                color: DemoColors.cyan,
                                lineWidth: 4,
                                animation: selectedStyleTag.style
                            )
                        ],
                        xScale: LinearScale(domain: 0...5),
                        yScale: LinearScale(domain: 0...200),
                        xAxes: [XAxisConfig(showGrid: false)],
                        yAxes: [YAxisConfig(gridColor: .white.opacity(0.1), gridLineWidth: 1)]
                    ) { points in
                        if let firstPoint = points.first {
                            Text("\(Int(firstPoint.originalPoint.y)) Value")
                                .font(.caption).bold()
                                .padding(8)
                                .background(Color.black.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            EmptyView()
                        }
                    }
                    .frame(height: 340)
                }

                DemoActionButton(title: "Toggle Data", color: DemoColors.cyan) {
                    useAltData.toggle()
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Animations")
        .navigationBarTitleDisplayMode(.inline)
    }
}
