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
    public var position: CGPoint
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
        position: CGPoint,
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
        self.position = position
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
