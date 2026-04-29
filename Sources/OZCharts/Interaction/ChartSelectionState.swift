//
//  ChartSelectionState.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

public struct ChartSelectionState: Equatable {
    public var selectedX: Double?

    public init(selectedX: Double? = nil) {
        self.selectedX = selectedX
    }

    public static let none = ChartSelectionState()
}
