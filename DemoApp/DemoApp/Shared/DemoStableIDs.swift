//
//  DemoStableIDs.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation

enum DemoSeriesID {
    static let viewportSignal = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    static let linkedPrice = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    static let linkedVolume = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!
    static let selectableLine = UUID(uuidString: "10000000-0000-0000-0000-000000000004")!
    static let mixedBars = UUID(uuidString: "10000000-0000-0000-0000-000000000005")!
    static let mixedTrend = UUID(uuidString: "10000000-0000-0000-0000-000000000006")!
    static let donutScore = UUID(uuidString: "10000000-0000-0000-0000-000000000007")!
    static let productLine = UUID(uuidString: "10000000-0000-0000-0000-000000000008")!
    static let violinAccuracy = UUID(uuidString: "10000000-0000-0000-0000-000000000009")!
    static let pointsDistribution = UUID(uuidString: "10000000-0000-0000-0000-000000000010")!
    static let starAchievement = UUID(uuidString: "10000000-0000-0000-0000-000000000011")!
    static let animatedLine = UUID(uuidString: "10000000-0000-0000-0000-000000000012")!
    static let hybridLine = UUID(uuidString: "10000000-0000-0000-0000-000000000013")!
    static let liveTrackingLine = UUID(uuidString: "10000000-0000-0000-0000-000000000014")!
    static let emptyStateLine = UUID(uuidString: "10000000-0000-0000-0000-000000000015")!
    static let axisMarkerLine = UUID(uuidString: "10000000-0000-0000-0000-000000000016")!
}

enum DemoAnnotationID {
    static let starTooltip = UUID(uuidString: "20000000-0000-0000-0000-000000000001")!

    static func starScore(row: Int) -> UUID {
        switch row {
        case 0: return UUID(uuidString: "20000000-0000-0000-0000-000000000010")!
        case 1: return UUID(uuidString: "20000000-0000-0000-0000-000000000011")!
        case 2: return UUID(uuidString: "20000000-0000-0000-0000-000000000012")!
        default: return UUID(uuidString: "20000000-0000-0000-0000-000000000013")!
        }
    }
}

enum DemoAxisMarkerID {
    static let highPriority = UUID(uuidString: "30000000-0000-0000-0000-000000000001")!
    static let compactFallback = UUID(uuidString: "30000000-0000-0000-0000-000000000002")!
    static let shifted = UUID(uuidString: "30000000-0000-0000-0000-000000000003")!
    static let stacked = UUID(uuidString: "30000000-0000-0000-0000-000000000004")!
    static let leadingThreshold = UUID(uuidString: "30000000-0000-0000-0000-000000000005")!
    static let trailingThreshold = UUID(uuidString: "30000000-0000-0000-0000-000000000006")!
}
