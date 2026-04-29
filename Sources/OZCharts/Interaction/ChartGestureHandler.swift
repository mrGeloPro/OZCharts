//
//  ChartGestureHandler.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public struct ChartGestureConfig {
    var isHorizontalScrollEnabled: Bool = true
    var isVerticalScrollEnabled:   Bool = true
    var isHorizontalZoomEnabled:   Bool = true
    var isVerticalZoomEnabled:     Bool = true
    var hitboxRadius:              CGFloat = 20
    var selectionBehavior:         ChartSelectionBehavior = .tap
    var clearsSelectionOnGestureEnd: Bool = true
}

public enum ChartGestureEvent {
    case panChanged(translation: CGSize)
    case panEnded
    case zoomChanged(magnification: CGFloat)
    case zoomEnded
    case highlight(location: CGPoint)
    case highlightCleared
}

public struct ChartGestureHandler: View {
    let config: ChartGestureConfig
    let onEvent: (ChartGestureEvent) -> Void
    @State private var isZooming = false

    public var body: some View {
        Color.clear
            .contentShape(.rect)
            .gesture(panAndHighlightGesture.simultaneously(with: zoomGesture))
    }

    private var panAndHighlightGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !isZooming else { return }

                let isMoving = abs(value.translation.width) > 5 || abs(value.translation.height) > 5
                if isMoving && (config.isHorizontalScrollEnabled || config.isVerticalScrollEnabled) {
                    onEvent(.panChanged(translation: value.translation))
                } else if isMoving && config.selectionBehavior.allowsDragSelection {
                    onEvent(.highlight(location: value.location))
                } else if !isMoving && config.selectionBehavior.allowsTapSelection {
                    onEvent(.highlight(location: value.location))
                }
            }
            .onEnded { _ in
                if !isZooming {
                    onEvent(.panEnded)
                }
                if config.selectionBehavior != .disabled, config.clearsSelectionOnGestureEnd {
                    onEvent(.highlightCleared)
                }
            }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard config.isHorizontalZoomEnabled || config.isVerticalZoomEnabled else { return }
                isZooming = true
                onEvent(.zoomChanged(magnification: value))
            }
            .onEnded { _ in
                isZooming = false
                onEvent(.zoomEnded)
            }
    }
}
