//
//  LinearScale.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import CoreGraphics

public struct LinearScale: Scale {
    public typealias InputType = Double
    public typealias OutputType = CGFloat

    public var domain: ClosedRange<Double>
    public var range: ClosedRange<CGFloat>
    public var isReversed: Bool

    public init(
        domain: ClosedRange<Double>,
        range: ClosedRange<CGFloat> = 0.0...1.0,
        isReversed: Bool = false
    ) {
        self.domain = domain.lowerBound == domain.upperBound
            ? domain.lowerBound...(domain.upperBound + 1.0)
            : domain
        self.range = range
        self.isReversed = isReversed
    }

    public func scale(_ value: Double) -> CGFloat {
        let domainExtent = domain.upperBound - domain.lowerBound
        let rangeExtent = range.upperBound - range.lowerBound
        let normalized = (value - domain.lowerBound) / domainExtent
        let projected = isReversed ? (1.0 - normalized) : normalized
        return range.lowerBound + CGFloat(projected) * rangeExtent
    }

    public func invert(_ value: CGFloat) -> Double {
        let domainExtent = domain.upperBound - domain.lowerBound
        let rangeExtent = range.upperBound - range.lowerBound
        guard rangeExtent != 0 else { return domain.lowerBound }
        let normalized = (value - range.lowerBound) / rangeExtent
        let projected = isReversed ? (1.0 - normalized) : normalized
        return domain.lowerBound + Double(projected) * domainExtent
    }

    public func ticks(
        count: Int,
        formatter: @escaping (Double) -> String = { String(format: "%.1f", $0) }
    ) -> [ScaleTick<Double, CGFloat>] {
        guard count > 1 else { return [] }
        let step = (domain.upperBound - domain.lowerBound) / Double(count - 1)
        return (0..<count).map { i in
            let value = domain.lowerBound + step * Double(i)
            return ScaleTick(value: value, position: scale(value), label: formatter(value))
        }
    }
}

public extension LinearScale {
    static func time(
        domain: ClosedRange<Date>,
        range: ClosedRange<CGFloat> = 0.0...1.0,
        isReversed: Bool = false
    ) -> LinearScale {
        LinearScale(
            domain: domain.lowerBound.timeIntervalSince1970...domain.upperBound.timeIntervalSince1970,
            range: range,
            isReversed: isReversed
        )
    }
}
