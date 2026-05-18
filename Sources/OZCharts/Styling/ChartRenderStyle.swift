//
//  ChartRenderStyle.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct ChartShadowStyle {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat

    public init(
        color: Color = .black.opacity(0.25),
        radius: CGFloat = 4,
        x: CGFloat = 0,
        y: CGFloat = 2
    ) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public enum ChartFillStyle {
    case color(Color)
    case linearGradient(colors: [Color], startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom)
    case stripes(
        foreground: Color,
        background: Color = .clear,
        lineWidth: CGFloat = 2,
        spacing: CGFloat = 8,
        angle: Angle = .degrees(45)
    )

    public static func gradient(
        _ colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> ChartFillStyle {
        .linearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }

    public static func achievementRemainder(
        foreground: Color = .gray.opacity(0.35),
        background: Color = .gray.opacity(0.16),
        lineWidth: CGFloat = 2,
        spacing: CGFloat = 8,
        angle: Angle = .degrees(45)
    ) -> ChartFillStyle {
        .stripes(
            foreground: foreground,
            background: background,
            lineWidth: lineWidth,
            spacing: spacing,
            angle: angle
        )
    }

    func shading(in rect: CGRect) -> GraphicsContext.Shading {
        switch self {
        case .color(let color):
            return .color(color)

        case .linearGradient(let colors, let startPoint, let endPoint):
            return .linearGradient(
                Gradient(colors: colors),
                startPoint: startPoint.point(in: rect),
                endPoint: endPoint.point(in: rect)
            )

        case .stripes(_, let background, _, _, _):
            return .color(background)
        }
    }
}

extension GraphicsContext {
    mutating func fill(_ path: Path, with style: ChartFillStyle, in rect: CGRect) {
        fill(path, with: style.shading(in: rect))

        guard case .stripes(let foreground, _, let lineWidth, let spacing, let angle) = style else {
            return
        }

        drawLayer { layer in
            layer.clip(to: path)

            let bounds = rect.insetBy(dx: -rect.width, dy: -rect.height)
            let radians = angle.radians
            let direction = CGVector(dx: cos(radians), dy: sin(radians))
            let normal = CGVector(dx: -direction.dy, dy: direction.dx)
            let diagonal = hypot(bounds.width, bounds.height)
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            var offset = -diagonal

            while offset <= diagonal {
                let midpoint = CGPoint(
                    x: center.x + normal.dx * offset,
                    y: center.y + normal.dy * offset
                )
                var stripe = Path()
                stripe.move(
                    to: CGPoint(
                        x: midpoint.x - direction.dx * diagonal,
                        y: midpoint.y - direction.dy * diagonal
                    )
                )
                stripe.addLine(
                    to: CGPoint(
                        x: midpoint.x + direction.dx * diagonal,
                        y: midpoint.y + direction.dy * diagonal
                    )
                )
                layer.stroke(
                    stripe,
                    with: .color(foreground),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
                offset += max(spacing, lineWidth)
            }
        }
    }
}

private extension UnitPoint {
    func point(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: rect.minX + rect.width * x,
            y: rect.minY + rect.height * y
        )
    }
}
