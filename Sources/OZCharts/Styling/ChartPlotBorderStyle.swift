//
//  ChartPlotBorderStyle.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct ChartPlotBorderEdges: OptionSet, Equatable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let top = ChartPlotBorderEdges(rawValue: 1 << 0)
    public static let bottom = ChartPlotBorderEdges(rawValue: 1 << 1)
    public static let leading = ChartPlotBorderEdges(rawValue: 1 << 2)
    public static let trailing = ChartPlotBorderEdges(rawValue: 1 << 3)

    public static let horizontal: ChartPlotBorderEdges = [.top, .bottom]
    public static let vertical: ChartPlotBorderEdges = [.leading, .trailing]
    public static let all: ChartPlotBorderEdges = [.top, .bottom, .leading, .trailing]
}

public struct ChartPlotBorderStyle {
    public var edges: ChartPlotBorderEdges
    public var color: Color
    public var lineWidth: CGFloat
    public var dash: [CGFloat]

    public init(
        edges: ChartPlotBorderEdges = .all,
        color: Color = .gray.opacity(0.45),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = []
    ) {
        self.edges = edges
        self.color = color
        self.lineWidth = lineWidth
        self.dash = dash
    }

    public static let hidden = ChartPlotBorderStyle(edges: [], lineWidth: 0)

    public static func visible(
        edges: ChartPlotBorderEdges = .all,
        color: Color = .gray.opacity(0.45),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = []
    ) -> ChartPlotBorderStyle {
        ChartPlotBorderStyle(
            edges: edges,
            color: color,
            lineWidth: lineWidth,
            dash: dash
        )
    }
}
