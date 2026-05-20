//
//  ChartTooltipOverlays.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct ChartAnnotationTooltipOverlay: View {
    let annotations: [ChartAnnotationContext]
    let canvasSize: CGSize
    let placement: ChartTooltipPlacement
    let anchorOverride: CGPoint?
    let offset: CGPoint
    let padding: CGFloat
    let maxWidth: CGFloat?
    let content: (([ChartAnnotationContext]) -> AnyView)?
    let onDiagnosticsChanged: ([ChartDiagnostic]) -> Void

    @State private var tooltipSize: CGSize = .zero

    var body: some View {
        if let anchor = anchorOverride ?? ChartTooltipLayout.anchor(for: annotations.map(\.position)) {
            let layoutSize = measuredTooltipSize
            let layout = ChartTooltipLayout.resolve(
                anchor: anchor,
                tooltipSize: layoutSize,
                canvasSize: canvasSize,
                placement: placement,
                offset: offset,
                padding: padding
            )
            resolvedContent
                .frame(maxWidth: resolvedMaxWidth, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .readSize { tooltipSize = $0 }
                .position(layout.position)
                .onAppear { publishTooltipDiagnostic(for: layout) }
                .onChange(of: layout.wasClamped) { _ in publishTooltipDiagnostic(for: layout) }
        }
    }

    private var measuredTooltipSize: CGSize {
        guard tooltipSize.width > 0, tooltipSize.height > 0 else {
            return CGSize(width: resolvedMaxWidth ?? 180, height: 72)
        }
        return tooltipSize
    }

    private var resolvedMaxWidth: CGFloat? {
        ChartTooltipLayout.resolvedMaxWidth(
            configuredMaxWidth: maxWidth,
            canvasWidth: canvasSize.width,
            padding: padding
        )
    }

    private var resolvedContent: some View {
        Group {
            if let content {
                content(annotations)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(annotations) { annotation in
                        Text(annotation.label ?? "\(annotation.x), \(annotation.y)")
                    }
                }
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.78))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }

    private func publishTooltipDiagnostic(for layout: ChartTooltipLayoutResult) {
        onDiagnosticsChanged(
            layout.wasClamped
                ? [ChartDiagnostics.tooltipClamped(anchor: layout.anchor, position: layout.position)]
                : []
        )
    }
}

struct ChartElementTooltipOverlay: View {
    let elements: [ChartSelectedElement]
    let canvasSize: CGSize
    let placement: ChartTooltipPlacement
    let anchorOverride: CGPoint?
    let offset: CGPoint
    let padding: CGFloat
    let maxWidth: CGFloat?
    let overflowAllowance: ChartTooltipOverflowAllowance
    let content: ((ChartElementTooltipContext) -> AnyView)?
    let onDiagnosticsChanged: ([ChartDiagnostic]) -> Void

    @State private var tooltipSize: CGSize = .zero

    var body: some View {
        if let anchor = resolvedAnchor {
            let layoutSize = measuredTooltipSize
            let layout = ChartTooltipLayout.resolve(
                anchor: anchor,
                tooltipSize: layoutSize,
                canvasSize: canvasSize,
                placement: placement,
                offset: offset,
                padding: padding,
                directionalOverflowAllowance: overflowAllowance
            )
            resolvedContent
                .frame(maxWidth: resolvedMaxWidth, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .readSize { tooltipSize = $0 }
                .position(layout.position)
                .onAppear { publishTooltipDiagnostic(for: layout) }
                .onChange(of: layout.wasClamped) { _ in publishTooltipDiagnostic(for: layout) }
        }
    }

    private var resolvedAnchor: CGPoint? {
        anchorOverride ?? ChartTooltipLayout.anchor(for: elements.map(\.tooltipInteractionAnchor))
    }

    private var measuredTooltipSize: CGSize {
        guard tooltipSize.width > 0, tooltipSize.height > 0 else {
            return CGSize(width: resolvedMaxWidth ?? 180, height: 72)
        }
        return tooltipSize
    }

    private var resolvedMaxWidth: CGFloat? {
        ChartTooltipLayout.resolvedMaxWidth(
            configuredMaxWidth: maxWidth,
            canvasWidth: canvasSize.width,
            padding: padding
        )
    }

    private var resolvedContent: some View {
        Group {
            if let content {
                content(currentContext)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(elements) { element in
                        Text(element.label ?? element.groupLabel ?? formattedValue(element.value))
                    }
                }
                .font(.caption)
                .padding(8)
                .background(Color.black.opacity(0.78))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }

    private var currentContext: ChartElementTooltipContext {
        let anchor = anchorOverride ?? ChartTooltipLayout.anchor(for: elements.map(\.tooltipInteractionAnchor)) ?? .zero
        let layout = ChartTooltipLayout.resolve(
            anchor: anchor,
            tooltipSize: measuredTooltipSize,
            canvasSize: canvasSize,
            placement: placement,
            offset: offset,
            padding: padding,
            directionalOverflowAllowance: overflowAllowance
        )
        return ChartElementTooltipContext(
            elements: elements,
            anchor: layout.anchor,
            position: layout.position,
            arrowEdge: arrowEdge(for: layout.attachment),
            arrowXOffset: layout.anchor.x - layout.position.x,
            arrowYOffset: layout.anchor.y - layout.position.y,
            wasClamped: layout.wasClamped
        )
    }

    private func publishTooltipDiagnostic(for layout: ChartTooltipLayoutResult) {
        onDiagnosticsChanged(
            layout.wasClamped
                ? [ChartDiagnostics.tooltipClamped(anchor: layout.anchor, position: layout.position)]
                : []
        )
    }

    private func arrowEdge(for attachment: ChartTooltipAttachment) -> ChartTooltipArrowEdge {
        switch attachment {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        case .center, .fixed:
            return .none
        }
    }

    private func formattedValue(_ value: Double?) -> String {
        guard let value else { return "Selected" }
        return String(format: "%.2f", value)
    }
}
