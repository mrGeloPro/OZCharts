//
//  ChartStore+Selection.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

extension ChartStore {
    public var selectionState: ChartSelectionState {
        ChartSelectionState(
            selectedX: highlightedPoints.first?.originalPoint.x,
            selectedPoints: selectedPointPayloads(for: highlightedPoints),
            selectedElements: selectedElements
        )
    }

    func selectElements(
        near location: CGPoint,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .cycle
    ) -> [ChartSelectedElement] {
        selectElementContexts(
            near: location,
            overlappingSelectionMode: overlappingSelectionMode
        ).map(\.payload)
    }

    func selectElementContexts(
        near location: CGPoint,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .cycle
    ) -> [ChartElementContext] {
        ChartHitTestResolver.elementContexts(
            near: location,
            contexts: selectableElements,
            overlappingSelectionMode: overlappingSelectionMode,
            cycleIDs: &selectionCycleIDs,
            cycleIndex: &selectionCycleIndex
        )
    }

    func selectPoints(
        near location: CGPoint,
        radius: CGFloat,
        mode: ChartSelectionMode,
        overlappingSelectionMode: ChartOverlappingSelectionMode = .all,
        nearestSelectionPolicy: ChartNearestSelectionPolicy = .unbounded
    ) -> [ChartPointContext<Point>] {
        ChartHitTestResolver.points(
            near: location,
            index: currentPointInteractionIndex(preferredHitRadius: radius),
            radius: radius,
            mode: mode,
            overlappingSelectionMode: overlappingSelectionMode,
            nearestSelectionPolicy: nearestSelectionPolicy,
            cycleIDs: &selectionCycleIDs,
            cycleIndex: &selectionCycleIndex
        )
    }

    func selectNearestXValue(_ xValue: Double) -> [ChartPointContext<Point>] {
        guard xValue.isFinite else { return [] }
        return currentPointInteractionIndex().nearestOriginalXValue(xValue)
    }

    func selectPoints(byIDs pointIDs: [UUID]) -> [ChartPointContext<Point>] {
        guard !pointIDs.isEmpty else { return [] }
        return currentPointInteractionIndex().points(byIDs: pointIDs)
    }

    func selectElements(byIDs elementIDs: [UUID]) -> [ChartSelectedElement] {
        guard !elementIDs.isEmpty else { return [] }

        let selectedIDs = Set(elementIDs)
        return selectableElements
            .map(\.payload)
            .filter { selectedIDs.contains($0.elementID) }
    }

    func selectElementContexts(byIDs elementIDs: [UUID]) -> [ChartElementContext] {
        guard !elementIDs.isEmpty else { return [] }

        let selectedIDs = Set(elementIDs)
        return selectableElements
            .filter { selectedIDs.contains($0.payload.elementID) }
    }

    public func applySelectionState(_ state: ChartSelectionState) {
        if !state.selectedElements.isEmpty {
            let selectedContextsByID = selectElementContexts(byIDs: state.selectedElements.map(\.elementID))
            selectedElementContexts = selectedContextsByID
            selectedElements = selectedContextsByID.map(\.payload)
            highlightedPoints = []
            resetSelectionCycle()
            return
        }

        if !state.selectedPoints.isEmpty {
            let selectedByID = selectPoints(byIDs: state.selectedPoints.map(\.pointID))
            if !selectedByID.isEmpty || state.selectedX == nil {
                highlightedPoints = selectedByID
                selectedElements = []
                selectedElementContexts = []
                resetSelectionCycle()
                return
            }
            highlightedPoints = selectNearestXValue(state.selectedX ?? 0)
            selectedElements = []
            selectedElementContexts = []
            resetSelectionCycle()
            return
        }

        guard let selectedX = state.selectedX else {
            highlightedPoints = []
            selectedElements = []
            selectedElementContexts = []
            resetSelectionCycle()
            return
        }

        highlightedPoints = selectNearestXValue(selectedX)
        selectedElements = []
        selectedElementContexts = []
        resetSelectionCycle()
    }

    func resetSelectionCycle() {
        selectionCycleIDs = []
        selectionCycleIndex = 0
    }

    func clearSelectionForDragIfNeeded(_ policy: ChartSelectionDismissalPolicy) {
        guard policy.contains(.drag) || policy.contains(.viewportChange) else { return }
        clearSelection()
    }

    func clearSelectionForViewportChangeIfNeeded(_ policy: ChartSelectionDismissalPolicy) {
        guard policy.contains(.viewportChange) else { return }
        clearSelection()
    }

    func clearSelection() {
        highlightedPoints = []
        selectedElements = []
        selectedElementContexts = []
        resetSelectionCycle()
    }

    func selectedPointPayloads(
        for points: [ChartPointContext<Point>]
    ) -> [ChartSelectedPoint] {
        points.map { context in
            let seriesIndex = seriesContexts.firstIndex { contexts in
                contexts.contains { $0.originalPoint.id == context.originalPoint.id }
            }

            return ChartSelectedPoint(
                pointID: context.originalPoint.id,
                seriesID: seriesIndex.flatMap { currentSeriesIDs[safe: $0] },
                seriesIndex: seriesIndex,
                x: context.originalPoint.x,
                y: context.originalPoint.y
            )
        }
    }
}
