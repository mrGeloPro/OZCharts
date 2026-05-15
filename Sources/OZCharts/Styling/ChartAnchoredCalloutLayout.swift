//
//  ChartAnchoredCalloutLayout.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

/// Preferred vertical side for a callout whose arrow points at an anchor.
public enum ChartAnchoredCalloutVerticalSide: Equatable {
    case above
    case below

    var opposite: ChartAnchoredCalloutVerticalSide {
        switch self {
        case .above: return .below
        case .below: return .above
        }
    }
}

/// Resolved geometry for an anchor-aware callout.
public struct ChartAnchoredCalloutLayoutResult: Equatable {
    public let center: CGPoint
    public let anchor: CGPoint
    public let side: ChartAnchoredCalloutVerticalSide
    public let arrowXOffset: CGFloat
    public let wasClamped: Bool

    public init(
        center: CGPoint,
        anchor: CGPoint,
        side: ChartAnchoredCalloutVerticalSide,
        arrowXOffset: CGFloat,
        wasClamped: Bool
    ) {
        self.center = center
        self.anchor = anchor
        self.side = side
        self.arrowXOffset = arrowXOffset
        self.wasClamped = wasClamped
    }
}

/// Utilities for positioning product callouts around a precise interaction anchor.
public enum ChartAnchoredCalloutLayout {
    /// Resolves a vertical callout so the card is readable while the arrow points at `anchor`.
    ///
    /// The returned `center` can be used with `CustomViewAnnotation(placement: .fixed(...))`.
    /// Use `arrowXOffset` to horizontally offset a triangle inside the callout view.
    public static func vertical(
        anchor: CGPoint,
        calloutSize: CGSize,
        containerSize: CGSize,
        preferredSide: ChartAnchoredCalloutVerticalSide,
        padding: CGFloat = 8,
        arrowInset: CGFloat = 16,
        arrowOutset: CGFloat = 7,
        sideShiftRatio: CGFloat = 0.95
    ) -> ChartAnchoredCalloutLayoutResult {
        let candidates = [preferredSide, preferredSide.opposite]
        let firstFitting = candidates
            .map {
                candidate(
                    anchor: anchor,
                    calloutSize: calloutSize,
                    containerSize: containerSize,
                    side: $0,
                    padding: padding,
                    arrowInset: arrowInset,
                    arrowOutset: arrowOutset,
                    sideShiftRatio: sideShiftRatio
                )
            }
            .first { !$0.wasClamped }

        return firstFitting ?? candidate(
            anchor: anchor,
            calloutSize: calloutSize,
            containerSize: containerSize,
            side: preferredSide,
            padding: padding,
            arrowInset: arrowInset,
            arrowOutset: arrowOutset,
            sideShiftRatio: sideShiftRatio
        )
    }

    private static func candidate(
        anchor: CGPoint,
        calloutSize: CGSize,
        containerSize: CGSize,
        side: ChartAnchoredCalloutVerticalSide,
        padding: CGFloat,
        arrowInset: CGFloat,
        arrowOutset: CGFloat,
        sideShiftRatio: CGFloat
    ) -> ChartAnchoredCalloutLayoutResult {
        let halfWidth = calloutSize.width / 2
        let halfHeight = calloutSize.height / 2
        let maxArrowOffset = max(0, halfWidth - arrowInset)
        let boundedShiftRatio = min(max(sideShiftRatio, 0), 1)
        let sideShift = maxArrowOffset * boundedShiftRatio

        let preferredCenterX = anchor.x < containerSize.width / 2
            ? anchor.x + sideShift
            : anchor.x - sideShift
        let clampedCenterX = clamp(
            preferredCenterX,
            lower: padding + halfWidth,
            upper: max(padding + halfWidth, containerSize.width - padding - halfWidth)
        )

        let preferredCenterY: CGFloat
        switch side {
        case .above:
            preferredCenterY = anchor.y - halfHeight - arrowOutset
        case .below:
            preferredCenterY = anchor.y + halfHeight + arrowOutset
        }
        let clampedCenterY = clamp(
            preferredCenterY,
            lower: padding + halfHeight,
            upper: max(padding + halfHeight, containerSize.height - padding - halfHeight)
        )
        let clampedCenter = CGPoint(x: clampedCenterX, y: clampedCenterY)

        return ChartAnchoredCalloutLayoutResult(
            center: clampedCenter,
            anchor: anchor,
            side: side,
            arrowXOffset: clamp(
                anchor.x - clampedCenterX,
                lower: -maxArrowOffset,
                upper: maxArrowOffset
            ),
            wasClamped: clampedCenter != CGPoint(x: preferredCenterX, y: preferredCenterY)
        )
    }

    private static func clamp(_ value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        min(max(value, lower), upper)
    }
}
