//
//  ChartViewportState.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

public struct ChartViewportState: Equatable {
    public var visibleXDomain: ClosedRange<Double>?
    public var visibleYDomain: ClosedRange<Double>?

    public init(
        visibleXDomain: ClosedRange<Double>? = nil,
        visibleYDomain: ClosedRange<Double>? = nil
    ) {
        self.visibleXDomain = visibleXDomain
        self.visibleYDomain = visibleYDomain
    }

    public static let automatic = ChartViewportState()
}
