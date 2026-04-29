//
//  LogScale.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public struct LogScale: Scale {
    public typealias InputType = Double
    public typealias OutputType = CGFloat

    public var domain: ClosedRange<Double>
    public var range: ClosedRange<CGFloat>
    public var isReversed: Bool
    public var base: Double

    public init(
        domain: ClosedRange<Double>,
        range: ClosedRange<CGFloat> = 0.0...1.0,
        isReversed: Bool = false,
        base: Double = 10
    ) {
        let lower = max(domain.lowerBound, .leastNonzeroMagnitude)
        let upper = max(domain.upperBound, lower.nextUp)
        self.domain = lower == upper ? lower...(upper * base) : lower...upper
        self.range = range
        self.isReversed = isReversed
        self.base = max(base, 2)
    }

    public func scale(_ value: Double) -> CGFloat {
        let safeValue = max(value, .leastNonzeroMagnitude)
        let lower = logValue(domain.lowerBound)
        let upper = logValue(domain.upperBound)
        let extent = upper - lower
        guard extent != 0 else { return range.lowerBound }

        let normalized = (logValue(safeValue) - lower) / extent
        let projected = isReversed ? (1.0 - normalized) : normalized
        return range.lowerBound + CGFloat(projected) * (range.upperBound - range.lowerBound)
    }

    public func invert(_ value: CGFloat) -> Double {
        let rangeExtent = range.upperBound - range.lowerBound
        guard rangeExtent != 0 else { return domain.lowerBound }

        let normalized = (value - range.lowerBound) / rangeExtent
        let projected = isReversed ? (1.0 - normalized) : normalized
        let lower = logValue(domain.lowerBound)
        let upper = logValue(domain.upperBound)
        return pow(base, lower + Double(projected) * (upper - lower))
    }

    public func ticks(
        count: Int,
        formatter: @escaping (Double) -> String = { String(format: "%.0f", $0) }
    ) -> [ScaleTick<Double, CGFloat>] {
        guard count > 1 else { return [] }
        let lower = logValue(domain.lowerBound)
        let upper = logValue(domain.upperBound)
        let step = (upper - lower) / Double(count - 1)

        return (0..<count).map { index in
            let value = pow(base, lower + step * Double(index))
            return ScaleTick(value: value, position: scale(value), label: formatter(value))
        }
    }

    private func logValue(_ value: Double) -> Double {
        log(max(value, .leastNonzeroMagnitude)) / log(base)
    }
}
