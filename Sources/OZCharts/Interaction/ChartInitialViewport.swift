//
//  ChartInitialViewport.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

public enum ChartViewportAnchor: Equatable {
    case leading
    case trailing
    case center
    case value(Double)
}

public enum ChartViewportDomain: Equatable {
    case range(ClosedRange<Double>)
    case window(length: Double, anchor: ChartViewportAnchor)
}

public struct ChartInitialViewport: Equatable {
    public var xDomain: ChartViewportDomain?
    public var yDomain: ChartViewportDomain?

    public init(
        xDomain: ChartViewportDomain? = nil,
        yDomain: ChartViewportDomain? = nil
    ) {
        self.xDomain = xDomain
        self.yDomain = yDomain
    }

    public init(
        x: ClosedRange<Double>? = nil,
        y: ClosedRange<Double>? = nil
    ) {
        self.xDomain = x.map { .range($0) }
        self.yDomain = y.map { .range($0) }
    }

    public static func x(_ range: ClosedRange<Double>) -> ChartInitialViewport {
        ChartInitialViewport(x: range)
    }

    public static func y(_ range: ClosedRange<Double>) -> ChartInitialViewport {
        ChartInitialViewport(y: range)
    }

    public static func xWindow(
        length: Double,
        anchor: ChartViewportAnchor = .leading
    ) -> ChartInitialViewport {
        ChartInitialViewport(xDomain: .window(length: length, anchor: anchor))
    }

    public static func yWindow(
        length: Double,
        anchor: ChartViewportAnchor = .leading
    ) -> ChartInitialViewport {
        ChartInitialViewport(yDomain: .window(length: length, anchor: anchor))
    }
}

extension ChartViewportDomain {
    func resolved(within global: ClosedRange<Double>) -> ClosedRange<Double>? {
        guard global.lowerBound.isFinite,
              global.upperBound.isFinite,
              global.lowerBound < global.upperBound else {
            return nil
        }

        switch self {
        case .range(let range):
            guard range.lowerBound.isFinite,
                  range.upperBound.isFinite,
                  range.lowerBound < range.upperBound else {
                return nil
            }
            return clamp(range, within: global)

        case .window(let length, let anchor):
            guard length.isFinite, length > 0 else { return nil }

            let globalLength = global.upperBound - global.lowerBound
            let windowLength = min(length, globalLength)
            let range: ClosedRange<Double>

            switch anchor {
            case .leading:
                range = global.lowerBound...(global.lowerBound + windowLength)

            case .trailing:
                range = (global.upperBound - windowLength)...global.upperBound

            case .center:
                let center = global.lowerBound + globalLength / 2
                range = centeredRange(center: center, length: windowLength)

            case .value(let value):
                guard value.isFinite else { return nil }
                range = centeredRange(center: value, length: windowLength)
            }

            return clamp(range, within: global)
        }
    }

    private func centeredRange(center: Double, length: Double) -> ClosedRange<Double> {
        (center - length / 2)...(center + length / 2)
    }

    private func clamp(
        _ range: ClosedRange<Double>,
        within global: ClosedRange<Double>
    ) -> ClosedRange<Double> {
        var lower = range.lowerBound
        var upper = range.upperBound
        let length = min(upper - lower, global.upperBound - global.lowerBound)

        if lower < global.lowerBound {
            lower = global.lowerBound
            upper = lower + length
        }

        if upper > global.upperBound {
            upper = global.upperBound
            lower = upper - length
        }

        return max(global.lowerBound, lower)...min(global.upperBound, upper)
    }
}
