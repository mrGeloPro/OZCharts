//
//  AxisViews.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

// MARK: - XAxisView

public struct XAxisView<S: Scale>: View where S.InputType == Double, S.OutputType == CGFloat {
    let scale: S
    let config: XAxisConfig

    private var ticks: [ScaleTick<Double, CGFloat>] {
        ChartTickBuilder.ticks(
            scale: scale,
            explicitValues: config.explicitValues,
            tickCount: config.tickCount,
            strategy: config.tickStrategy,
            formatter: config.labelFormatter
        )
    }

    public var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 0, geometry.size.height > 0 {
                ZStack {
                    if config.showAxisLine {
                        Rectangle()
                            .fill(config.axisLineColor)
                            .frame(height: config.axisLineWidth)
                            .frame(maxHeight: .infinity, alignment: config.position == .top ? .bottom : .top)
                    }

                    ForEach(visibleTicks) { tick in
                        VStack(spacing: config.labelSpacing) {
                            if config.position == .top {
                                Spacer()
                                labelView(for: tick.value)
                                if config.showTicks { tickRect }
                            } else {
                                if config.showTicks { tickRect }
                                labelView(for: tick.value)
                                Spacer()
                            }
                        }
                        .position(x: tick.position, y: geometry.size.height / 2)
                    }
                }
            }
        }
    }

    private var visibleTicks: [ScaleTick<Double, CGFloat>] {
        ChartTickBuilder.filteredTicks(
            ticks,
            strategy: config.labelCollisionStrategy
        )
    }

    @ViewBuilder
    private func labelView(for value: Double) -> some View {
        if let custom = config.customLabelBuilder?(value) {
            custom
        } else {
            Text(config.labelFormatter(value))
                .font(config.font)
                .foregroundColor(config.textColor)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    private var tickRect: some View {
        Rectangle()
            .frame(width: config.tickWidth, height: config.tickLength)
            .foregroundColor(config.tickColor)
    }
}

// MARK: - YAxisView

public struct YAxisView<S: Scale>: View where S.InputType == Double, S.OutputType == CGFloat {
    let scale: S
    let config: YAxisConfig

    private var ticks: [ScaleTick<Double, CGFloat>] {
        ChartTickBuilder.ticks(
            scale: scale,
            explicitValues: config.explicitValues,
            tickCount: config.tickCount,
            strategy: config.tickStrategy,
            formatter: config.labelFormatter
        )
    }

    public var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 0, geometry.size.height > 0 {
                ZStack {
                    if config.showAxisLine {
                        Rectangle()
                            .fill(config.axisLineColor)
                            .frame(width: config.axisLineWidth)
                            .frame(maxWidth: .infinity, alignment: config.position == .leading ? .trailing : .leading)
                    }

                    ForEach(visibleTicks) { tick in
                        HStack(spacing: config.labelSpacing) {
                            if config.position == .leading {
                                Spacer()
                                labelView(for: tick.value)
                                if config.showTicks { tickRect }
                            } else {
                                if config.showTicks { tickRect }
                                labelView(for: tick.value)
                                Spacer()
                            }
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height - tick.position)
                    }
                }
            }
        }
    }

    private var visibleTicks: [ScaleTick<Double, CGFloat>] {
        ChartTickBuilder.filteredTicks(
            ticks,
            strategy: config.labelCollisionStrategy
        )
    }

    @ViewBuilder
    private func labelView(for value: Double) -> some View {
        if let custom = config.customLabelBuilder?(value) {
            custom
        } else {
            Text(config.labelFormatter(value))
                .font(config.font)
                .foregroundColor(config.textColor)
                .lineLimit(1)
                .fixedSize()
        }
    }

    private var tickRect: some View {
        Rectangle()
            .frame(width: config.tickWidth, height: config.tickLength)
            .foregroundColor(config.tickColor)
    }
}
