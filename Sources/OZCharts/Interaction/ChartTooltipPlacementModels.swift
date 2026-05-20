//
//  ChartTooltipPlacementModels.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public enum ChartTooltipPlacement: Equatable {
    case automatic
    case top
    case bottom
    case leading
    case trailing
    case center
    case fixed(CGPoint)
}

enum ChartTooltipAttachment: Equatable {
    case top
    case bottom
    case leading
    case trailing
    case center
    case fixed
}

struct ChartTooltipLayoutResult: Equatable {
    var position: CGPoint
    var attachment: ChartTooltipAttachment
    var anchor: CGPoint
    var wasClamped: Bool
}

struct ChartTooltipOverflowAllowance: Equatable {
    var leading: CGFloat
    var trailing: CGFloat
    var top: CGFloat
    var bottom: CGFloat

    static let zero = ChartTooltipOverflowAllowance()

    init(
        leading: CGFloat = 0,
        trailing: CGFloat = 0,
        top: CGFloat = 0,
        bottom: CGFloat = 0
    ) {
        self.leading = max(0, leading)
        self.trailing = max(0, trailing)
        self.top = max(0, top)
        self.bottom = max(0, bottom)
    }

    init(symmetric size: CGSize) {
        self.init(
            leading: size.width,
            trailing: size.width,
            top: size.height,
            bottom: size.height
        )
    }
}
