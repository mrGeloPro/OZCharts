//
//  AxisConfiguration.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public enum XAxisPosition { case top, bottom }
public enum YAxisPosition { case leading, trailing }

// MARK: - AxisTransform

public struct AxisTransform {
    private let transform: (Double) -> Double

    public init(_ transform: @escaping (Double) -> Double) {
        self.transform = transform
    }

    public func callAsFunction(_ value: Double) -> Double {
        transform(value)
    }

    public static let identity = AxisTransform { $0 }

    public static func linear(multiplier: Double = 1, offset: Double = 0) -> AxisTransform {
        AxisTransform { $0 * multiplier + offset }
    }

    public static func offset(_ value: Double) -> AxisTransform {
        linear(offset: value)
    }

    public static func percentage(of total: Double) -> AxisTransform {
        AxisTransform { value in
            guard total != 0 else { return 0 }
            return value / total * 100
        }
    }

    public static func reciprocal(numerator: Double) -> AxisTransform {
        AxisTransform { value in
            guard value != 0 else { return 0 }
            return numerator / value
        }
    }

    public func clamped(to range: ClosedRange<Double>) -> AxisTransform {
        AxisTransform { value in
            let transformed = self(value)
            guard transformed.isFinite else { return transformed }
            return min(max(transformed, range.lowerBound), range.upperBound)
        }
    }

    public func replacingNonFinite(with fallback: Double) -> AxisTransform {
        AxisTransform { value in
            let transformed = self(value)
            return transformed.isFinite ? transformed : fallback
        }
    }

    public func combined(with next: AxisTransform) -> AxisTransform {
        AxisTransform { next(self($0)) }
    }
}

// MARK: - XAxisConfig

public struct XAxisConfig {
    public var position: XAxisPosition
    public var showGrid: Bool
    public var showTicks: Bool
    public var explicitValues: [Double]?
    public var tickStrategy: ChartTickStrategy
    public var labelCollisionStrategy: ChartLabelCollisionStrategy
    public var gridColor: Color
    public var gridLineWidth: CGFloat
    public var gridLineDash: [CGFloat]
    public var tickCount: Int
    public var axisTransform: AxisTransform
    public var labelFormatter: (Double) -> String
    public var font: Font
    public var textColor: Color
    public var height: CGFloat
    public var showAxisLine: Bool
    public var axisLineColor: Color
    public var axisLineWidth: CGFloat
    public var tickLength: CGFloat
    public var tickColor: Color
    public var tickWidth: CGFloat
    public var labelSpacing: CGFloat
    public var labelLineLimit: Int?
    public var customLabelBuilder: ((Double) -> AnyView)?
    public var title: String?
    public var titleFont: Font
    public var titleColor: Color

    public init(
        position: XAxisPosition                 = .bottom,
        showGrid: Bool                          = true,
        showTicks: Bool                         = true,
        explicitValues: [Double]?               = nil,
        tickStrategy: ChartTickStrategy          = .regular,
        labelCollisionStrategy: ChartLabelCollisionStrategy = .showAll,
        gridColor: Color                        = .gray.opacity(0.3),
        gridLineWidth: CGFloat                  = 1,
        gridLineDash: [CGFloat]                 = [],
        tickCount: Int                          = 5,
        axisTransform: AxisTransform            = .identity,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) },
        font: Font                              = .caption2,
        textColor: Color                        = .gray,
        height: CGFloat                         = 30,
        showAxisLine: Bool                      = false,
        axisLineColor: Color                    = .gray.opacity(0.5),
        axisLineWidth: CGFloat                  = 1,
        tickLength: CGFloat                     = 5,
        tickColor: Color                        = .gray.opacity(0.5),
        tickWidth: CGFloat                      = 1,
        labelSpacing: CGFloat                   = 4,
        labelLineLimit: Int?                    = 1,
        customLabelBuilder: ((Double) -> AnyView)? = nil,
        title: String?                          = nil,
        titleFont: Font                         = .caption,
        titleColor: Color                       = .gray
    ) {
        self.position           = position
        self.showGrid           = showGrid
        self.showTicks          = showTicks
        self.explicitValues     = explicitValues
        self.tickStrategy       = tickStrategy
        self.labelCollisionStrategy = labelCollisionStrategy
        self.gridColor          = gridColor
        self.gridLineWidth      = gridLineWidth
        self.gridLineDash       = gridLineDash
        self.tickCount          = tickCount
        self.axisTransform      = axisTransform
        self.labelFormatter     = labelFormatter
        self.font               = font
        self.textColor          = textColor
        self.height             = height
        self.showAxisLine       = showAxisLine
        self.axisLineColor      = axisLineColor
        self.axisLineWidth      = axisLineWidth
        self.tickLength         = tickLength
        self.tickColor          = tickColor
        self.tickWidth          = tickWidth
        self.labelSpacing       = labelSpacing
        self.labelLineLimit     = labelLineLimit
        self.customLabelBuilder = customLabelBuilder
        self.title              = title
        self.titleFont          = titleFont
        self.titleColor         = titleColor
    }
}

