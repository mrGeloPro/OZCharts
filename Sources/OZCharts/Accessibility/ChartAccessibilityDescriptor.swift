//
//  ChartAccessibilityDescriptor.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

public struct ChartAccessibilityDescriptor<Point: ChartDataPoint>
where Point.XValue == Double, Point.YValue == Double {
    public var label: String
    public var summary: String?
    public var selectedValueFormatter: ([ChartPointContext<Point>]) -> String?

    public init(
        label: String,
        summary: String? = nil,
        selectedValueFormatter: @escaping ([ChartPointContext<Point>]) -> String? = { points in
            guard let point = points.first else { return nil }
            return "Selected x \(point.originalPoint.x), y \(point.originalPoint.y)"
        }
    ) {
        self.label = label
        self.summary = summary
        self.selectedValueFormatter = selectedValueFormatter
    }

    func value(for selectedPoints: [ChartPointContext<Point>]) -> String {
        selectedValueFormatter(selectedPoints) ?? summary ?? ""
    }
}
