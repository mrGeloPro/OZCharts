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

    public static let dashboard = ChartCalloutStyle(
        backgroundColor: Color(red: 0.10, green: 0.11, blue: 0.15),
        foregroundColor: .white,
        cornerRadius: 8,
        horizontalPadding: 12,
        verticalPadding: 10,
        shadowColor: .black.opacity(0.28),
        shadowRadius: 10,
        shadowYOffset: 5
    )
}

public struct ChartCallout<Content: View>: View {
    public var context: ChartElementTooltipContext
    public var style: ChartCalloutStyle
    public var arrowSize: CGSize
    public var arrowInset: CGFloat
    public var content: Content
    @State private var calloutSize: CGSize = .zero

    public init(
        context: ChartElementTooltipContext,
        style: ChartCalloutStyle = .productLight,
        arrowSize: CGSize = CGSize(width: 14, height: 8),
        arrowInset: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.context = context
        self.style = style
        self.arrowSize = arrowSize
        self.arrowInset = arrowInset
        self.content = content()
    }

    public var body: some View {
        content
            .chartCalloutStyle(style)
            .readCalloutSize { calloutSize = $0 }
            .overlay(alignment: arrowAlignment) {
                if context.arrowEdge != .none {
                    ChartCalloutArrow(edge: context.arrowEdge)
                        .fill(style.backgroundColor)
                        .frame(width: resolvedArrowSize.width, height: resolvedArrowSize.height)
                        .offset(arrowOffset)
                        .shadow(
                            color: style.shadowColor.opacity(0.75),
                            radius: max(0, style.shadowRadius / 2),
                            y: arrowShadowYOffset
                        )
                }
            }
    }

    private var arrowAlignment: Alignment {
        switch context.arrowEdge {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .none:
            return .center
        }
    }

    private var arrowOffset: CGSize {
        switch context.arrowEdge {
        case .top:
            return CGSize(width: clampedXOffset, height: -resolvedArrowSize.height + 1)
        case .bottom:
            return CGSize(width: clampedXOffset, height: resolvedArrowSize.height - 1)
        case .leading:
            return CGSize(width: -resolvedArrowSize.width + 1, height: clampedYOffset)
        case .trailing:
            return CGSize(width: resolvedArrowSize.width - 1, height: clampedYOffset)
        case .none:
            return .zero
        }
    }

    private var resolvedArrowSize: CGSize {
        switch context.arrowEdge {
        case .top, .bottom:
            let reach = verticalArrowReach
            return CGSize(width: arrowSize.width, height: reach > 0 ? reach : arrowSize.height)
        case .leading, .trailing:
            let reach = horizontalArrowReach
            return CGSize(width: reach > 0 ? reach : arrowSize.height, height: arrowSize.width)
        case .none:
            return .zero
        }
    }

    private var verticalArrowReach: CGFloat {
        guard calloutSize.height > 0 else { return arrowSize.height }
        switch context.arrowEdge {
        case .top:
            return max(0, context.position.y - calloutSize.height / 2 - context.anchor.y)
        case .bottom:
            return max(0, context.anchor.y - (context.position.y + calloutSize.height / 2))
        case .leading, .trailing, .none:
            return 0
        }
    }

    private var horizontalArrowReach: CGFloat {
        guard calloutSize.width > 0 else { return arrowSize.height }
        switch context.arrowEdge {
        case .leading:
            return max(0, context.position.x - calloutSize.width / 2 - context.anchor.x)
        case .trailing:
            return max(0, context.anchor.x - (context.position.x + calloutSize.width / 2))
        case .top, .bottom, .none:
            return 0
        }
    }

    private var arrowShadowYOffset: CGFloat {
        context.arrowEdge == .bottom ? 2 : 0
    }

    private var clampedXOffset: CGFloat {
        clamp(
            context.arrowXOffset,
            lower: -maxArrowXOffset,
            upper: maxArrowXOffset
        )
    }

    private var clampedYOffset: CGFloat {
        clamp(
            context.arrowYOffset,
            lower: -maxArrowYOffset,
            upper: maxArrowYOffset
        )
    }

    private var maxArrowXOffset: CGFloat {
        let measuredOffset = max(0, calloutSize.width / 2 - arrowInset)
        return measuredOffset > 0 ? measuredOffset : abs(context.arrowXOffset)
    }

    private var maxArrowYOffset: CGFloat {
        let measuredOffset = max(0, calloutSize.height / 2 - arrowInset)
        return measuredOffset > 0 ? measuredOffset : abs(context.arrowYOffset)
    }
}

private struct ChartCalloutArrow: Shape {
    let edge: ChartTooltipArrowEdge

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch edge {
        case .top:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .bottom:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        case .leading:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .trailing:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .none:
            return Path()
        }
        path.closeSubpath()
        return path
    }
}

private func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
    min(max(value, lower), upper)
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

private struct ChartCalloutSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private extension View {
    func readCalloutSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: ChartCalloutSizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(ChartCalloutSizePreferenceKey.self, perform: onChange)
    }
}