// MARK: - YAxisConfig

public struct YAxisConfig {
    public var position: YAxisPosition
    public var showGrid: Bool
    public var showTicks: Bool
    public var explicitValues: [Double]?
    public var tickStrategy: ChartTickStrategy
    public var labelCollisionStrategy: ChartLabelCollisionStrategy
    public var gridColor: Color
    public var gridLineWidth: CGFloat
    public var gridLineDash: [CGFloat]
    public var tickCount: Int
    public var axisTransform: AxisTransform
    public var labelFormatter: (Double) -> String
    public var font: Font
    public var textColor: Color
    public var width: CGFloat
    public var showAxisLine: Bool
    public var axisLineColor: Color
    public var axisLineWidth: CGFloat
    public var tickLength: CGFloat
    public var tickColor: Color
    public var tickWidth: CGFloat
    public var labelSpacing: CGFloat
    public var labelLineLimit: Int?
    public var customLabelBuilder: ((Double) -> AnyView)?
    public var title: String?
    public var titleFont: Font
    public var titleColor: Color

    public init(
        position: YAxisPosition                 = .leading,
        showGrid: Bool                          = true,
        showTicks: Bool                         = true,
        explicitValues: [Double]?               = nil,
        tickStrategy: ChartTickStrategy          = .regular,
        labelCollisionStrategy: ChartLabelCollisionStrategy = .showAll,
        gridColor: Color                        = .gray.opacity(0.3),
        gridLineWidth: CGFloat                  = 1,
        gridLineDash: [CGFloat]                 = [],
        tickCount: Int                          = 5,
        axisTransform: AxisTransform            = .identity,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) },
        font: Font                              = .caption2,
        textColor: Color                        = .gray,
        width: CGFloat                          = 40,
        showAxisLine: Bool                      = false,
        axisLineColor: Color                    = .gray.opacity(0.5),
        axisLineWidth: CGFloat                  = 1,
        tickLength: CGFloat                     = 5,
        tickColor: Color                        = .gray.opacity(0.5),
        tickWidth: CGFloat                      = 1,
        labelSpacing: CGFloat                   = 4,
        labelLineLimit: Int?                    = 1,
        customLabelBuilder: ((Double) -> AnyView)? = nil,
        title: String?                          = nil,
        titleFont: Font                         = .caption,
        titleColor: Color                       = .gray
    ) {
        self.position           = position
        self.showGrid           = showGrid
        self.showTicks          = showTicks
        self.explicitValues     = explicitValues
        self.tickStrategy       = tickStrategy
        self.labelCollisionStrategy = labelCollisionStrategy
        self.gridColor          = gridColor
        self.gridLineWidth      = gridLineWidth
        self.gridLineDash       = gridLineDash
        self.tickCount          = tickCount
        self.axisTransform      = axisTransform
        self.labelFormatter     = labelFormatter
        self.font               = font
        self.textColor          = textColor
        self.width              = width
        self.showAxisLine       = showAxisLine
        self.axisLineColor      = axisLineColor
        self.axisLineWidth      = axisLineWidth
        self.tickLength         = tickLength
        self.tickColor          = tickColor
        self.tickWidth          = tickWidth
        self.labelSpacing       = labelSpacing
        self.labelLineLimit     = labelLineLimit
        self.customLabelBuilder = customLabelBuilder
        self.title              = title
        self.titleFont          = titleFont
        self.titleColor         = titleColor
    }
}
