//
//  ProductChartSnapshotTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import XCTest
@testable import OZCharts

final class ProductChartSnapshotTests: XCTestCase {
    private enum StarGroup: Hashable {
        case star1
        case star2
        case star3
        case remainder
    }

    @MainActor
    func testProductLineChartProducesStableImageSignatureShape() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let data = [
            Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, x: 1, y: 2),
            Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, x: 3, y: 4),
            Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, x: 5, y: 3),
            Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, x: 8, y: 5),
            Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, x: 12, y: 9),
            Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!, x: 15, y: 4)
        ]

        let view = CartesianChartView(
            series: [
                LineSeries(
                    data: data,
                    color: .purple,
                    lineWidth: 4,
                    interpolation: .monotone,
                    strokeStyle: .gradient([.purple, .pink], startPoint: .leading, endPoint: .trailing),
                    area: AreaStyle(fillStyle: .gradient([Color.purple.opacity(0.28), Color.purple.opacity(0.02)]), baseline: 0)
                )
            ],
            xDomain: .fixed(0...16),
            yDomain: .fixed(0...10),
            theme: .dark,
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .frame(width: 320, height: 220)

        let signature = try renderSignature(view)

        XCTAssertEqual(signature.width, 640)
        XCTAssertEqual(signature.height, 440)
        XCTAssertGreaterThan(signature.nonZeroByteCount, 10_000)
        XCTAssertNotEqual(signature.checksum, 0)
    }

    @MainActor
    func testProductDonutChartProducesStableImageSignatureShape() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let view = OZDonutChart(
            [
                Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!, x: 0, y: 85.2),
                Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!, x: 1, y: 11.3),
                Point2D(id: UUID(uuidString: "00000000-0000-0000-0000-000000000103")!, x: 2, y: 3.5)
            ],
            colors: [.cyan, .purple, .yellow],
            segmentStyles: [
                DonutSegmentStyle(fill: .gradient([.cyan, .blue.opacity(0.75)])),
                DonutSegmentStyle(fill: .gradient([.purple, .pink]), explodedOffset: 10),
                DonutSegmentStyle(fill: .gradient([.yellow, .orange]), explodedOffset: 12)
            ],
            segmentLabelMapper: { point in
                ["Basic", "Bonus", "Streak"][safe: Int(point.x)]
            },
            thickness: 38,
            gapAngle: .degrees(9),
            lineCap: .round,
            theme: .dark
        )
        .frame(width: 260, height: 220)

        let signature = try renderSignature(view)

        XCTAssertEqual(signature.width, 520)
        XCTAssertEqual(signature.height, 440)
        XCTAssertGreaterThan(signature.nonZeroByteCount, 20_000)
        XCTAssertNotEqual(signature.checksum, 0)
    }

    @MainActor
    func testProductStackedBarChartProducesStableImageSignatureShape() throws {
        guard #available(macOS 13.0, *) else {
            throw XCTSkip("ImageRenderer requires macOS 13 or newer.")
        }

        let rows: [GroupedPoint2D<StarGroup>] = [
            GroupedPoint2D(x: 10, y: 3, group: .star1),
            GroupedPoint2D(x: 25, y: 3, group: .star2),
            GroupedPoint2D(x: 36, y: 3, group: .star3),
            GroupedPoint2D(x: 14, y: 3, group: .remainder),
            GroupedPoint2D(x: 13, y: 2, group: .star1),
            GroupedPoint2D(x: 21, y: 2, group: .star2),
            GroupedPoint2D(x: 18, y: 2, group: .star3),
            GroupedPoint2D(x: 33, y: 2, group: .remainder),
            GroupedPoint2D(x: 11, y: 1, group: .star1),
            GroupedPoint2D(x: 17, y: 1, group: .star2),
            GroupedPoint2D(x: 13, y: 1, group: .star3),
            GroupedPoint2D(x: 44, y: 1, group: .remainder)
        ]

        let view = CartesianChartView(
            series: [
                StackedBarSeries(
                    data: rows,
                    stackOrder: [.star1, .star2, .star3, .remainder],
                    colorMapper: { group in
                        switch group {
                        case .star1: return .yellow
                        case .star2: return .orange
                        case .star3: return .orange.opacity(0.8)
                        case .remainder: return .gray
                        }
                    },
                    fillStyleMapper: { group in
                        group == .remainder
                            ? .stripes(foreground: .white.opacity(0.14), background: .gray.opacity(0.2))
                            : .color(.orange)
                    },
                    barHeight: 22,
                    cornerRadius: 4,
                    segmentGap: 1
                )
            ],
            xDomain: .fixed(0...100),
            yDomain: .fixed(0...4),
            theme: .dark,
            xAxes: [.init(position: .bottom, explicitValues: [0, 20, 40, 60, 80, 100])],
            yAxes: [.hidden()],
            isHorizontalScrollEnabled: false,
            isHorizontalZoomEnabled: false,
            isVerticalScrollEnabled: false,
            isVerticalZoomEnabled: false
        ) { _ in EmptyView() }
        .frame(width: 320, height: 220)

        let signature = try renderSignature(view)

        XCTAssertEqual(signature.width, 640)
        XCTAssertEqual(signature.height, 440)
        XCTAssertGreaterThan(signature.nonZeroByteCount, 16_000)
        XCTAssertNotEqual(signature.checksum, 0)
    }
}

private struct ImageSnapshotSignature {
    let width: Int
    let height: Int
    let nonZeroByteCount: Int
    let checksum: UInt64
}

@MainActor
@available(macOS 13.0, *)
private func renderSignature<Content: View>(_ view: Content) throws -> ImageSnapshotSignature {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 2
    guard let image = renderer.cgImage,
          let data = image.dataProvider?.data as Data? else {
        throw XCTSkip("Could not render chart image.")
    }

    var checksum: UInt64 = 14_695_981_039_346_656_037
    var nonZeroByteCount = 0
    for byte in data {
        if byte != 0 {
            nonZeroByteCount += 1
        }
        checksum = (checksum ^ UInt64(byte)) &* 1_099_511_628_211
    }

    return ImageSnapshotSignature(
        width: image.width,
        height: image.height,
        nonZeroByteCount: nonZeroByteCount,
        checksum: checksum
    )
}
