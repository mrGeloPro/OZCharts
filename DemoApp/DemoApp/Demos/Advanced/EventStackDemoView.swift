//
//  EventStackDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

// MARK: - Event Stacking

struct EventStackDemoView: View {
    let mockData: [Point2D] = (0...10).map { Point2D(x: Double($0), y: Double.random(in: 10...50)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(data: mockData, id: DemoSeriesID.emptyStateLine, color: DemoColors.secondaryText.opacity(0.7), lineWidth: 2)
                        ],
                        xScale: LinearScale(domain: 0...10),
                        yScale: LinearScale(domain: 0...100),
                        customViewAnnotations: [
                            CustomViewAnnotation(x: 5, y: 50) { InteractiveStackView() }
                        ]
                    )  { _ in EmptyView() }
                    .frame(height: 350)
                }

                DemoHint(text: "Tap the icon to cycle through stacked events.")
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Event Stacking")
        .navigationBarTitleDisplayMode(.inline)
    }

    struct InteractiveStackView: View {
        @State private var topIndex = 0
        let icons = ["sun.max.fill", "cloud.rain.fill", "bolt.fill"]
        let colors: [Color] = [.yellow, DemoColors.cyan, DemoColors.purple]

        var body: some View {
            ZStack {
                ForEach(0..<icons.count, id: \.self) { i in
                    Image(systemName: icons[i])
                        .font(.title)
                        .foregroundColor(colors[i])
                        .offset(x: i == topIndex ? 0 : CGFloat(i * 3), y: i == topIndex ? 0 : CGFloat(i * 3))
                        .opacity(i == topIndex ? 1 : 0.3)
                        .scaleEffect(i == topIndex ? 1.2 : 0.8)
                }
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    topIndex = (topIndex + 1) % icons.count
                }
            }
        }
    }
}
