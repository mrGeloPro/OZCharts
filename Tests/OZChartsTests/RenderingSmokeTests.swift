//
//  RenderingSmokeTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import XCTest
@testable import OZCharts

final class RenderingSmokeTests: XCTestCase {
    @MainActor
    func testLegendCanRenderToImage() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = ChartLegendView(
            items: [
                ChartLegendItem(title: "Current", color: .blue),
                ChartLegendItem(title: "Target", color: .orange, symbol: .circle)
            ]
        )
        .frame(width: 240, height: 44)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2

        XCTAssertNotNil(renderer.cgImage)
    }
}
