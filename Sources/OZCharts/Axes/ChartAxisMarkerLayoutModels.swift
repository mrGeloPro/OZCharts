//
//  ChartAxisMarkerLayoutModels.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

struct ChartAxisMarkerLayoutCandidate {
    let id: UUID
    let axis: ChartAxisMarkerAxis
    let placement: ChartAxisMarkerPlacement
    let anchor: CGPoint
    let position: CGPoint
    let size: CGSize
    let compactSize: CGSize?
    let priority: Double
    let collisionStrategy: ChartAxisMarkerCollisionStrategy
    let originalIndex: Int
}

struct ChartAxisMarkerLayoutResult {
    let id: UUID
    let anchor: CGPoint
    let position: CGPoint
    let frame: CGRect
    let isVisible: Bool
    let usesCompactContent: Bool
    let originalIndex: Int
}

struct ChartAxisMarkerCollisionGroup: Hashable {
    let axis: ChartAxisMarkerAxis
    let placement: ChartAxisMarkerPlacement
}
