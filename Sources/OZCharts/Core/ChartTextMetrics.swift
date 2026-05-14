//
//  ChartTextMetrics.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

enum ChartTextMetrics {
    static func estimatedSize(
        for text: String,
        averageCharacterWidth: CGFloat = 7,
        lineHeight: CGFloat = 14,
        horizontalPadding: CGFloat = 2,
        verticalPadding: CGFloat = 2
    ) -> CGSize {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        let longestLine = lines.map(\.count).max() ?? text.count
        return CGSize(
            width: CGFloat(longestLine) * averageCharacterWidth + horizontalPadding * 2,
            height: CGFloat(max(1, lines.count)) * lineHeight + verticalPadding * 2
        )
    }
}
