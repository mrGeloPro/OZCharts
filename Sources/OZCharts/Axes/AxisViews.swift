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
                        VStack(spacing: 0) {
                            if config.position == .top {
                                Spacer()
                                labelView(for: tick.value)
                                labelAxisGap
                                if config.showTicks { tickRect }
                            } else {
                                if config.showTicks { tickRect }
                                labelAxisGap
                                labelView(for: tick.value)
                                Spacer()
                            }
                        }
                        .position(x: tick.position, y: geometry.size.height / 2)
                    }

                    if let title = config.title {
                        Text(title)
                            .font(config.titleFont)
                            .foregroundColor(config.titleColor)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .position(
                                x: geometry.size.width / 2,
                                y: config.position == .top ? 8 : geometry.size.height - 8
                            )
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
        let displayValue = config.axisTransform(value)
        Group {
            if let custom = config.customLabelBuilder?(displayValue) {
                custom
            } else {
                Text(config.labelFormatter(displayValue))
                    .font(config.font)
                    .foregroundColor(config.textColor)
                    .lineLimit(config.labelLineLimit)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(config.labelInsets)
        .frame(
            width: config.labelReservedSize?.width,
            height: config.labelReservedSize?.height,
            alignment: config.labelAlignment
        )
    }

    private var tickRect: some View {
        Rectangle()
            .frame(width: config.tickWidth, height: config.tickLength)
            .foregroundColor(config.tickColor)
    }

    private var labelAxisGap: some View {
        Color.clear.frame(height: config.labelSpacing)
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
                        HStack(spacing: 0) {
                            if config.position == .leading {
                                Spacer()
                                labelView(for: tick.value)
                                labelAxisGap
                                if config.showTicks { tickRect }
                            } else {
                                if config.showTicks { tickRect }
                                labelAxisGap
                                labelView(for: tick.value)
                                Spacer()
                            }
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height - tick.position)
                    }

                    if let title = config.title {
                        Text(title)
                            .font(config.titleFont)
                            .foregroundColor(config.titleColor)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .rotationEffect(.degrees(config.position == .leading ? -90 : 90))
                            .position(
                                x: config.position == .leading ? 9 : geometry.size.width - 9,
                                y: geometry.size.height / 2
                            )
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
        let displayValue = config.axisTransform(value)
        Group {
            if let custom = config.customLabelBuilder?(displayValue) {
                custom
            } else {
                Text(config.labelFormatter(displayValue))
                    .font(config.font)
                    .foregroundColor(config.textColor)
                    .multilineTextAlignment(config.position == .leading ? .trailing : .leading)
                    .lineLimit(config.labelLineLimit)
                    .fixedSize(horizontal: true, vertical: true)
            }
        }
        .padding(config.labelInsets)
        .frame(
            width: config.labelReservedSize?.width,
            height: config.labelReservedSize?.height,
            alignment: config.labelAlignment
        )
    }

    private var tickRect: some View {
        Rectangle()
            .frame(width: config.tickLength, height: config.tickWidth)
            .foregroundColor(config.tickColor)
    }

    private var labelAxisGap: some View {
        Color.clear.frame(width: config.labelSpacing)
    }
}
