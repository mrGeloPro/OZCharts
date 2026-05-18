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
    var isVerticalScrollEnabled: Bool = true
    var isHorizontalZoomEnabled: Bool = true
    var isVerticalZoomEnabled: Bool = true
    var hitboxRadius: CGFloat = 20
    var selectionBehavior: ChartSelectionBehavior = .tap
    var selectionDismissalPolicy: ChartSelectionDismissalPolicy = .transient
    var selectionActivation: ChartSelectionActivation = .immediate

    func allowsPan(for translation: CGSize) -> Bool {
        let horizontalDistance = abs(translation.width)
        let verticalDistance = abs(translation.height)

        switch (isHorizontalScrollEnabled, isVerticalScrollEnabled) {
        case (true, true):
            return true
        case (true, false):
            return horizontalDistance >= verticalDistance
        case (false, true):
            return verticalDistance >= horizontalDistance
        case (false, false):
            return false
        }
    }
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
                if isMoving && config.allowsPan(for: value.translation) {
                    onEvent(.panChanged(translation: value.translation))
                } else if isMoving && config.selectionBehavior.allowsDragSelection {
                    onEvent(.highlight(location: value.location))
                } else if !isMoving,
                          config.selectionActivation == .immediate,
                          config.selectionBehavior.allowsTapSelection {
                    onEvent(.highlight(location: value.location))
                }
            }
            .onEnded { value in
                let isMoving = abs(value.translation.width) > 5 || abs(value.translation.height) > 5
                if !isZooming,
                   !isMoving,
                   config.selectionActivation == .onTapEnd,
                   config.selectionBehavior.allowsTapSelection {
                    onEvent(.highlight(location: value.location))
                }
                if !isZooming {
                    onEvent(.panEnded)
                }
                if config.selectionBehavior != .disabled,
                   config.selectionDismissalPolicy.contains(.gestureEnd),
                   config.selectionActivation == .immediate {
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
