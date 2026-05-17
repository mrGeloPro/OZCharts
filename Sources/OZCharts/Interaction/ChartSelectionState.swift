//
//  ChartSelectionState.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import Foundation

public struct ChartSelectedPoint: Equatable, Identifiable {
    public var id: UUID { pointID }
    public var pointID: UUID
    public var seriesID: UUID?
    public var seriesIndex: Int?
    public var x: Double
    public var y: Double

    public init(
        pointID: UUID,
        seriesID: UUID? = nil,
        seriesIndex: Int? = nil,
        x: Double,
        y: Double
    ) {
        self.pointID = pointID
        self.seriesID = seriesID
        self.seriesIndex = seriesIndex
        self.x = x
        self.y = y
    }
}

public enum ChartSelectedElementKind: Equatable {
    case point
    case bar
    case stackedBarSegment
    case stackedBarRemainder
    case stackedBarRow
    case donutSegment
    case annotation
    case custom(String)
}

public struct ChartSelectedElement: Equatable, Identifiable {
    public var id: UUID { elementID }
    public var elementID: UUID
    public var kind: ChartSelectedElementKind
    public var seriesID: UUID?
    public var seriesIndex: Int?
    public var pointID: UUID?
    public var segmentIndex: Int?
    public var groupLabel: String?
    public var label: String?
    public var x: Double?
    public var y: Double?
    public var value: Double?
    public var totalValue: Double?
    public var rowIndex: Int?
    public var rowLabel: String?
    public var isSupplementary: Bool
    public var position: CGPoint
    public var interactionPosition: CGPoint?
    public var bounds: CGRect

    public init(
        elementID: UUID,
        kind: ChartSelectedElementKind,
        seriesID: UUID? = nil,
        seriesIndex: Int? = nil,
        pointID: UUID? = nil,
        segmentIndex: Int? = nil,
        groupLabel: String? = nil,
        label: String? = nil,
        x: Double? = nil,
        y: Double? = nil,
        value: Double? = nil,
        totalValue: Double? = nil,
        rowIndex: Int? = nil,
        rowLabel: String? = nil,
        isSupplementary: Bool = false,
        position: CGPoint,
        interactionPosition: CGPoint? = nil,
        bounds: CGRect
    ) {
        self.elementID = elementID
        self.kind = kind
        self.seriesID = seriesID
        self.seriesIndex = seriesIndex
        self.pointID = pointID
        self.segmentIndex = segmentIndex
        self.groupLabel = groupLabel
        self.label = label
        self.x = x
        self.y = y
        self.value = value
        self.totalValue = totalValue
        self.rowIndex = rowIndex
        self.rowLabel = rowLabel
        self.isSupplementary = isSupplementary
        self.position = position
        self.interactionPosition = interactionPosition
        self.bounds = bounds
    }
}

public struct ChartSelectionState: Equatable {
    public var selectedX: Double?
    public var selectedPoints: [ChartSelectedPoint]
    public var selectedElements: [ChartSelectedElement]

    public init(
        selectedX: Double? = nil,
        selectedPoints: [ChartSelectedPoint] = [],
        selectedElements: [ChartSelectedElement] = []
    ) {
        self.selectedX = selectedX
        self.selectedPoints = selectedPoints
        self.selectedElements = selectedElements
    }

    public static let none = ChartSelectionState()
}

public struct ChartSelection<Point: ChartDataPoint> where Point.XValue == Double, Point.YValue == Double {
    public var points: [ChartPointContext<Point>]
    public var elements: [ChartSelectedElement]
    public var annotations: [ChartAnnotationContext]
    public var state: ChartSelectionState

    public init(
        points: [ChartPointContext<Point>] = [],
        elements: [ChartSelectedElement] = [],
        annotations: [ChartAnnotationContext] = [],
        state: ChartSelectionState = .none
    ) {
        self.points = points
        self.elements = elements
        self.annotations = annotations
        self.state = state
    }

    public var isEmpty: Bool {
        points.isEmpty && elements.isEmpty && annotations.isEmpty
    }

    public var primaryPoint: ChartPointContext<Point>? {
        points.first
    }

    public var primaryElement: ChartSelectedElement? {
        elements.first
    }

    public var primaryAnnotation: ChartAnnotationContext? {
        annotations.first
    }

    public static var none: ChartSelection<Point> {
        ChartSelection()
    }
}

extension ChartSelectedElement {
    var tooltipInteractionAnchor: CGPoint {
        guard let interactionPosition else { return position }
        guard bounds.width > 0, bounds.height > 0 else { return interactionPosition }

        return CGPoint(
            x: min(max(interactionPosition.x, bounds.minX), bounds.maxX),
            y: min(max(interactionPosition.y, bounds.minY), bounds.maxY)
        )
    }
}
