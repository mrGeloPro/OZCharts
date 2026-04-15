//
//  PolarCoordinator.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import SwiftUI

public struct PolarSegment {
    public let startAngle: Angle
    public let endAngle: Angle
    public let color: Color
}

public final class PolarCoordinator {
    public init() {}
    
    public func calculateSegments(from values: [Double], colors: [Color]) -> [PolarSegment] {
        let total = values.reduce(0, +)
        var currentAngle: Double = -90
        
        return values.enumerated().map { index, value in
            let delta = (value / total) * 360.0
            let start = Angle(degrees: currentAngle)
            let end = Angle(degrees: currentAngle + delta)
            currentAngle += delta
            
            return PolarSegment(
                startAngle: start,
                endAngle: end, 
                color: colors[safe: index] ?? .gray
            )
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
