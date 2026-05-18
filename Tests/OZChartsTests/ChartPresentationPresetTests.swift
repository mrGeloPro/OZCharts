//
//  ChartPresentationPresetTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

@testable import OZCharts
import XCTest

final class ChartPresentationPresetTests: XCTestCase {
    func testSparklinePresetHidesAxesAndInteractions() {
        let preset = ChartPresentationPreset.sparkline()

        XCTAssertEqual(preset.interaction, .static)
        XCTAssertEqual(preset.selection, .disabled)
        XCTAssertEqual(preset.rendering.legendPosition, .hidden)
        XCTAssertEqual(preset.xAxes?.first?.height, 0)
        XCTAssertEqual(preset.yAxes?.first?.width, 0)
    }

    func testInteractiveExplorationPresetKeepsZoomAndNearestSelection() {
        let preset = ChartPresentationPreset.interactiveExploration()

        XCTAssertEqual(preset.interaction, .automatic)
        XCTAssertEqual(preset.selection.mode, .nearestX)
        XCTAssertEqual(preset.selection.behavior, .tapAndDrag)
        XCTAssertTrue(preset.viewport.showsZoomControls)
        XCTAssertEqual(preset.rendering.legendPosition, .bottom)
        XCTAssertNil(preset.xAxes)
        XCTAssertNil(preset.yAxes)
    }

    func testProductCardPresetKeepsScrollSafeSelectionAndHitPointTooltip() {
        let preset = ChartPresentationPreset.productCard(
            plotBorder: .visible(edges: [.top, .bottom])
        )

        XCTAssertEqual(preset.interaction, .automatic)
        XCTAssertEqual(preset.selection, .scrollSafeNearestX)
        XCTAssertEqual(preset.tooltip.anchor, .hitPoint)
        XCTAssertFalse(preset.viewport.showsZoomControls)
        XCTAssertEqual(preset.rendering.legendPosition, .bottom)
        XCTAssertEqual(preset.rendering.plotBorderStyle.edges, [.top, .bottom])
    }

    func testDenseEventTimelineKeepsAxisPlacementExplicit() {
        let preset = ChartPresentationPreset.denseEventTimeline(
            xPosition: .bottom,
            yPosition: .leading
        )

        XCTAssertTrue(preset.interaction.isHorizontalScrollEnabled)
        XCTAssertFalse(preset.interaction.isVerticalScrollEnabled)
        XCTAssertEqual(preset.tooltip.maxWidth, 240)
        XCTAssertEqual(preset.xAxes?.first?.position, .bottom)
        XCTAssertEqual(preset.yAxes?.first?.position, .leading)
    }
}
