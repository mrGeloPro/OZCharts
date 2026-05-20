//
//  ChartAxisMarkerOverlay.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct ChartAxisMarkerOverlay<XScale: Scale, YScale: Scale>: View
where XScale.InputType == Double, XScale.OutputType == CGFloat,
    YScale.InputType == Double, YScale.OutputType == CGFloat {
    let markers: [ChartAxisMarker]
    let xScale: XScale
    let yScale: YScale
    let plotOrigin: CGPoint
    let plotSize: CGSize
    @Binding var markerSizes: [UUID: CGSize]
    @Binding var compactMarkerSizes: [UUID: CGSize]
    let selectionOptions: ChartAxisMarkerSelectionOptions
    let selectedIDs: Set<UUID>
    let onMarkerTap: (ChartAxisMarkerContext, [ChartAxisMarkerContext]) -> Void

    var body: some View {
        GeometryReader { geometry in
            let results = resolvedResults(in: geometry.size)
            let contexts = contexts(for: results)
            let visibleResults = results
                .filter(\.isVisible)
                .sorted { first, second in
                    let firstIsSelected = selectedIDs.contains(first.id)
                    let secondIsSelected = selectedIDs.contains(second.id)
                    if firstIsSelected != secondIsSelected {
                        return !firstIsSelected && secondIsSelected
                    }
                    return first.originalIndex < second.originalIndex
                }

            ZStack(alignment: .topLeading) {
                measurementLayer
                    .allowsHitTesting(false)

                ForEach(visibleResults, id: \.id) { result in
                    if let marker = marker(for: result.id) {
                        markerView(for: marker, compact: result.usesCompactContent)
                            .position(result.position)
                            .onTapGesture {
                                if let context = contexts.first(where: { $0.id == marker.id }) {
                                    onMarkerTap(context, contexts)
                                }
                            }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var measurementLayer: some View {
        ForEach(markers) { marker in
            ZStack {
                marker.content
                    .fixedSize()
                    .hidden()
                    .readSize { markerSizes[marker.id] = $0 }

                if let compactContent = marker.compactContent {
                    compactContent
                        .fixedSize()
                        .hidden()
                        .readSize { compactMarkerSizes[marker.id] = $0 }
                }
            }
        }
    }

    @ViewBuilder
    private func markerView(for marker: ChartAxisMarker, compact: Bool) -> some View {
        let content = compact ? marker.compactContent ?? marker.content : marker.content

        if let label = marker.accessibilityLabel {
            content
                .fixedSize()
                .accessibilityLabel(Text(label))
                .contentShape(Rectangle())
        } else {
            content
                .fixedSize()
                .contentShape(Rectangle())
        }
    }

    private func resolvedResults(in chartSize: CGSize) -> [ChartAxisMarkerLayoutResult] {
        let bounds = CGRect(origin: .zero, size: chartSize)
        let candidates = markers.enumerated().compactMap { index, marker in
            candidate(for: marker, index: index)
        }

        return ChartAxisMarkerCollisionResolver.resolve(candidates, bounds: bounds)
    }

    private func contexts(
        for results: [ChartAxisMarkerLayoutResult]
    ) -> [ChartAxisMarkerContext] {
        results.compactMap { result in
            guard result.isVisible,
                  let marker = marker(for: result.id)
            else { return nil }

            return ChartAxisMarkerContext(
                marker: marker,
                anchor: result.anchor,
                position: result.position,
                frame: result.frame,
                usesCompactContent: result.usesCompactContent
            )
        }
    }

    private func candidate(
        for marker: ChartAxisMarker,
        index: Int
    ) -> ChartAxisMarkerLayoutCandidate? {
        guard let anchor = anchor(for: marker) else { return nil }

        let position = CGPoint(
            x: anchor.x + marker.offset.width,
            y: anchor.y + marker.offset.height
        )

        guard position.x.isFinite, position.y.isFinite else { return nil }

        return ChartAxisMarkerLayoutCandidate(
            id: marker.id,
            axis: marker.axis,
            placement: marker.placement,
            anchor: anchor,
            position: position,
            size: markerSizes[marker.id] ?? .zero,
            compactSize: compactMarkerSizes[marker.id],
            priority: marker.priority,
            collisionStrategy: marker.collisionStrategy,
            originalIndex: index
        )
    }

    private func marker(for id: UUID) -> ChartAxisMarker? {
        markers.first { $0.id == id }
    }

    private func anchor(for marker: ChartAxisMarker) -> CGPoint? {
        guard plotSize.width > 0, plotSize.height > 0 else { return nil }

        switch marker.axis {
        case .x:
            let x = xScale.scale(marker.value)
            guard x >= 0, x <= plotSize.width else { return nil }
            return CGPoint(
                x: plotOrigin.x + x,
                y: xMarkerY(for: marker.placement)
            )

        case .y:
            let y = plotSize.height - yScale.scale(marker.value)
            guard y >= 0, y <= plotSize.height else { return nil }
            return CGPoint(
                x: yMarkerX(for: marker.placement),
                y: plotOrigin.y + y
            )
        }
    }

    private func xMarkerY(for placement: ChartAxisMarkerPlacement) -> CGFloat {
        switch placement {
        case .top, .leading:
            return plotOrigin.y
        case .bottom, .trailing:
            return plotOrigin.y + plotSize.height
        }
    }

    private func yMarkerX(for placement: ChartAxisMarkerPlacement) -> CGFloat {
        switch placement {
        case .leading, .top:
            return plotOrigin.x
        case .trailing, .bottom:
            return plotOrigin.x + plotSize.width
        }
    }
}
