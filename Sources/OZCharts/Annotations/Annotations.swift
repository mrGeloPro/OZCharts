//
//  Annotations.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

// MARK: - XRangeAnnotation

public struct XRangeAnnotation {
    public let xRange: ClosedRange<Double>
    public let label: String?
    public let color: Color
    public let opacity: Double

    public init(
        xRange: ClosedRange<Double>,
        label: String? = nil,
        color: Color = .gray,
        opacity: Double = 0.12
    ) {
        self.xRange = xRange
        self.label = label
        self.color = color
        self.opacity = opacity
    }
}

// MARK: - XYRangeAnnotation

public struct XYRangeAnnotation {
    public let xRange: ClosedRange<Double>
    public let yRange: ClosedRange<Double>
    public let label: String?
    public let color: Color
    public let opacity: Double

    public init(
        xRange: ClosedRange<Double>,
        yRange: ClosedRange<Double>,
        label: String? = nil,
        color: Color = .gray,
        opacity: Double = 0.12
    ) {
        self.xRange = xRange
        self.yRange = yRange
        self.label = label
        self.color = color
        self.opacity = opacity
    }
}

// MARK: - VerticalAnnotation

public struct VerticalAnnotation {
    public let xValue: Double
    public let label: String
    public let color: Color
    public let lineWidth: CGFloat
    public let dash: [CGFloat]

    public init(
        xValue: Double,
        label: String,
        color: Color = .yellow,
        lineWidth: CGFloat = 2,
        dash: [CGFloat] = [5, 5]
    ) {
        self.xValue = xValue
        self.label = label
        self.color = color
        self.lineWidth = lineWidth
        self.dash = dash
    }
}

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

// MARK: - RangeAnnotation

public struct RangeAnnotation {
    public let yRange: ClosedRange<Double>
    public let label: String?
    public let color: Color
    public let opacity: Double
    public let labelColor: Color
    public let labelFont: Font
    public let showsLabel: Bool
    public let labelXPosition: CGFloat
    public let labelAnchor: UnitPoint
    public let labelYOffset: CGFloat

    public init(
        yRange: ClosedRange<Double>,
        label: String? = nil,
        color: Color = .green,
        opacity: Double = 0.12,
        labelColor: Color = .primary,
        labelFont: Font = .caption2,
        showsLabel: Bool = false,
        labelXPosition: CGFloat = 0.5,
        labelAnchor: UnitPoint = .center,
        labelYOffset: CGFloat = 0
    ) {
        self.yRange = yRange
        self.label = label
        self.color = color
        self.opacity = opacity
        self.labelColor = labelColor
        self.labelFont = labelFont
        self.showsLabel = showsLabel
        self.labelXPosition = labelXPosition
        self.labelAnchor = labelAnchor
        self.labelYOffset = labelYOffset
    }
}

// MARK: - ChartEventMarker

public struct ChartEventMarker: Identifiable {
    public let id: UUID
    public let x: Double
    public let y: Double
    public let label: String?
    public let shape: ChartSymbolShape
    public let color: Color
    public let size: CGFloat
    public let strokeColor: Color
    public let strokeWidth: CGFloat
    public let isSelectable: Bool
    public let hitboxRadius: CGFloat?

    public init(
        id: UUID = UUID(),
        x: Double,
        y: Double,
        label: String? = nil,
        shape: ChartSymbolShape = .circle,
        color: Color = .yellow,
        size: CGFloat = 16,
        strokeColor: Color = .black.opacity(0.3),
        strokeWidth: CGFloat = 1,
        isSelectable: Bool = true,
        hitboxRadius: CGFloat? = nil
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.label = label
        self.shape = shape
        self.color = color
        self.size = size
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.isSelectable = isSelectable
        self.hitboxRadius = hitboxRadius
    }

    public var pointAnnotation: PointAnnotation<Double, Double> {
        PointAnnotation(
            id: id,
            x: x,
            y: y,
            label: label,
            shape: shape,
            color: color,
            size: size,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            isSelectable: isSelectable,
            hitboxRadius: hitboxRadius
        )
    }
}

// MARK: - PointAnnotation

public struct PointAnnotation<X: Comparable, Y: Comparable>: Identifiable {
    public let id: UUID
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
        id: UUID = UUID(),
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
        self.id          = id
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
    public let id: UUID
    public let x: X
    public let y: Y
    public let label: String?
    public let placement: ChartLabelPlacement
    public let collisionPriority: Int
    public let avoidsCollisions: Bool
    public let padding: CGFloat
    public let isSelectable: Bool
    public let hitboxRadius: CGFloat?
    public let content: AnyView

    public init<V: View>(
        id: UUID = UUID(),
        x: X,
        y: Y,
        label: String? = nil,
        placement: ChartLabelPlacement = .center,
        collisionPriority: Int = 0,
        avoidsCollisions: Bool = true,
        padding: CGFloat = 8,
        isSelectable: Bool = false,
        hitboxRadius: CGFloat? = nil,
        @ViewBuilder content: () -> V
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.label = label
        self.placement = placement
        self.collisionPriority = collisionPriority
        self.avoidsCollisions = avoidsCollisions
        self.padding = padding
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
