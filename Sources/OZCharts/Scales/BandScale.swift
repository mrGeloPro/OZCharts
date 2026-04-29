//
//  BandScale.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public struct BandScale: Scale {
    public typealias InputType = String
    public typealias OutputType = CGFloat

    public var domain: ClosedRange<String>
    public var range: ClosedRange<CGFloat>
    public var isReversed: Bool
    public var categories: [String]
    public var padding: CGFloat

    public init(
        categories: [String],
        range: ClosedRange<CGFloat> = 0.0...1.0,
        padding: CGFloat = 0.1,
        isReversed: Bool = false
    ) {
        let resolved = categories.isEmpty ? [""] : categories
        self.categories = resolved
        self.domain = (resolved.first ?? "")...(resolved.last ?? "")
        self.range = range
        self.padding = max(0, min(padding, 0.9))
        self.isReversed = isReversed
    }

    public func scale(_ value: String) -> CGFloat {
        guard let index = categories.firstIndex(of: value), !categories.isEmpty else {
            return range.lowerBound
        }

        let count = CGFloat(categories.count)
        let totalWidth = range.upperBound - range.lowerBound
        let band = totalWidth / max(1, count)
        let inner = band * (1 - padding)
        let offset = CGFloat(index) * band + (band - inner) / 2 + inner / 2
        let projected = isReversed ? totalWidth - offset : offset
        return range.lowerBound + projected
    }

    public func invert(_ value: CGFloat) -> String {
        guard !categories.isEmpty else { return "" }
        let totalWidth = range.upperBound - range.lowerBound
        guard totalWidth > 0 else { return categories[0] }

        let local = min(max(value - range.lowerBound, 0), totalWidth)
        let projected = isReversed ? totalWidth - local : local
        let index = min(categories.count - 1, max(0, Int(projected / (totalWidth / CGFloat(categories.count)))))
        return categories[index]
    }

    public func ticks(
        count: Int,
        formatter: @escaping (String) -> String = { $0 }
    ) -> [ScaleTick<String, CGFloat>] {
        categories.map { category in
            ScaleTick(value: category, position: scale(category), label: formatter(category))
        }
    }
}
