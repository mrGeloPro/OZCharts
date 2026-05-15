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
    public var liveTrackingStatus: ChartLiveTrackingStatus
    public var command: ChartViewportCommand?

    public init(
        visibleXDomain: ClosedRange<Double>? = nil,
        visibleYDomain: ClosedRange<Double>? = nil,
        liveTrackingStatus: ChartLiveTrackingStatus = .inactive,
        command: ChartViewportCommand? = nil
    ) {
        self.visibleXDomain = visibleXDomain
        self.visibleYDomain = visibleYDomain
        self.liveTrackingStatus = liveTrackingStatus
        self.command = command
    }

    public static let automatic = ChartViewportState()
    public static let jumpToLatest = ChartViewportState(command: .jumpToLatest)

    public mutating func requestJumpToLatest() {
        command = .jumpToLatest
    }
}
