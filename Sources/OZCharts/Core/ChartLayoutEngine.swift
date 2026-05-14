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

    public init(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}

public struct ChartPlotLayout: Equatable {
    public let containerSize: CGSize
    public let insets: ChartInsets
    public let plotArea: CGRect

    public init(containerSize: CGSize, insets: ChartInsets) {
        self.containerSize = containerSize
        self.insets = insets
        self.plotArea = ChartLayoutEngine.plotArea(in: containerSize, insets: insets)
    }
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

    public static func plotArea(in size: CGSize, insets: ChartInsets) -> CGRect {
        let origin = CGPoint(
            x: max(0, insets.leading),
            y: max(0, insets.top)
        )
        let width = max(0, size.width - insets.leading - insets.trailing)
        let height = max(0, size.height - insets.top - insets.bottom)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    public static func layout(
        in size: CGSize,
        xAxes: [XAxisConfig],
        yAxes: [YAxisConfig]
    ) -> ChartPlotLayout {
        ChartPlotLayout(containerSize: size, insets: insets(xAxes: xAxes, yAxes: yAxes))
    }
}

extension ChartInsets: Equatable {}
