//
//  ChartSelectionBehavior.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

public enum ChartSelectionBehavior: Equatable {
    case disabled
    case tap
    case drag
    case tapAndDrag

    var allowsTapSelection: Bool {
        self == .tap || self == .tapAndDrag
    }

    var allowsDragSelection: Bool {
        self == .drag || self == .tapAndDrag
    }
}
