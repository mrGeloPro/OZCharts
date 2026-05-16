//
//  PolarCoordinator.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct PolarSegment {
    public let startAngle: Angle
    public let endAngle: Angle
    public let color: Color
}

public struct PolarDonutLayoutOptions: Equatable {
    public var thickness: CGFloat
    public var gapAngle: Angle
    public var startAngle: Angle
    public var contentInset: CGFloat
    public var explodedOffsets: [CGFloat]
    public var shadowRadii: [CGFloat]

    public init(
        thickness: CGFloat = 40,
        gapAngle: Angle = .degrees(6),
        startAngle: Angle = .degrees(-90),
        contentInset: CGFloat = 2,
        explodedOffsets: [CGFloat] = [],
        shadowRadii: [CGFloat] = []
    ) {
        self.thickness = thickness
        self.gapAngle = gapAngle
        self.startAngle = startAngle
        self.contentInset = contentInset
        self.explodedOffsets = explodedOffsets
        self.shadowRadii = shadowRadii
    }
}

public struct PolarSegmentLayout: Equatable {
    public let index: Int
    public let value: Double
    public let fraction: Double
    public let center: CGPoint
    public let radius: CGFloat
    public let thickness: CGFloat
    public let innerRadius: CGFloat
    public let outerRadius: CGFloat
    public let startAngle: Double
    public let endAngle: Double
    public let midpointAngle: Double
    public let bounds: CGRect
}

public final class PolarCoordinator {
    public init() {}

    public func calculateSegments(from values: [Double], colors: [Color]) -> [PolarSegment] {
        let total = values.reduce(0, +)
        guard total > 0 else { return [] }
        var currentAngle: Double = -90

        return values.enumerated().map { index, value in
            let delta = (value / total) * 360.0
            let start = Angle(degrees: currentAngle)
            let end   = Angle(degrees: currentAngle + delta)
            currentAngle += delta
            return PolarSegment(
                startAngle: start,
                endAngle: end,
                color: colors[safe: index] ?? .gray
            )
        }
    }

    public func calculateDonutSegments(
        from values: [Double],
        in size: CGSize,
        options: PolarDonutLayoutOptions = PolarDonutLayoutOptions()
    ) -> [PolarSegmentLayout] {
        let sanitizedValues = values.map { max(0, $0) }
        let total = sanitizedValues.reduce(0, +)
        guard total > 0 else { return [] }

        let baseCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxExplodedOffset = options.explodedOffsets.max() ?? 0
        let maxShadowRadius = options.shadowRadii.max() ?? 0
        let outerRadius = max(
            0,
            min(size.width, size.height) / 2 - options.contentInset - maxExplodedOffset - maxShadowRadius
        )
        let radius = outerRadius - options.thickness / 2
        guard radius > 0 else { return [] }

        let totalGapRadians = options.gapAngle.radians * Double(sanitizedValues.count)
        let availableRadians = 2 * Double.pi - totalGapRadians
        guard availableRadians > 0 else { return [] }

        var layouts: [PolarSegmentLayout] = []
        var currentRadians = options.startAngle.radians

        for (index, value) in sanitizedValues.enumerated() {
            let fraction = value / total
            let delta = fraction * availableRadians
            let start = currentRadians + options.gapAngle.radians / 2
            let end = start + delta
            let midpoint = (start + end) / 2
            let explodedOffset = options.explodedOffsets[safe: index] ?? 0
            let center = CGPoint(
                x: baseCenter.x + CGFloat(cos(midpoint)) * explodedOffset,
                y: baseCenter.y + CGFloat(sin(midpoint)) * explodedOffset
            )
            let segmentOuterRadius = radius + options.thickness / 2
            let bounds = CGRect(
                x: center.x - segmentOuterRadius,
                y: center.y - segmentOuterRadius,
                width: segmentOuterRadius * 2,
                height: segmentOuterRadius * 2
            )

            layouts.append(
                PolarSegmentLayout(
                    index: index,
                    value: value,
                    fraction: fraction,
                    center: center,
                    radius: radius,
                    thickness: options.thickness,
                    innerRadius: max(0, radius - options.thickness / 2),
                    outerRadius: segmentOuterRadius,
                    startAngle: start,
                    endAngle: end,
                    midpointAngle: midpoint,
                    bounds: bounds
                )
            )

            currentRadians += delta + options.gapAngle.radians
        }

        return layouts
    }
}
