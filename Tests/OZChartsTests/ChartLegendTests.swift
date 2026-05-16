//
//  ChartLegendTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import XCTest
@testable import OZCharts

final class ChartLegendTests: XCTestCase {
    private enum Group: Hashable {
        case first
        case second
    }

    func testLineSeriesBuildsLineLegendItemWhenLabelExists() {
        let series = LineSeries(
            data: [Point2D(x: 1, y: 2)],
            color: .blue,
            label: "Revenue"
        )

        XCTAssertEqual(series.legendItem?.id, series.id)
        XCTAssertEqual(series.legendItem?.title, "Revenue")
        XCTAssertEqual(series.legendItem?.symbol, .line)
    }

    func testScatterSeriesBuildsCircleLegendItemWhenLabelExists() {
        let series = ScatterSeries(
            data: [Point2D(x: 1, y: 2)],
            color: .purple,
            label: "Samples"
        )

        XCTAssertEqual(series.legendItem?.title, "Samples")
        XCTAssertEqual(series.legendItem?.symbol, .circle)
    }

    func testDonutSeriesBuildsCircleLegendItemWhenLabelExists() {
        let series = DonutSeries(
            data: [Point2D(x: 1, y: 2)],
            colors: [.orange],
            label: "Share"
        )

        XCTAssertEqual(series.legendItem?.title, "Share")
        XCTAssertEqual(series.legendItem?.symbol, .circle)
    }

    func testStackedBarSeriesBuildsGroupLegendItems() {
        let series = StackedBarSeries<GroupedPoint2D<Group>>(
            data: [],
            stackOrder: [.first, .second],
            colorMapper: { _ in .blue },
            groupLabel: { group in
                group == .first ? "First" : "Second"
            }
        )

        XCTAssertEqual(series.legendItems.map(\.title), ["First", "Second"])
        XCTAssertTrue(series.legendItems.allSatisfy { $0.symbol == .square })
    }

    func testViolinSeriesBuildsGroupLegendItemsInDataOrder() {
        let series = ViolinSeries(
            data: [
                GroupedPoint2D(x: 0, y: 10, group: Group.second),
                GroupedPoint2D(x: 0, y: 12, group: Group.first)
            ],
            centerX: 0,
            sideMapper: { _ in .both },
            colorMapper: { _ in .blue },
            groupLabel: { group in
                group == .first ? "First" : "Second"
            }
        )

        XCTAssertEqual(series.legendItems.map(\.title), ["Second", "First"])
    }

    func testLegendOptionsLimitItemsAndAppendOverflowItem() {
        let items = [
            ChartLegendItem(title: "A", color: .red),
            ChartLegendItem(title: "B", color: .green),
            ChartLegendItem(title: "C", color: .blue)
        ]
        let options = ChartLegendOptions.compact(itemLimit: 2)

        let displayed = options.displayedItems(from: items)

        XCTAssertEqual(displayed.map(\.title), ["A", "B", "+1 more"])
        XCTAssertEqual(displayed.last?.symbol, .circle)
    }

    func testLegendOptionsKeepAllItemsWhenLimitIsNotExceeded() {
        let items = [
            ChartLegendItem(title: "A", color: .red),
            ChartLegendItem(title: "B", color: .green)
        ]
        let options = ChartLegendOptions.dashboard(itemLimit: 3)

        XCTAssertEqual(options.displayedItems(from: items).map(\.title), ["A", "B"])
    }

    func testLegendOptionsAllowCustomOverflowCopy() {
        let items = [
            ChartLegendItem(title: "A", color: .red),
            ChartLegendItem(title: "B", color: .green),
            ChartLegendItem(title: "C", color: .blue),
            ChartLegendItem(title: "D", color: .orange)
        ]
        let options = ChartLegendOptions(
            itemLimit: 1,
            overflowTitlePrefix: "and ",
            overflowTitleSuffix: " hidden"
        )

        XCTAssertEqual(options.displayedItems(from: items).map(\.title), ["A", "and 3 hidden"])
    }
}
