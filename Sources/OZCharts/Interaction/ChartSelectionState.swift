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

public enum ChartSelectionAnchorKind: Equatable {
    case point
    case element
    case annotation
}

public struct ChartSelectionAnchor: Equatable {
    public var kind: ChartSelectionAnchorKind
    public var position: CGPoint
    public var interactionPosition: CGPoint?
    public var bounds: CGRect?
    public var seriesID: UUID?
    public var seriesIndex: Int?
    public var pointID: UUID?
    public var segmentIndex: Int?
    public var rowIndex: Int?
    public var rowLabel: String?
    public var label: String?
    public var x: Double?
    public var y: Double?
    public var value: Double?

    public init(
        kind: ChartSelectionAnchorKind,
        position: CGPoint,
        interactionPosition: CGPoint? = nil,
        bounds: CGRect? = nil,
        seriesID: UUID? = nil,
        seriesIndex: Int? = nil,
        pointID: UUID? = nil,
        segmentIndex: Int? = nil,
        rowIndex: Int? = nil,
        rowLabel: String? = nil,
        label: String? = nil,
        x: Double? = nil,
        y: Double? = nil,
        value: Double? = nil
    ) {
        self.kind = kind
        self.position = position
        self.interactionPosition = interactionPosition
        self.bounds = bounds
        self.seriesID = seriesID
        self.seriesIndex = seriesIndex
        self.pointID = pointID
        self.segmentIndex = segmentIndex
        self.rowIndex = rowIndex
        self.rowLabel = rowLabel
        self.label = label
        self.x = x
        self.y = y
        self.value = value
    }
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

    public var primaryAnchor: ChartSelectionAnchor? {
        if let element = primaryElement {
            return ChartSelectionAnchor(element: element)
        }
        if let point = primaryPoint {
            return ChartSelectionAnchor(point: point, payload: state.selectedPoints.first)
        }
        if let annotation = primaryAnnotation {
            return ChartSelectionAnchor(annotation: annotation)
        }
        return nil
    }

    public var primaryPosition: CGPoint? {
        primaryAnchor?.position
    }

    public var primaryBounds: CGRect? {
        primaryAnchor?.bounds
    }

    public static var none: ChartSelection<Point> {
        ChartSelection()
    }
}

public extension ChartSelectionAnchor {
    init(element: ChartSelectedElement) {
        self.init(
            kind: .element,
            position: element.tooltipInteractionAnchor,
            interactionPosition: element.interactionPosition,
            bounds: element.bounds,
            seriesID: element.seriesID,
            seriesIndex: element.seriesIndex,
            pointID: element.pointID,
            segmentIndex: element.segmentIndex,
            rowIndex: element.rowIndex,
            rowLabel: element.rowLabel,
            label: element.label ?? element.groupLabel,
            x: element.x,
            y: element.y,
            value: element.value
        )
    }

    init<Point: ChartDataPoint>(
        point: ChartPointContext<Point>,
        payload: ChartSelectedPoint? = nil
    ) where Point.XValue == Double, Point.YValue == Double {
        self.init(
            kind: .point,
            position: point.position,
            seriesID: payload?.seriesID,
            seriesIndex: payload?.seriesIndex,
            pointID: point.id,
            x: point.originalPoint.x,
            y: point.originalPoint.y,
            value: point.originalPoint.y
        )
    }

    init(annotation: ChartAnnotationContext) {
        let bounds = annotation.hitboxRadius.map { radius in
            CGRect(
                x: annotation.position.x - radius,
                y: annotation.position.y - radius,
                width: radius * 2,
                height: radius * 2
            )
        }
        self.init(
            kind: .annotation,
            position: annotation.position,
            bounds: bounds,
            pointID: annotation.id,
            label: annotation.label,
            x: annotation.x,
            y: annotation.y,
            value: annotation.y
        )
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
