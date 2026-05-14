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
    public var selectedElementFormatter: ([ChartSelectedElement]) -> String?

    public init(
        label: String,
        summary: String? = nil,
        selectedValueFormatter: @escaping ([ChartPointContext<Point>]) -> String? = { points in
            guard let point = points.first else { return nil }
            return "Selected x \(point.originalPoint.x), y \(point.originalPoint.y)"
        },
        selectedElementFormatter: @escaping ([ChartSelectedElement]) -> String? = { elements in
            guard let element = elements.first else { return nil }
            if let label = element.label {
                return "Selected \(label)"
            }
            return element.value.map { "Selected value \($0)" }
        }
    ) {
        self.label = label
        self.summary = summary
        self.selectedValueFormatter = selectedValueFormatter
        self.selectedElementFormatter = selectedElementFormatter
    }

    func value(
        for selectedPoints: [ChartPointContext<Point>],
        selectedElements: [ChartSelectedElement] = []
    ) -> String {
        if !selectedElements.isEmpty,
           let elementValue = selectedElementFormatter(selectedElements) {
            return elementValue
        }
        return selectedValueFormatter(selectedPoints) ?? summary ?? ""
    }
}
