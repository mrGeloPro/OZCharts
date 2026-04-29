//
//  ChartTheme.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct ChartTheme {
    public var foregroundColor: Color
    public var secondaryForegroundColor: Color
    public var gridColor: Color
    public var axisLineColor: Color
    public var tickColor: Color
    public var seriesColors: [Color]

    public init(
        foregroundColor: Color,
        secondaryForegroundColor: Color,
        gridColor: Color,
        axisLineColor: Color,
        tickColor: Color,
        seriesColors: [Color]
    ) {
        self.foregroundColor = foregroundColor
        self.secondaryForegroundColor = secondaryForegroundColor
        self.gridColor = gridColor
        self.axisLineColor = axisLineColor
        self.tickColor = tickColor
        self.seriesColors = seriesColors
    }

    public static let light = ChartTheme(
        foregroundColor: .primary,
        secondaryForegroundColor: .secondary,
        gridColor: .gray.opacity(0.22),
        axisLineColor: .gray.opacity(0.45),
        tickColor: .gray.opacity(0.55),
        seriesColors: [.blue, .green, .orange, .pink, .purple]
    )

    public static let dark = ChartTheme(
        foregroundColor: .white,
        secondaryForegroundColor: .gray,
        gridColor: .white.opacity(0.14),
        axisLineColor: .white.opacity(0.22),
        tickColor: .white.opacity(0.28),
        seriesColors: [.cyan, .yellow, .mint, .pink, .orange]
    )

    public static let `default` = ChartTheme.light

    public func xAxis(
        position: XAxisPosition = .bottom,
        tickCount: Int = 5,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) -> XAxisConfig {
        XAxisConfig(
            position: position,
            gridColor: gridColor,
            tickCount: tickCount,
            labelFormatter: labelFormatter,
            textColor: secondaryForegroundColor,
            showAxisLine: true,
            axisLineColor: axisLineColor,
            tickColor: tickColor
        )
    }

    public func yAxis(
        position: YAxisPosition = .leading,
        tickCount: Int = 5,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) -> YAxisConfig {
        YAxisConfig(
            position: position,
            gridColor: gridColor,
            tickCount: tickCount,
            labelFormatter: labelFormatter,
            textColor: secondaryForegroundColor,
            showAxisLine: true,
            axisLineColor: axisLineColor,
            tickColor: tickColor
        )
    }
}

public extension XAxisConfig {
    static func hidden(position: XAxisPosition = .bottom) -> XAxisConfig {
        XAxisConfig(
            position: position,
            showGrid: false,
            showTicks: false,
            textColor: .clear,
            height: 0,
            showAxisLine: false
        )
    }

    static func time(
        position: XAxisPosition = .bottom,
        tickCount: Int = 6,
        suffix: String = "s"
    ) -> XAxisConfig {
        XAxisConfig(
            position: position,
            tickCount: tickCount,
            labelFormatter: { "\(Int($0))\(suffix)" }
        )
    }

    static func date(
        position: XAxisPosition = .bottom,
        tickCount: Int = 6,
        format: Date.FormatStyle = .dateTime.month().day()
    ) -> XAxisConfig {
        XAxisConfig(
            position: position,
            tickCount: tickCount,
            labelFormatter: { Date(timeIntervalSince1970: $0).formatted(format) }
        )
    }
}

public extension YAxisConfig {
    static func hidden(position: YAxisPosition = .leading) -> YAxisConfig {
        YAxisConfig(
            position: position,
            showGrid: false,
            showTicks: false,
            textColor: .clear,
            width: 0,
            showAxisLine: false
        )
    }

    static func percent(
        position: YAxisPosition = .leading,
        tickCount: Int = 5,
        fractionValues: Bool = false
    ) -> YAxisConfig {
        YAxisConfig(
            position: position,
            tickCount: tickCount,
            labelFormatter: { value in
                let percent = fractionValues ? value * 100 : value
                return "\(Int(percent))%"
            }
        )
    }
}
