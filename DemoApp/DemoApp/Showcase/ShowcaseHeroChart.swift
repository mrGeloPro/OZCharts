//
//  ShowcaseHeroChart.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

struct ShowcaseHeroChart: View {
    var body: some View {
        CartesianChartView(
            series: [
                BarSeries(
                    data: DemoShowcaseData.heroVolume,
                    id: DemoShowcaseSeriesID.heroVolume,
                    color: DemoColors.orange.opacity(0.5),
                    barWidth: 7
                ).eraseToAnyChartSeries(),
                AreaSeries(
                    data: DemoShowcaseData.heroSignal,
                    id: DemoShowcaseSeriesID.heroArea,
                    color: DemoColors.cyan,
                    fillOpacity: 0.18,
                    baseline: 0,
                    lineWidth: 2
                ).eraseToAnyChartSeries(),
                LineSeries(
                    data: DemoShowcaseData.heroSignal,
                    id: DemoShowcaseSeriesID.heroLine,
                    color: DemoColors.green,
                    lineWidth: 2
                ).eraseToAnyChartSeries()
            ],
            xDomain: .fixed(0...14),
            yDomain: .fixed(0...110),
            xAxes: [],
            yAxes: [],
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .chartCrosshair(.hidden)
    }
}

struct FeaturePill: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption2.weight(.bold))
            .foregroundColor(color)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .cornerRadius(999)
    }
}
