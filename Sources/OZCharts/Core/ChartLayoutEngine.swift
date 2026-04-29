//
//  ChartLayoutEngine.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public struct ChartInsets {
    public let top: CGFloat
    public let leading: CGFloat
    public let bottom: CGFloat
    public let trailing: CGFloat
}

public enum ChartLayoutEngine {
    public static func insets(xAxes: [XAxisConfig], yAxes: [YAxisConfig]) -> ChartInsets {
        ChartInsets(
            top:      xAxes.filter { $0.position == .top      }.reduce(0) { $0 + $1.height },
            leading:  yAxes.filter { $0.position == .leading  }.reduce(0) { $0 + $1.width  },
            bottom:   xAxes.filter { $0.position == .bottom   }.reduce(0) { $0 + $1.height },
            trailing: yAxes.filter { $0.position == .trailing }.reduce(0) { $0 + $1.width  }
        )
    }
}
