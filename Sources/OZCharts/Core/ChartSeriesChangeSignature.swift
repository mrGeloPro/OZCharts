//
//  ChartSeriesChangeSignature.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation

struct ChartSeriesChangeSignature: Equatable {
    let seriesID: UUID
    let zIndex: Int
    let layoutSignature: ChartSeriesSignature
    let renderSignature: ChartSeriesSignature
    let points: [ChartPointValueSignature]
}

struct ChartPointValueSignature: Equatable {
    let x: Double
    let y: Double
}
