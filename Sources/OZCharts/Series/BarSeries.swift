//
//  BarSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct BarLayout {
    let rect: CGRect
}

public enum ChartValueLabelPosition: Hashable {
    case hidden
    case inside
    case outside
}

public struct ChartValueLabelStyle {
    public var position: ChartValueLabelPosition
    public var color: Color
    public var font: Font
    public var formatter: (Double) -> String

    public init(
        position: ChartValueLabelPosition = .outside,
        color: Color = .primary,
        font: Font = .caption,
        formatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) {
        self.position = position
        self.color = color
        self.font = font
        self.formatter = formatter
    }
}

public struct BarSeries<P: ChartDataPoint>: ChartSeriesProtocol
    where P.XValue == Double, P.YValue == Double {
    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle
    public var label: String?

    public var color: Color
    public var fillStyle: ChartFillStyle?
    public var barWidth: CGFloat
    public var cornerRadius: CGFloat
    public var baseline: Double
    public var shadow: ChartShadowStyle?
    public var valueLabelStyle: ChartValueLabelStyle?

    public init(
        data: [P],
        id: UUID = UUID(),
        color: Color = .blue,
        fillStyle: ChartFillStyle? = nil,
        label: String? = nil,
        barWidth: CGFloat = 14,
        cornerRadius: CGFloat = 3,
        baseline: Double = 0,
        shadow: ChartShadowStyle? = nil,
        valueLabelStyle: ChartValueLabelStyle? = nil,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.id = id
        self.data = data
        self.color = color
        self.fillStyle = fillStyle
        self.label = label
        self.barWidth = barWidth
        self.cornerRadius = cornerRadius
        self.baseline = baseline
        self.shadow = shadow
        self.valueLabelStyle = valueLabelStyle
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: color, symbol: .square)
        }
    }

    public var layoutSignature: ChartSeriesSignature {
        ChartSeriesSignature(
            kind: String(reflecting: Self.self),
            values: [
                Double(barWidth),
                Double(cornerRadius),
                baseline
            ],
            tokens: [
                "valueLabelPosition:\(String(describing: valueLabelStyle?.position))",
                "animation:\(animation.kind)"
            ]
        )
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        let layouts = barLayouts(contexts: contexts)
        for layout in layouts {
            let path = Path(roundedRect: layout.rect, cornerRadius: cornerRadius)
            let fillStyle = fillStyle ?? .color(color)
            if let shadow {
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y))
                    layer.fill(path, with: fillStyle, in: layout.rect)
                }
            } else {
                context.fill(path, with: fillStyle, in: layout.rect)
            }
        }

        guard let valueLabelStyle, valueLabelStyle.position != .hidden else { return }
        let labelInputs = zip(layouts, contexts).compactMap { layout, chartContext -> (layout: BarLayout, chartContext: ChartPointContext<P>, label: String, resolved: ChartResolvedLabel)? in
            let value = chartContext.originalPoint.y
            let x = layout.rect.midX
            let anchor: CGPoint
            let placements: [ChartLabelPlacement]
            switch valueLabelStyle.position {
            case .hidden:
                return nil
            case .inside:
                anchor = CGPoint(x: x, y: layout.rect.midY)
                placements = [.center]
            case .outside:
                anchor = CGPoint(x: x, y: layout.rect.minY)
                placements = [.top, .bottom]
            }
            let label = valueLabelStyle.formatter(value)
            return (
                layout,
                chartContext,
                label,
                ChartResolvedLabel(
                    id: chartContext.originalPoint.id,
                    anchor: anchor,
                    position: anchor,
                    size: ChartTextMetrics.estimatedSize(for: label),
                    placement: placements.first ?? .center,
                    isVisible: true
                )
            )
        }

        let candidates = labelInputs.map { input in
            ChartLabelCandidate(
                id: input.chartContext.originalPoint.id,
                anchor: input.resolved.anchor,
                size: input.resolved.size,
                preferredPlacements: [input.resolved.placement],
                padding: 2,
                spacing: 4,
                canHide: true
            )
        }
        let resolvedLabels = ChartLabelCollisionResolver.resolve(
            candidates: candidates,
            canvasSize: size
        )
        let resolvedByID = Dictionary(uniqueKeysWithValues: resolvedLabels.map { ($0.id, $0) })

        for input in labelInputs {
            guard let resolved = resolvedByID[input.chartContext.originalPoint.id], resolved.isVisible else { continue }
            let text = Text(input.label)
                .font(valueLabelStyle.font)
                .foregroundColor(valueLabelStyle.color)
            context.draw(text, at: resolved.position, anchor: .center)
        }
    }

    func barLayouts(contexts: [ChartPointContext<P>]) -> [BarLayout] {
        contexts.compactMap { context in
            let baselineY = context.scaleY(baseline)
            let valueY = context.position.y
            guard baselineY.isFinite, valueY.isFinite else { return nil }

            let top = min(baselineY, valueY)
            let height = abs(baselineY - valueY)
            guard height > 0 else { return nil }

            return BarLayout(
                rect: CGRect(
                    x: context.position.x - barWidth / 2,
                    y: top,
                    width: barWidth,
                    height: height
                )
            )
        }
    }

    public func selectionElements(
        contexts: [ChartPointContext<P>],
        size _: CGSize
    ) -> [ChartElementContext] {
        zip(barLayouts(contexts: contexts), contexts).map { layout, context in
            let payload = ChartSelectedElement(
                elementID: context.originalPoint.id,
                kind: .bar,
                seriesID: id,
                pointID: context.originalPoint.id,
                label: label,
                x: context.originalPoint.x,
                y: context.originalPoint.y,
                value: context.originalPoint.y,
                position: CGPoint(x: layout.rect.midX, y: layout.rect.midY),
                bounds: layout.rect
            )

            return ChartElementContext(
                payload: payload,
                hitShape: .rect(layout.rect),
                zIndex: zIndex
            )
        }
    }
}
