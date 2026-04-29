//
//  Annotations.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

// MARK: - HorizontalAnnotation

public struct HorizontalAnnotation {
    public let yValue: Double
    public let label: String
    public let color: Color
    public let lineWidth: CGFloat
    public let dash: [CGFloat]

    public init(
        yValue: Double,
        label: String,
        color: Color        = .yellow,
        lineWidth: CGFloat  = 2,
        dash: [CGFloat]     = [5, 5]
    ) {
        self.yValue    = yValue
        self.label     = label
        self.color     = color
        self.lineWidth = lineWidth
        self.dash      = dash
    }
}

// MARK: - PointAnnotation

public struct PointAnnotation<X: Comparable, Y: Comparable>: Identifiable {
    public let id = UUID()
    public let x: X
    public let y: Y
    public let label: String?
    public let shape: ChartSymbolShape
    public let color: Color
    public let size: CGFloat
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    public let isSelectable: Bool
    public let hitboxRadius: CGFloat?

    public init(
        x: X,
        y: Y,
        label: String?       = nil,
        shape: ChartSymbolShape,
        color: Color        = .yellow,
        size: CGFloat       = 16,
        strokeColor: Color  = .black.opacity(0.3),
        strokeWidth: CGFloat = 1,
        isSelectable: Bool  = false,
        hitboxRadius: CGFloat? = nil
    ) {
        self.x           = x
        self.y           = y
        self.label       = label
        self.shape       = shape
        self.color       = color
        self.size        = size
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.isSelectable = isSelectable
        self.hitboxRadius = hitboxRadius
    }
}

// MARK: - CustomViewAnnotation

public struct CustomViewAnnotation<X: Comparable, Y: Comparable>: Identifiable {
    public let id = UUID()
    public let x: X
    public let y: Y
    public let label: String?
    public let isSelectable: Bool
    public let hitboxRadius: CGFloat?
    public let content: AnyView

    public init<V: View>(
        x: X,
        y: Y,
        label: String? = nil,
        isSelectable: Bool = false,
        hitboxRadius: CGFloat? = nil,
        @ViewBuilder content: () -> V
    ) {
        self.x = x
        self.y = y
        self.label = label
        self.isSelectable = isSelectable
        self.hitboxRadius = hitboxRadius
        self.content = AnyView(content())
    }
}

public enum ChartAnnotationKind: Equatable {
    case point
    case customView
}

public struct ChartAnnotationContext: Identifiable, Equatable {
    public let id: UUID
    public let kind: ChartAnnotationKind
    public let x: Double
    public let y: Double
    public let position: CGPoint
    public let label: String?
    public let hitboxRadius: CGFloat?

    public init(
        id: UUID,
        kind: ChartAnnotationKind,
        x: Double,
        y: Double,
        position: CGPoint,
        label: String? = nil,
        hitboxRadius: CGFloat? = nil
    ) {
        self.id = id
        self.kind = kind
        self.x = x
        self.y = y
        self.position = position
        self.label = label
        self.hitboxRadius = hitboxRadius
    }
}
