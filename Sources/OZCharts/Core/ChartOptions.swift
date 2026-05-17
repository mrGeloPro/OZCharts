//
//  ChartOptions.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public enum ChartTooltipAnchor: Equatable {
    case selectedValue
    case tapLocation
    case elementCenter
    case hitPoint
}

public enum ChartTooltipArrowEdge: Equatable, Sendable {
    case top
    case bottom
    case leading
    case trailing
    case none
}

public enum ChartSelectionActivation: Equatable, Sendable {
    case immediate
    case onTapEnd
}

public enum ChartNearestSelectionPolicy: Equatable, Sendable {
    case unbounded
    case withinHitbox
    case within(CGFloat)

    func maximumDistance(for hitboxRadius: CGFloat) -> CGFloat? {
        switch self {
        case .unbounded:
            nil
        case .withinHitbox:
            hitboxRadius
        case let .within(distance):
            max(0, distance)
        }
    }
}

public struct ChartElementTooltipContext {
    public var elements: [ChartSelectedElement]
    public var anchor: CGPoint
    public var position: CGPoint
    public var arrowEdge: ChartTooltipArrowEdge
    public var arrowXOffset: CGFloat
    public var arrowYOffset: CGFloat
    public var wasClamped: Bool

    public init(
        elements: [ChartSelectedElement],
        anchor: CGPoint,
        position: CGPoint,
        arrowEdge: ChartTooltipArrowEdge,
        arrowXOffset: CGFloat,
        arrowYOffset: CGFloat,
        wasClamped: Bool
    ) {
        self.elements = elements
        self.anchor = anchor
        self.position = position
        self.arrowEdge = arrowEdge
        self.arrowXOffset = arrowXOffset
        self.arrowYOffset = arrowYOffset
        self.wasClamped = wasClamped
    }
}

public enum ChartSelectionPriority: Equatable {
    case annotationsFirst
    case seriesFirst
    case annotationsOnly
    case seriesOnly
}

public struct ChartInteractionOptions: Equatable {
    public var isHorizontalScrollEnabled: Bool
    public var isVerticalScrollEnabled: Bool
    public var isHorizontalZoomEnabled: Bool
    public var isVerticalZoomEnabled: Bool
    public var minZoomScale: Double

    public init(
        isHorizontalScrollEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        minZoomScale: Double = 0.05
    ) {
        self.isHorizontalScrollEnabled = isHorizontalScrollEnabled
        self.isVerticalScrollEnabled = isVerticalScrollEnabled
        self.isHorizontalZoomEnabled = isHorizontalZoomEnabled
        self.isVerticalZoomEnabled = isVerticalZoomEnabled
        self.minZoomScale = minZoomScale
    }

    public static let automatic = ChartInteractionOptions()
    public static let `static` = ChartInteractionOptions(
        isHorizontalScrollEnabled: false,
        isVerticalScrollEnabled: false,
        isHorizontalZoomEnabled: false,
        isVerticalZoomEnabled: false
    )
    public static let disabled = ChartInteractionOptions(
        isHorizontalScrollEnabled: false,
        isVerticalScrollEnabled: false,
        isHorizontalZoomEnabled: false,
        isVerticalZoomEnabled: false
    )
}

public struct ChartSelectionOptions: Equatable {
    public var mode: ChartSelectionMode
    public var behavior: ChartSelectionBehavior
    public var overlappingSelectionMode: ChartOverlappingSelectionMode
    public var hitboxRadius: CGFloat
    public var dismissalPolicy: ChartSelectionDismissalPolicy
    public var activation: ChartSelectionActivation
    public var nearestSelectionPolicy: ChartNearestSelectionPolicy

    public init(
        mode: ChartSelectionMode = .pointsInRadius,
        behavior: ChartSelectionBehavior = .tap,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        hitboxRadius: CGFloat = 20,
        dismissalPolicy: ChartSelectionDismissalPolicy = .transient,
        activation: ChartSelectionActivation = .immediate,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded
    ) {
        self.mode = mode
        self.behavior = behavior
        self.overlappingSelectionMode = overlappingSelectionMode
        self.hitboxRadius = hitboxRadius
        self.dismissalPolicy = dismissalPolicy
        self.activation = activation
        self.nearestSelectionPolicy = nearestSelectionPolicy
    }

    public static let disabled = ChartSelectionOptions(
        mode: .none,
        behavior: .disabled,
        hitboxRadius: 0,
        dismissalPolicy: .transient
    )

    public static let nearestX = ChartSelectionOptions(
        mode: .nearestX,
        behavior: .tapAndDrag,
        hitboxRadius: 24,
        dismissalPolicy: .tapOutside
    )

    public static let scrollSafeNearestX = ChartSelectionOptions(
        mode: .nearestX,
        behavior: .tapAndDrag,
        hitboxRadius: 28,
        dismissalPolicy: .tapOutside,
        activation: .onTapEnd,
        nearestSelectionPolicy: .withinHitbox
    )

    public static let transientElement = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .all,
        hitboxRadius: 24,
        dismissalPolicy: .transient
    )

    public static let persistentElement = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .all,
        hitboxRadius: 24,
        dismissalPolicy: .tapOutside
    )

    public static let pinnedElement = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .all,
        hitboxRadius: 24,
        dismissalPolicy: .pinned
    )

    public static let eventOnly = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .cycle,
        hitboxRadius: 32,
        dismissalPolicy: .transient
    )
    public static let eventThenNearestPoint = ChartSelectionOptions.nearestX
}

