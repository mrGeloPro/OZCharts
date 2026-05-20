//
//  OZChart+Series.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public extension OZChart {
    func line(
        id: UUID? = nil,
        color: Color,
        label: String? = nil,
        lineWidth: CGFloat = 2,
        dash: [CGFloat] = [],
        dashPhase: CGFloat = 0,
        lineCap: CGLineCap = .round,
        interpolation: LineInterpolation = .linear,
        strokeStyle: ChartFillStyle? = nil,
        shadow: ChartShadowStyle? = nil,
        area: AreaStyle? = nil,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            LineSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .line),
                color: color,
                label: label,
                lineWidth: lineWidth,
                dash: dash,
                dashPhase: dashPhase,
                lineCap: lineCap,
                interpolation: interpolation,
                strokeStyle: strokeStyle,
                shadow: shadow,
                area: area,
                downsampling: downsampling,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    func line(
        id: UUID? = nil,
        style: LineSeriesStyle,
        label: String? = nil,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            LineSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .line),
                label: label,
                style: style,
                downsampling: downsampling,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    func area(
        id: UUID? = nil,
        color: Color,
        fillColor: Color? = nil,
        fillStyle: ChartFillStyle? = nil,
        label: String? = nil,
        fillOpacity: Double = 0.2,
        baseline: Double? = nil,
        lineWidth: CGFloat = 2,
        interpolation: LineInterpolation = .linear,
        strokeStyle: ChartFillStyle? = nil,
        shadow: ChartShadowStyle? = nil,
        downsampling: ChartDownsampling = .none,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            AreaSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .area),
                color: color,
                fillColor: fillColor ?? color,
                fillStyle: fillStyle,
                fillOpacity: fillOpacity,
                baseline: baseline,
                label: label,
                lineWidth: lineWidth,
                interpolation: interpolation,
                strokeStyle: strokeStyle,
                shadow: shadow,
                downsampling: downsampling,
                animation: animation,
                zIndex: zIndex
            )
        )
    }

    func bar(
        id: UUID? = nil,
        color: Color,
        label: String? = nil,
        barWidth: CGFloat = 10,
        cornerRadius: CGFloat = 2,
        baseline: Double = 0,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            BarSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .bar),
                color: color,
                label: label,
                barWidth: barWidth,
                cornerRadius: cornerRadius,
                baseline: baseline,
                zIndex: zIndex
            )
        )
    }

    func scatter(
        id: UUID? = nil,
        color: Color,
        label: String? = nil,
        pointSize: CGFloat = 6,
        symbol: ChartSymbolShape = .circle,
        zIndex: Int = 0
    ) -> Self {
        addingSeries(
            ScatterSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .scatter),
                color: color,
                label: label,
                pointSize: pointSize,
                symbol: symbol,
                zIndex: zIndex
            )
        )
    }

    func donut(
        id: UUID? = nil,
        colors: [Color],
        segmentStyles: [DonutSegmentStyle] = [],
        label: String? = nil,
        segmentLabelMapper: ((Point) -> String?)? = nil,
        thickness: CGFloat = 40,
        gapAngle: Angle = .degrees(6),
        startAngle: Angle = .degrees(-90),
        lineCap: CGLineCap = .butt,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) -> Self {
        var copy = addingSeries(
            DonutSeries(
                data: sourceData,
                id: id ?? defaultSeriesID(kind: .donut),
                colors: colors,
                segmentStyles: segmentStyles,
                label: label,
                segmentLabelMapper: segmentLabelMapper,
                thickness: thickness,
                gapAngle: gapAngle,
                startAngle: startAngle,
                lineCap: lineCap,
                animation: animation,
                zIndex: zIndex
            )
        )
        if copy.xAxes == nil, copy.yAxes == nil {
            copy = copy.hiddenAxes()
        }
        copy.interactionOptions = .static
        return copy
    }
}

extension OZChart {
    func addingSeries<S: ChartSeriesProtocol>(_ chartSeries: S) -> Self where S.Point == Point {
        var copy = self
        copy.series.append(chartSeries.eraseToAnyChartSeries())
        return copy
    }

    func defaultSeriesID(kind: OZChartSeriesKind) -> UUID {
        stableSeriesID(kind: kind, index: series.count)
    }

    private func stableSeriesID(kind: OZChartSeriesKind, index: Int) -> UUID {
        let value = UInt64(index)
        return UUID(
            uuid: (
                0x4F, 0x5A, 0x43, 0x68,
                0x61, 0x72,
                kind.rawValue,
                0x00,
                UInt8((value >> 56) & 0xFF),
                UInt8((value >> 48) & 0xFF),
                UInt8((value >> 40) & 0xFF),
                UInt8((value >> 32) & 0xFF),
                UInt8((value >> 24) & 0xFF),
                UInt8((value >> 16) & 0xFF),
                UInt8((value >> 8) & 0xFF),
                UInt8(value & 0xFF)
            )
        )
    }
}

enum OZChartSeriesKind: UInt8 {
    case line = 0x01
    case area = 0x02
    case bar = 0x03
    case scatter = 0x04
    case donut = 0x05
    case stackedArea = 0x06
    case stackedBar = 0x07
    case violin = 0x08
}
