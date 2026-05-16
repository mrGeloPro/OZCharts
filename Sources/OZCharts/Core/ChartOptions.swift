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
    case gestureLocation
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
    public var clearsSelectionOnGestureEnd: Bool

    public init(
        mode: ChartSelectionMode = .pointsInRadius,
        behavior: ChartSelectionBehavior = .tap,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        hitboxRadius: CGFloat = 20,
        clearsSelectionOnGestureEnd: Bool = true
    ) {
        self.mode = mode
        self.behavior = behavior
        self.overlappingSelectionMode = overlappingSelectionMode
        self.hitboxRadius = hitboxRadius
        self.clearsSelectionOnGestureEnd = clearsSelectionOnGestureEnd
    }

    public static let disabled = ChartSelectionOptions(
        mode: .none,
        behavior: .disabled,
        hitboxRadius: 0,
        clearsSelectionOnGestureEnd: true
    )

    public static let nearestX = ChartSelectionOptions(
        mode: .nearestX,
        behavior: .tapAndDrag,
        hitboxRadius: 24,
        clearsSelectionOnGestureEnd: false
    )

    public static let elementTap = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .all,
        hitboxRadius: 24,
        clearsSelectionOnGestureEnd: false
    )

    public static let elementPress = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .all,
        hitboxRadius: 24,
        clearsSelectionOnGestureEnd: true
    )

    public static let transientElement = elementPress
    public static let persistentElement = elementTap
    public static let eventOnly = ChartSelectionOptions(
        mode: .none,
        behavior: .tap,
        overlappingSelectionMode: .cycle,
        hitboxRadius: 32,
        clearsSelectionOnGestureEnd: true
    )
    public static let eventThenNearestPoint = ChartSelectionOptions.nearestX
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