public struct ChartSelectionDismissalPolicy: OptionSet, Equatable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let gestureEnd = ChartSelectionDismissalPolicy(rawValue: 1 << 0)
    public static let tapOutside = ChartSelectionDismissalPolicy(rawValue: 1 << 1)
    public static let drag = ChartSelectionDismissalPolicy(rawValue: 1 << 2)
    public static let viewportChange = ChartSelectionDismissalPolicy(rawValue: 1 << 3)

    public static let none: ChartSelectionDismissalPolicy = []
    public static let transient: ChartSelectionDismissalPolicy = [.gestureEnd, .tapOutside, .drag, .viewportChange]
    public static let persistent: ChartSelectionDismissalPolicy = [.tapOutside, .drag, .viewportChange]
    public static let pinned: ChartSelectionDismissalPolicy = []
}

public struct ChartTooltipOptions: Equatable {
    public var placement: ChartTooltipPlacement
    public var anchor: ChartTooltipAnchor
    public var offset: CGPoint
    public var padding: CGFloat
    public var maxWidth: CGFloat?

    public init(
        placement: ChartTooltipPlacement = .automatic,
        anchor: ChartTooltipAnchor = .selectedValue,
        offset: CGPoint = CGPoint(x: 0, y: -20),
        padding: CGFloat = 8,
        maxWidth: CGFloat? = nil
    ) {
        self.placement = placement
        self.anchor = anchor
        self.offset = offset
        self.padding = padding
        self.maxWidth = maxWidth
    }

    public static let automatic = ChartTooltipOptions()

    public static func tapLocation(
        placement: ChartTooltipPlacement = .automatic,
        offset: CGPoint = CGPoint(x: 0, y: -20),
        padding: CGFloat = 8,
        maxWidth: CGFloat? = nil
    ) -> ChartTooltipOptions {
        ChartTooltipOptions(
            placement: placement,
            anchor: .tapLocation,
            offset: offset,
            padding: padding,
            maxWidth: maxWidth
        )
    }

    public static func hitPoint(
        placement: ChartTooltipPlacement = .automatic,
        offset: CGPoint = CGPoint(x: 0, y: -20),
        padding: CGFloat = 8,
        maxWidth: CGFloat? = nil
    ) -> ChartTooltipOptions {
        ChartTooltipOptions(
            placement: placement,
            anchor: .hitPoint,
            offset: offset,
            padding: padding,
            maxWidth: maxWidth
        )
    }

    public static func elementCenter(
        placement: ChartTooltipPlacement = .automatic,
        offset: CGPoint = CGPoint(x: 0, y: -20),
        padding: CGFloat = 8,
        maxWidth: CGFloat? = nil
    ) -> ChartTooltipOptions {
        ChartTooltipOptions(
            placement: placement,
            anchor: .elementCenter,
            offset: offset,
            padding: padding,
            maxWidth: maxWidth
        )
    }
}

public struct ChartViewportOptions: Equatable {
    public var liveTrackingMode: ChartLiveTrackingMode
    public var initialViewport: ChartInitialViewport?
    public var showsZoomControls: Bool
    public var zoomControlStep: Double

    public init(
        liveTrackingMode: ChartLiveTrackingMode = .disabled,
        initialViewport: ChartInitialViewport? = nil,
        showsZoomControls: Bool = false,
        zoomControlStep: Double = 2
    ) {
        self.liveTrackingMode = liveTrackingMode
        self.initialViewport = initialViewport
        self.showsZoomControls = showsZoomControls
        self.zoomControlStep = zoomControlStep
    }

    public static let automatic = ChartViewportOptions()
}

public struct ChartRenderOptions {
    public var legendOptions: ChartLegendOptions
    public var legendPosition: ChartLegendPosition {
        get { legendOptions.position }
        set { legendOptions.position = newValue }
    }
    public var legendSpacing: CGFloat {
        get { legendOptions.itemSpacing }
        set { legendOptions.itemSpacing = newValue }
    }
    public var selectedElementStyle: ChartSelectedElementStyle
    public var canvasRenderOrder: [CanvasLayer]

    public init(
        legendPosition: ChartLegendPosition = .hidden,
        legendSpacing: CGFloat = 12,
        selectedElementStyle: ChartSelectedElementStyle = .product,
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart]
    ) {
        self.legendOptions = ChartLegendOptions(position: legendPosition, itemSpacing: legendSpacing)
        self.selectedElementStyle = selectedElementStyle
        self.canvasRenderOrder = canvasRenderOrder
    }

    public init(
        legend: ChartLegendOptions,
        selectedElementStyle: ChartSelectedElementStyle = .product,
        canvasRenderOrder: [CanvasLayer] = [.grid, .rangeAnnotations, .horizontalAnnotations, .pointAnnotations, .coreChart]
    ) {
        self.legendOptions = legend
        self.selectedElementStyle = selectedElementStyle
        self.canvasRenderOrder = canvasRenderOrder
    }

    public static let automatic = ChartRenderOptions()

    public static func dashboard(
        legend: ChartLegendPosition = .bottom,
        spacing: CGFloat = 10
    ) -> ChartRenderOptions {
        ChartRenderOptions(
            legend: ChartLegendOptions.dashboard(position: legend),
            selectedElementStyle: .product
        ).withLegendSpacing(spacing)
    }

    public static func dashboard(
        legend: ChartLegendOptions
    ) -> ChartRenderOptions {
        ChartRenderOptions(
            legend: legend,
            selectedElementStyle: .product
        )
    }

    private func withLegendSpacing(_ spacing: CGFloat) -> ChartRenderOptions {
        var copy = self
        copy.legendSpacing = spacing
        return copy
    }
}
