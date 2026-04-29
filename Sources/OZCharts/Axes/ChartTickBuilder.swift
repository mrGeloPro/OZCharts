//
//  ChartTickBuilder.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public enum ChartTickStrategy: Equatable {
    case regular
    case nice
}

public enum ChartLabelCollisionStrategy: Equatable {
    case showAll
    case hideOverlapping(minSpacing: CGFloat = 44)
}

enum ChartTickBuilder {
    static func ticks<S: Scale>(
        scale: S,
        explicitValues: [Double]?,
        tickCount: Int,
        strategy: ChartTickStrategy,
        formatter: @escaping (Double) -> String
    ) -> [ScaleTick<Double, CGFloat>]
    where S.InputType == Double, S.OutputType == CGFloat {
        if let explicitValues {
            return explicitValues.map {
                ScaleTick(value: $0, position: scale.scale($0), label: formatter($0))
            }
        }

        switch strategy {
        case .regular:
            return scale.ticks(count: tickCount, formatter: formatter)

        case .nice:
            return niceTicks(
                domain: scale.domain,
                tickCount: tickCount,
                position: { scale.scale($0) },
                formatter: formatter
            )
        }
    }

    static func filteredTicks(
        _ ticks: [ScaleTick<Double, CGFloat>],
        strategy: ChartLabelCollisionStrategy
    ) -> [ScaleTick<Double, CGFloat>] {
        switch strategy {
        case .showAll:
            return ticks

        case .hideOverlapping(let minSpacing):
            guard minSpacing > 0 else { return ticks }

            var accepted: [ScaleTick<Double, CGFloat>] = []
            for tick in ticks.sorted(by: { $0.position < $1.position }) {
                guard let last = accepted.last else {
                    accepted.append(tick)
                    continue
                }
                if abs(tick.position - last.position) >= minSpacing {
                    accepted.append(tick)
                }
            }
            return accepted
        }
    }

    private static func niceTicks(
        domain: ClosedRange<Double>,
        tickCount: Int,
        position: (Double) -> CGFloat,
        formatter: (Double) -> String
    ) -> [ScaleTick<Double, CGFloat>] {
        guard tickCount > 1,
              domain.lowerBound.isFinite,
              domain.upperBound.isFinite,
              domain.lowerBound < domain.upperBound else {
            return []
        }

        let targetStep = (domain.upperBound - domain.lowerBound) / Double(max(1, tickCount - 1))
        let step = niceStep(for: targetStep)
        guard step > 0, step.isFinite else { return [] }

        let start = ceil(domain.lowerBound / step) * step
        let end = floor(domain.upperBound / step) * step
        guard start <= end else { return [] }

        var values: [Double] = []
        var value = start
        let maxIterations = max(2, tickCount * 4)

        for _ in 0..<maxIterations {
            if value > end + step * 0.001 { break }
            values.append(sanitized(value))
            value += step
        }

        return values.map {
            ScaleTick(value: $0, position: position($0), label: formatter($0))
        }
    }

    private static func niceStep(for rawStep: Double) -> Double {
        guard rawStep > 0 else { return 0 }

        let exponent = floor(log10(rawStep))
        let magnitude = pow(10, exponent)
        let fraction = rawStep / magnitude

        let niceFraction: Double
        if fraction < 1.5 {
            niceFraction = 1
        } else if fraction < 3 {
            niceFraction = 2
        } else if fraction < 7 {
            niceFraction = 5
        } else {
            niceFraction = 10
        }

        return niceFraction * magnitude
    }

    private static func sanitized(_ value: Double) -> Double {
        abs(value) < 1e-10 ? 0 : value
    }
}
