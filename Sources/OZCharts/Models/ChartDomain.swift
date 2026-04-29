//
//  ChartDomain.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation

public struct ChartDomain: Equatable {
    public var range: ClosedRange<Double>?
    public var padding: Double
    public var includeZero: Bool
    public var fallback: ClosedRange<Double>

    public init(
        range: ClosedRange<Double>? = nil,
        padding: Double = 0,
        includeZero: Bool = false,
        fallback: ClosedRange<Double> = 0...1
    ) {
        self.range = range
        self.padding = max(0, padding)
        self.includeZero = includeZero
        self.fallback = fallback.lowerBound == fallback.upperBound
            ? fallback.lowerBound...(fallback.upperBound + 1)
            : fallback
    }

    public static func fixed(_ range: ClosedRange<Double>) -> ChartDomain {
        ChartDomain(range: range)
    }

    public static func auto(
        padding: Double = 0.08,
        includeZero: Bool = false,
        fallback: ClosedRange<Double> = 0...1
    ) -> ChartDomain {
        ChartDomain(
            range: nil,
            padding: padding,
            includeZero: includeZero,
            fallback: fallback
        )
    }

    public func resolve(values: [Double]) -> ClosedRange<Double> {
        if let range {
            return normalized(range)
        }

        let finiteValues = values.filter(\.isFinite)
        guard var lower = finiteValues.min(), var upper = finiteValues.max() else {
            return normalized(fallback)
        }

        if includeZero {
            lower = min(lower, 0)
            upper = max(upper, 0)
        }

        guard lower != upper else {
            let delta = max(abs(lower) * 0.1, 1)
            return (lower - delta)...(upper + delta)
        }

        let inset = (upper - lower) * padding
        return (lower - inset)...(upper + inset)
    }

    private func normalized(_ range: ClosedRange<Double>) -> ClosedRange<Double> {
        guard range.lowerBound != range.upperBound else {
            return range.lowerBound...(range.upperBound + 1)
        }
        return range
    }
}
