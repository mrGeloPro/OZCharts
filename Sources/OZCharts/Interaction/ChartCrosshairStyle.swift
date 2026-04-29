//
//  ChartCrosshairStyle.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public enum ChartCrosshairMode: Equatable {
    case none
    case vertical
    case horizontal
    case both
}

public struct ChartCrosshairStyle {
    public var mode: ChartCrosshairMode
    public var color: Color
    public var lineWidth: CGFloat
    public var dash: [CGFloat]

    public init(
        mode: ChartCrosshairMode = .vertical,
        color: Color = .secondary.opacity(0.8),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [4, 4]
    ) {
        self.mode = mode
        self.color = color
        self.lineWidth = lineWidth
        self.dash = dash
    }

    public static let hidden = ChartCrosshairStyle(mode: .none)

    public static func vertical(
        color: Color = .secondary.opacity(0.8),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [4, 4]
    ) -> ChartCrosshairStyle {
        ChartCrosshairStyle(mode: .vertical, color: color, lineWidth: lineWidth, dash: dash)
    }

    public static func horizontal(
        color: Color = .secondary.opacity(0.8),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [4, 4]
    ) -> ChartCrosshairStyle {
        ChartCrosshairStyle(mode: .horizontal, color: color, lineWidth: lineWidth, dash: dash)
    }

    public static func both(
        color: Color = .secondary.opacity(0.8),
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [4, 4]
    ) -> ChartCrosshairStyle {
        ChartCrosshairStyle(mode: .both, color: color, lineWidth: lineWidth, dash: dash)
    }

    var isVisible: Bool {
        mode != .none
    }
}
