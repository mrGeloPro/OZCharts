//
//  ChartCalloutStyle.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct ChartCalloutStyle {
    public var backgroundColor: Color
    public var foregroundColor: Color
    public var cornerRadius: CGFloat
    public var horizontalPadding: CGFloat
    public var verticalPadding: CGFloat
    public var shadowColor: Color
    public var shadowRadius: CGFloat
    public var shadowYOffset: CGFloat

    public init(
        backgroundColor: Color,
        foregroundColor: Color,
        cornerRadius: CGFloat = 6,
        horizontalPadding: CGFloat = 10,
        verticalPadding: CGFloat = 8,
        shadowColor: Color = .black.opacity(0.18),
        shadowRadius: CGFloat = 8,
        shadowYOffset: CGFloat = 4
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowYOffset = shadowYOffset
    }

    public static let productLight = ChartCalloutStyle(
        backgroundColor: .white,
        foregroundColor: .black
    )

    public static let productDark = ChartCalloutStyle(
        backgroundColor: Color(red: 0.05, green: 0.03, blue: 0.10),
        foregroundColor: .white,
        shadowColor: .black.opacity(0.35)
    )
}

private struct ChartCalloutModifier: ViewModifier {
    let style: ChartCalloutStyle

    func body(content: Content) -> some View {
        content
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .fill(style.backgroundColor)
            )
            .shadow(color: style.shadowColor, radius: style.shadowRadius, y: style.shadowYOffset)
    }
}

public extension View {
    func chartCalloutStyle(_ style: ChartCalloutStyle = .productLight) -> some View {
        modifier(ChartCalloutModifier(style: style))
    }
}
