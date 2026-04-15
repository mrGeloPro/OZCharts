//
//  HorizontalAnnotation.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 15.04.2026.
//

import Foundation
import SwiftUI

public struct HorizontalAnnotation {
    public let yValue: Double
    public let label: String
    public let color: Color
    public let lineWidth: CGFloat
    public let dash: [CGFloat]
    
    public init(yValue: Double, label: String, color: Color = .yellow, lineWidth: CGFloat = 2, dash: [CGFloat] = [5, 5]) {
        self.yValue = yValue
        self.label = label
        self.color = color
        self.lineWidth = lineWidth
                self.dash = dash
    }
}
