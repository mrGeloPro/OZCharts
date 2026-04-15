//
//  PointAnnotation.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 15.04.2026.
//

import Foundation
import SwiftUI

public struct PointAnnotation<X: Comparable, Y: Comparable>: Identifiable {
    public let id = UUID()
    public let x: X
    public let y: Y
    public let shape: ChartSymbolShape
    public let color: Color
    public let size: CGFloat
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    
    public init(x: X, y: Y, shape: ChartSymbolShape, color: Color = .yellow, size: CGFloat = 16, strokeColor: Color = .black.opacity(0.3), strokeWidth: CGFloat = 1) {
        self.x = x
        self.y = y
        self.shape = shape
        self.color = color
        self.size = size
        self.strokeColor = strokeColor
                self.strokeWidth = strokeWidth
    }
}
