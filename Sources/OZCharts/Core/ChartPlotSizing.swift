//
//  ChartPlotSizing.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

enum ChartPlotSizing {
    static func plotSize(in availableSize: CGSize, plotInsets: ChartInsets) -> CGSize {
        ChartLayoutEngine
            .plotArea(in: availableSize, insets: plotInsets)
            .size
    }

    static func totalCanvasSize(
        plotAreaSize: CGSize?,
        layoutInsets: ChartInsets?
    ) -> CGSize? {
        guard let plotAreaSize else { return nil }
        guard let layoutInsets else { return plotAreaSize }

        return CGSize(
            width: plotAreaSize.width + layoutInsets.leading + layoutInsets.trailing,
            height: plotAreaSize.height + layoutInsets.top + layoutInsets.bottom
        )
    }
}
