//
//  ChartElementContext.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public enum ChartElementHitShape: Equatable {
    case rect(CGRect)
    case donutSegment(
        center: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        startAngle: Double,
        endAngle: Double
    )

    public var bounds: CGRect {
        switch self {
        case .rect(let rect):
            return rect
        case .donutSegment(let center, _, let outerRadius, _, _):
            return CGRect(
                x: center.x - outerRadius,
                y: center.y - outerRadius,
                width: outerRadius * 2,
                height: outerRadius * 2
            )
        }
    }

    public func contains(_ point: CGPoint) -> Bool {
        switch self {
        case .rect(let rect):
            return rect.contains(point)

        case .donutSegment(let center, let innerRadius, let outerRadius, let startAngle, let endAngle):
            let dx = point.x - center.x
            let dy = point.y - center.y
            let radius = hypot(dx, dy)
            guard radius >= innerRadius, radius <= outerRadius else { return false }

            let angle = normalizedAngle(atan2(Double(dy), Double(dx)))
            let start = normalizedAngle(startAngle)
            let end = normalizedAngle(endAngle)
            if start <= end {
                return angle >= start && angle <= end
            }
            return angle >= start || angle <= end
        }
    }
}

public struct ChartElementContext: Identifiable, Equatable {
    public var id: UUID { payload.elementID }
    public var payload: ChartSelectedElement
    public var hitShape: ChartElementHitShape
    public var zIndex: Int

    public init(
        payload: ChartSelectedElement,
        hitShape: ChartElementHitShape,
        zIndex: Int = 0
    ) {
        self.payload = payload
        self.hitShape = hitShape
        self.zIndex = zIndex
    }

    public func contains(_ point: CGPoint) -> Bool {
        hitShape.contains(point)
    }
}

private func normalizedAngle(_ angle: Double) -> Double {
    let fullTurn = 2 * Double.pi
    let remainder = angle.truncatingRemainder(dividingBy: fullTurn)
    return remainder >= 0 ? remainder : remainder + fullTurn
}
