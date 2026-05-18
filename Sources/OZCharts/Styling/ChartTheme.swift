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

    public static let darkProduct = ChartTheme(
        foregroundColor: .white,
        secondaryForegroundColor: .white.opacity(0.78),
        gridColor: .white.opacity(0.18),
        axisLineColor: .white.opacity(0.66),
        tickColor: .white.opacity(0.48),
        seriesColors: [
            Color(red: 0.05, green: 0.86, blue: 0.92),
            Color(red: 0.70, green: 0.15, blue: 0.96),
            Color(red: 1.00, green: 0.76, blue: 0.02),
            Color(red: 1.00, green: 0.55, blue: 0.02)
        ]
    )

    public static let dashboard = ChartTheme(
        foregroundColor: .primary,
        secondaryForegroundColor: .secondary,
        gridColor: .gray.opacity(0.16),
        axisLineColor: .gray.opacity(0.28),
        tickColor: .gray.opacity(0.38),
        seriesColors: [
            Color(red: 0.13, green: 0.69, blue: 0.76),
            Color(red: 0.39, green: 0.32, blue: 0.86),
            Color(red: 0.95, green: 0.57, blue: 0.18),
            Color(red: 0.28, green: 0.72, blue: 0.44),
            Color(red: 0.86, green: 0.30, blue: 0.45)
        ]
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

    static func compact(
        position: XAxisPosition = .bottom,
        tickCount: Int = 4,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) -> XAxisConfig {
        XAxisConfig(
            position: position,
            tickStrategy: .nice,
            labelCollisionStrategy: .hideOverlapping(minSpacing: 34),
            gridColor: .gray.opacity(0.14),
            gridLineWidth: 0.75,
            tickCount: tickCount,
            labelFormatter: labelFormatter,
            font: .caption2,
            textColor: .secondary,
            height: 24,
            showAxisLine: false,
            tickLength: 3,
            tickColor: .gray.opacity(0.36),
            labelSpacing: 3
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

    static func compact(
        position: YAxisPosition = .leading,
        tickCount: Int = 4,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) -> YAxisConfig {
        YAxisConfig(
            position: position,
            tickStrategy: .nice,
            labelCollisionStrategy: .hideOverlapping(minSpacing: 28),
            gridColor: .gray.opacity(0.14),
            gridLineWidth: 0.75,
            tickCount: tickCount,
            labelFormatter: labelFormatter,
            font: .caption2,
            textColor: .secondary,
            width: 34,
            showAxisLine: false,
            tickLength: 3,
            tickColor: .gray.opacity(0.36),
            labelSpacing: 3
        )
    }

    static func stackedBarRows(
        values: [Double],
        position: YAxisPosition = .leading,
        width: CGFloat = 88,
        labelSpacing: CGFloat = 6,
        labelInsets: EdgeInsets = EdgeInsets(),
        labelLineLimit: Int? = nil,
        rowLabel: @escaping (Double) -> String?
    ) -> YAxisConfig {
        YAxisConfig(
            position: position,
            showGrid: false,
            explicitValues: values,
            tickStrategy: .regular,
            labelFormatter: { rowLabel($0) ?? String(format: "%.0f", $0) },
            font: .caption,
            textColor: .secondary,
            width: width,
            showAxisLine: false,
            tickLength: 0,
            labelSpacing: labelSpacing,
            labelInsets: labelInsets,
            labelLineLimit: labelLineLimit
        )
    }
}
