//
//  ChartLiveTracking.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

public enum ChartLiveTrackingStatus: Equatable {
    case inactive
    case followingLatest
    case pausedByUser

    public var isFollowingLatest: Bool {
        self == .followingLatest
    }

    public var isPausedByUser: Bool {
        self == .pausedByUser
    }
}

public enum ChartViewportCommand: Equatable {
    case jumpToLatest
}

public struct ChartLiveTrackingMode: Equatable {
    public var isEnabled: Bool
    public var pauseOnUserInteraction: Bool
    public var trailingToleranceRatio: Double

    public init(
        isEnabled: Bool = true,
        pauseOnUserInteraction: Bool = true,
        trailingToleranceRatio: Double = 0.02
    ) {
        self.isEnabled = isEnabled
        self.pauseOnUserInteraction = pauseOnUserInteraction
        self.trailingToleranceRatio = trailingToleranceRatio
    }

    public static let disabled = ChartLiveTrackingMode(isEnabled: false)

    public static func followLatest(
        pauseOnUserInteraction: Bool = true,
        trailingToleranceRatio: Double = 0.02
    ) -> ChartLiveTrackingMode {
        ChartLiveTrackingMode(
            isEnabled: true,
            pauseOnUserInteraction: pauseOnUserInteraction,
            trailingToleranceRatio: trailingToleranceRatio
        )
    }
}
