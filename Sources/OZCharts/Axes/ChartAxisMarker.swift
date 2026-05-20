//
//  ChartAxisMarker.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public enum ChartAxisMarkerAxis: Hashable {
    case x
    case y
}

public enum ChartAxisMarkerPlacement: Hashable {
    case top
    case bottom
    case leading
    case trailing
}

public enum ChartAxisMarkerCollisionStrategy: Equatable {
    case allowOverlap
    case hideLowerPriority
    case hideLabel
    case shift(maxOffset: CGFloat = 16)
    case stack(spacing: CGFloat = 4)
    case automatic
}

public struct ChartAxisMarkerSelectionOptions: Equatable {
    public var isEnabled: Bool
    public var hitboxRadius: CGFloat
    public var overlappingMode: ChartOverlappingSelectionMode

    public init(
        isEnabled: Bool = false,
        hitboxRadius: CGFloat = 20,
        overlappingMode: ChartOverlappingSelectionMode = .cycle
    ) {
        self.isEnabled = isEnabled
        self.hitboxRadius = hitboxRadius
        self.overlappingMode = overlappingMode
    }

    public static let disabled = ChartAxisMarkerSelectionOptions()

    public static func enabled(
        hitboxRadius: CGFloat = 20,
        overlappingMode: ChartOverlappingSelectionMode = .cycle
    ) -> ChartAxisMarkerSelectionOptions {
        ChartAxisMarkerSelectionOptions(
            isEnabled: true,
            hitboxRadius: hitboxRadius,
            overlappingMode: overlappingMode
        )
    }
}

public struct ChartAxisMarker: Identifiable {
    public let id: UUID
    public let axis: ChartAxisMarkerAxis
    public let value: Double
    public let placement: ChartAxisMarkerPlacement
    public let offset: CGSize
    public let priority: Double
    public let collisionStrategy: ChartAxisMarkerCollisionStrategy
    public let hitboxRadius: CGFloat?
    public let accessibilityLabel: String?
    public let content: AnyView
    public let compactContent: AnyView?

    public init<Content: View>(
        id: UUID = UUID(),
        axis: ChartAxisMarkerAxis,
        value: Double,
        placement: ChartAxisMarkerPlacement,
        offset: CGSize = .zero,
        priority: Double = 0,
        collisionStrategy: ChartAxisMarkerCollisionStrategy = .allowOverlap,
        hitboxRadius: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.axis = axis
        self.value = value
        self.placement = placement
        self.offset = offset
        self.priority = priority
        self.collisionStrategy = collisionStrategy
        self.hitboxRadius = hitboxRadius
        self.accessibilityLabel = accessibilityLabel
        self.content = AnyView(content())
        self.compactContent = nil
    }

    public init<Content: View, CompactContent: View>(
        id: UUID = UUID(),
        axis: ChartAxisMarkerAxis,
        value: Double,
        placement: ChartAxisMarkerPlacement,
        offset: CGSize = .zero,
        priority: Double = 0,
        collisionStrategy: ChartAxisMarkerCollisionStrategy = .allowOverlap,
        hitboxRadius: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder compactContent: () -> CompactContent,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.axis = axis
        self.value = value
        self.placement = placement
        self.offset = offset
        self.priority = priority
        self.collisionStrategy = collisionStrategy
        self.hitboxRadius = hitboxRadius
        self.accessibilityLabel = accessibilityLabel
        self.content = AnyView(content())
        self.compactContent = AnyView(compactContent())
    }

    public static func x<Content: View>(
        id: UUID = UUID(),
        value: Double,
        placement: ChartAxisMarkerPlacement = .bottom,
        offset: CGSize = .zero,
        priority: Double = 0,
        collisionStrategy: ChartAxisMarkerCollisionStrategy = .allowOverlap,
        hitboxRadius: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> ChartAxisMarker {
        ChartAxisMarker(
            id: id,
            axis: .x,
            value: value,
            placement: placement,
            offset: offset,
            priority: priority,
            collisionStrategy: collisionStrategy,
            hitboxRadius: hitboxRadius,
            accessibilityLabel: accessibilityLabel,
            content: content
        )
    }

    public static func x<Content: View, CompactContent: View>(
        id: UUID = UUID(),
        value: Double,
        placement: ChartAxisMarkerPlacement = .bottom,
        offset: CGSize = .zero,
        priority: Double = 0,
        collisionStrategy: ChartAxisMarkerCollisionStrategy = .allowOverlap,
        hitboxRadius: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder compactContent: () -> CompactContent,
        @ViewBuilder content: () -> Content
    ) -> ChartAxisMarker {
        ChartAxisMarker(
            id: id,
            axis: .x,
            value: value,
            placement: placement,
            offset: offset,
            priority: priority,
            collisionStrategy: collisionStrategy,
            hitboxRadius: hitboxRadius,
            accessibilityLabel: accessibilityLabel,
            compactContent: compactContent,
            content: content
        )
    }

    public static func y<Content: View>(
        id: UUID = UUID(),
        value: Double,
        placement: ChartAxisMarkerPlacement = .leading,
        offset: CGSize = .zero,
        priority: Double = 0,
        collisionStrategy: ChartAxisMarkerCollisionStrategy = .allowOverlap,
        hitboxRadius: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> ChartAxisMarker {
        ChartAxisMarker(
            id: id,
            axis: .y,
            value: value,
            placement: placement,
            offset: offset,
            priority: priority,
            collisionStrategy: collisionStrategy,
            hitboxRadius: hitboxRadius,
            accessibilityLabel: accessibilityLabel,
            content: content
        )
    }

    public static func y<Content: View, CompactContent: View>(
        id: UUID = UUID(),
        value: Double,
        placement: ChartAxisMarkerPlacement = .leading,
        offset: CGSize = .zero,
        priority: Double = 0,
        collisionStrategy: ChartAxisMarkerCollisionStrategy = .allowOverlap,
        hitboxRadius: CGFloat? = nil,
        accessibilityLabel: String? = nil,
        @ViewBuilder compactContent: () -> CompactContent,
        @ViewBuilder content: () -> Content
    ) -> ChartAxisMarker {
        ChartAxisMarker(
            id: id,
            axis: .y,
            value: value,
            placement: placement,
            offset: offset,
            priority: priority,
            collisionStrategy: collisionStrategy,
            hitboxRadius: hitboxRadius,
            accessibilityLabel: accessibilityLabel,
            compactContent: compactContent,
            content: content
        )
    }
}

public struct ChartAxisMarkerContext: Identifiable {
    public let id: UUID
    public let marker: ChartAxisMarker
    public let anchor: CGPoint
    public let position: CGPoint
    public let frame: CGRect
    public let usesCompactContent: Bool

    init(
        marker: ChartAxisMarker,
        anchor: CGPoint,
        position: CGPoint,
        frame: CGRect,
        usesCompactContent: Bool
    ) {
        self.id = marker.id
        self.marker = marker
        self.anchor = anchor
        self.position = position
        self.frame = frame
        self.usesCompactContent = usesCompactContent
    }
}
