//
//  ChartSelectedElementStyle.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct ChartSelectedElementStyle {
    public var strokeColor: Color
    public var fillColor: Color
    public var lineWidth: CGFloat
    public var cornerRadius: CGFloat

    public init(
        strokeColor: Color = .white.opacity(0.9),
        fillColor: Color = .white.opacity(0.16),
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 4
    ) {
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
    }

    public static let hidden = ChartSelectedElementStyle(
        strokeColor: .clear,
        fillColor: .clear,
        lineWidth: 0,
        cornerRadius: 0
    )

    public static let product = ChartSelectedElementStyle()
}
