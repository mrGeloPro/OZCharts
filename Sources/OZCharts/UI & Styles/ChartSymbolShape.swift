//
//  ChartSymbolShape.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 15.04.2026.
//

import SwiftUI

public enum ChartSymbolShape: Hashable {
    case circle
    case square
    case triangle
    case diamond
    case cross
    case star
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        switch self {
        case .circle:
            path.addEllipse(in: rect)
        case .square:
            path.addRect(rect)
        case .triangle:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
        case .diamond:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
        case .cross:
            let t = rect.width * 0.3 // Товщина ліній хрестика
            path.addRect(CGRect(x: rect.midX - t/2, y: rect.minY, width: t, height: rect.height))
            path.addRect(CGRect(x: rect.minX, y: rect.midY - t/2, width: rect.width, height: t))
        case .star:
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let rOuter = rect.width / 2
            let rInner = rOuter * 0.4
            for i in 0..<10 {
                let radius = (i % 2 == 0) ? rOuter : rInner
                let angle = Double(i) * (.pi / 5) - .pi / 2
                let pt = CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        }
        return path
    }
}
