//
//  ChartLayoutEngineTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
import XCTest
@testable import OZCharts

final class ChartLayoutEngineTests: XCTestCase {
    func testInsetsUseAxisDimensions() {
        let layout = ChartLayoutEngine.layout(
            in: CGSize(width: 320, height: 240),
            xAxes: [
                XAxisConfig(position: .top, height: 24),
                XAxisConfig(position: .bottom, height: 32)
            ],
            yAxes: [
                YAxisConfig(position: .leading, width: 40),
                YAxisConfig(position: .trailing, width: 52)
            ]
        )

        XCTAssertEqual(layout.insets.top, 24)
        XCTAssertEqual(layout.insets.bottom, 32)
        XCTAssertEqual(layout.insets.leading, 40)
        XCTAssertEqual(layout.insets.trailing, 52)
        XCTAssertEqual(layout.plotArea, CGRect(x: 40, y: 24, width: 228, height: 184))
    }

    func testPlotAreaNeverBecomesNegative() {
        let plotArea = ChartLayoutEngine.plotArea(
            in: CGSize(width: 80, height: 60),
            insets: ChartInsets(top: 40, leading: 30, bottom: 40, trailing: 80)
        )

        XCTAssertEqual(plotArea.origin.x, 30)
        XCTAssertEqual(plotArea.origin.y, 40)
        XCTAssertEqual(plotArea.size.width, 0)
        XCTAssertEqual(plotArea.size.height, 0)
    }
}
