//
//  DonutSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct DonutSegmentLayout {
    let index: Int
    let pointID: UUID
    let value: Double
    let x: Double
    let center: CGPoint
    let radius: CGFloat
    let thickness: CGFloat
    let startAngle: Double
    let endAngle: Double
    let bounds: CGRect
}

public struct DonutSegmentStyle {
    public var fill: ChartFillStyle
    public var explodedOffset: CGFloat
    public var shadow: ChartShadowStyle?

    public init(
        fill: ChartFillStyle,
        explodedOffset: CGFloat = 0,
        shadow: ChartShadowStyle? = nil
    ) {
        self.fill = fill
        self.explodedOffset = explodedOffset
        self.shadow = shadow
    }
}

public struct DonutSeries<P: ChartDataPoint>: ChartSeriesProtocol
    where P.XValue == Double, P.YValue == Double {
    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle
    public var label: String?
    public var segmentLabelMapper: ((P) -> String?)?

    public var colors: [Color]
    public var segmentStyles: [DonutSegmentStyle]
    public var thickness: CGFloat
    public var gapAngle: Angle
    public var startAngle: Angle
    public var lineCap: CGLineCap

    public init(
        data: [P],
        id: UUID = UUID(),
        colors: [Color],
        segmentStyles: [DonutSegmentStyle] = [],
        label: String? = nil,
        segmentLabelMapper: ((P) -> String?)? = nil,
        thickness: CGFloat = 40,
        gapAngle: Angle = .degrees(6),
        startAngle: Angle = .degrees(-90),
        lineCap: CGLineCap = .butt,
        animation: ChartAnimationStyle = .none,
        zIndex: Int = 0
    ) {
        self.id = id
        self.data = data
        self.label = label
        self.segmentLabelMapper = segmentLabelMapper
        self.colors = colors
        self.segmentStyles = segmentStyles
        self.thickness = thickness
        self.gapAngle = gapAngle
        self.startAngle = startAngle
        self.lineCap = lineCap
        self.animation = animation
        self.zIndex = zIndex
    }

    public var legendItem: ChartLegendItem? {
        label.map {
            ChartLegendItem(id: id, title: $0, color: colors.first ?? .gray, symbol: .circle)
        }
    }

    public var layoutSignature: ChartSeriesSignature {
        ChartSeriesSignature(
            kind: String(reflecting: Self.self),
            values: [
                Double(thickness),
                gapAngle.radians,
                startAngle.radians
            ] + segmentStyles.flatMap {
                [
                    Double($0.explodedOffset),
                    Double($0.shadow?.radius ?? 0),
                    Double($0.shadow?.x ?? 0),
                    Double($0.shadow?.y ?? 0)
                ]
            },
            tokens: [
                "lineCap:\(lineCap.rawValue)",
                "segmentStyles:\(segmentStyles.count)",
                "hasSegmentLabelMapper:\(segmentLabelMapper != nil)",
                "animation:\(animation.kind)"
            ]
        )
    }

    public func render(
        into context: inout GraphicsContext,
        contexts _: [ChartPointContext<P>],
        size: CGSize
    ) {
        for segment in segmentLayouts(size: size) {
            let index = segment.index
            let segmentStyle = segmentStyles[safe: index]

            var path = Path()
            path.addArc(
                center: segment.center,
                radius: segment.radius,
                startAngle: .radians(segment.startAngle),
                endAngle: .radians(segment.endAngle),
                clockwise: false
            )

            let color = colors[safe: index] ?? .gray
            let fill = segmentStyle?.fill ?? .color(color)
            let strokeStyle = StrokeStyle(lineWidth: thickness, lineCap: lineCap)
            let rect = CGRect(origin: .zero, size: size)
            if let shadow = segmentStyle?.shadow {
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y))
                    layer.stroke(path, with: fill.shading(in: rect), style: strokeStyle)
                }
            } else {
                context.stroke(path, with: fill.shading(in: rect), style: strokeStyle)
            }
        }
    }

    func segmentLayouts(size: CGSize) -> [DonutSegmentLayout] {
        PolarCoordinator()
            .calculateDonutSegments(
                from: data.map(\.y),
                in: size,
                options: PolarDonutLayoutOptions(
                    thickness: thickness,
                    gapAngle: gapAngle,
                    startAngle: startAngle,
                    explodedOffsets: segmentStyles.map(\.explodedOffset),
                    shadowRadii: segmentStyles.compactMap(\.shadow?.radius)
                )
            )
            .compactMap { segment in
                guard let point = data[safe: segment.index] else {
                    return nil
                }

                return DonutSegmentLayout(
                    index: segment.index,
                    pointID: point.id,
                    value: segment.value,
                    x: point.x,
                    center: segment.center,
                    radius: segment.radius,
                    thickness: segment.thickness,
                    startAngle: segment.startAngle,
                    endAngle: segment.endAngle,
                    bounds: segment.bounds
                )
            }
    }

    public func selectionElements(
        contexts _: [ChartPointContext<P>],
        size: CGSize
    ) -> [ChartElementContext] {
        segmentLayouts(size: size).map { segment in
            let point = data[safe: segment.index]
            let segmentLabel = point.flatMap { segmentLabelMapper?($0) } ?? label
            let innerRadius = max(0, segment.radius - segment.thickness / 2)
            let outerRadius = segment.radius + segment.thickness / 2
            let midpoint = (segment.startAngle + segment.endAngle) / 2
            let position = CGPoint(
                x: segment.center.x + CGFloat(cos(midpoint)) * segment.radius,
                y: segment.center.y + CGFloat(sin(midpoint)) * segment.radius
            )
            let payload = ChartSelectedElement(
                elementID: segment.pointID,
                kind: .donutSegment,
                seriesID: id,
                pointID: segment.pointID,
                segmentIndex: segment.index,
                label: segmentLabel,
                x: segment.x,
                y: segment.value,
                value: segment.value,
                position: position,
                bounds: segment.bounds
            )

            return ChartElementContext(
                payload: payload,
                hitShape: .donutSegment(
                    center: segment.center,
                    innerRadius: innerRadius,
                    outerRadius: outerRadius,
                    startAngle: segment.startAngle,
                    endAngle: segment.endAngle
                ),
                zIndex: zIndex
            )
        }
    }
}
