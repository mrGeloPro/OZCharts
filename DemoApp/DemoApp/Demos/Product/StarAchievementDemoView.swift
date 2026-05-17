//
//  StarAchievementDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

// MARK: - Stacked Bar Demo

enum StarType: Hashable { case s1, s2, s3, remainder }

struct StarAchievementDemoView: View {
    /// y=0 Current, y=1 Last, y=2 Average, y=3 High score.
    let mockData: [GroupedPoint2D<StarType>] = [
        // Current
        GroupedPoint2D(x: 12, y: 0, group: .s1),
        GroupedPoint2D(x: 20, y: 0, group: .s2),
        GroupedPoint2D(x: 23, y: 0, group: .s3),
        // Last
        GroupedPoint2D(x: 10, y: 1, group: .s1),
        GroupedPoint2D(x: 18, y: 1, group: .s2),
        GroupedPoint2D(x: 14, y: 1, group: .s3),
        // Average
        GroupedPoint2D(x: 13, y: 2, group: .s1),
        GroupedPoint2D(x: 22, y: 2, group: .s2),
        GroupedPoint2D(x: 18, y: 2, group: .s3),
        // High score
        GroupedPoint2D(x: 10, y: 3, group: .s1),
        GroupedPoint2D(x: 20, y: 3, group: .s2),
        GroupedPoint2D(x: 40, y: 3, group: .s3)
    ]

    let yLabels: [Int: String] = [0: "Current", 1: "Last", 2: "Average", 3: "High score"]
    let totals:  [Int: Double] = [0: 5.50, 1: 4.20, 2: 5.10, 3: 4.40]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    OZChart(mockData)
                        .axes(
                            x: [
                                XAxisConfig(
                                    position: .bottom,
                                    showGrid: false,
                                    explicitValues: stride(from: 0.0, through: 90.0, by: 10.0).map { $0 },
                                    labelFormatter: { "\(Int($0))" },
                                    showAxisLine: true
                                )
                            ]
                        )
                        .stackedBar(
                            id: DemoSeriesID.starAchievement,
                            stackOrder: [.s1, .s2, .s3],
                            colorMapper: { star in
                                switch star {
                                case .s1: return .yellow
                                case .s2: return Color(red: 1.00, green: 0.72, blue: 0.00)
                                case .s3: return DemoColors.orange
                                case .remainder: return DemoColors.surface
                                }
                            },
                            fillStyleMapper: { star in
                                switch star {
                                case .s1: return .gradient([.yellow, Color.yellow.opacity(0.86)], startPoint: .leading, endPoint: .trailing)
                                case .s2: return .gradient([Color.yellow.opacity(0.92), DemoColors.orange], startPoint: .leading, endPoint: .trailing)
                                case .s3: return .gradient([DemoColors.orange, Color.orange], startPoint: .leading, endPoint: .trailing)
                                case .remainder:
                                    return .stripes(
                                        foreground: Color.white.opacity(0.12),
                                        background: DemoColors.surface.opacity(0.70),
                                        lineWidth: 3,
                                        spacing: 9
                                    )
                                }
                            },
                            groupLabel: { star in starTitle(for: star) },
                            rowLabel: { [yLabels] row in yLabels[Int(row.rounded())] },
                            rowEndLabel: { [totals] row, _ in
                                totals[Int(row.rounded())].map { String(format: "%.2f", $0) }
                            },
                            layout: .achievement(
                                leftAxisWidth: 78,
                                rightAxisWidth: 58,
                                axisLabelSpacing: 8,
                                rowLabelLineLimit: 2,
                                barHeight: 26,
                                segmentGap: 2,
                                rowHitboxHeight: 44
                            ),
                            remainder: .target(
                                { row in Int(row.rounded()) == 0 ? nil : 85 },
                                signature: "star-achievement-targets",
                                fillStyle: .stripes(
                                    foreground: Color.white.opacity(0.12),
                                    background: DemoColors.surface.opacity(0.70),
                                    lineWidth: 3,
                                    spacing: 9
                                ),
                                accessibilityLabel: "Remaining"
                            ),
                            separatorStyle: StackedBarSeparatorStyle(
                                color: DemoColors.background,
                                width: 2
                            ),
                            interactionOptions: .segments
                        )
                        .domain(x: .fixed(0...100), y: .fixed(-0.8...3.8))
                        .interaction(.static)
                        .selection(ChartSelectionOptions(
                            mode: .none,
                            behavior: .tapAndDrag,
                            overlappingSelectionMode: .cycle,
                            hitboxRadius: 24,
                            dismissalPolicy: .persistent
                        ))
                        .tooltipOptions(
                            .hitPoint(
                                placement: .automatic,
                                offset: CGPoint(x: 0, y: -18),
                                padding: 8,
                                maxWidth: 220
                            )
                        )
                        .elementTooltipContext { context in
                            if let selection = context.elements.compactMap(StackedBarSelection.init(element:)).first,
                               let rowValue = selection.rowValue {
                                let row = Int(rowValue.rounded())
                                ChartCallout(context: context, style: .productLight) {
                                    StarAchievementTooltip(
                                        rowTitle: yLabels[row] ?? "Result",
                                        lines: selectedStarLines(for: row)
                                    )
                                }
                            }
                        }
                        .frame(height: 340)

                    DemoLegend(items: [
                        ("Star 1", .yellow),
                        ("Star 2", Color(red: 1.00, green: 0.72, blue: 0.00)),
                        ("Star 3", DemoColors.orange)
                    ])
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Star Achievement")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func selectedStarLines(for row: Int) -> [String] {
        let segments = visibleSegments(for: row, includingRemainder: false)
        var cumulative = 0.0

        return segments.enumerated().map { index, item in
            cumulative += item.value
            let title = starTitle(for: item.group)
            let minutesValue = index == 0 ? item.value / 10 : cumulative / 10
            let suffix = index == 0 ? "" : " (total)"
            return "\(title): \(String(format: "%.2f", minutesValue))min\(suffix)"
        }
    }

    private func visibleSegments(for row: Int, includingRemainder: Bool) -> [(group: StarType, value: Double)] {
        mockData
            .filter { Int($0.y.rounded()) == row && (includingRemainder || $0.group != .remainder) }
            .sorted { lhs, rhs in
                starOrder(lhs.group) < starOrder(rhs.group)
            }
            .map { ($0.group, $0.x) }
    }

    private func starTitle(for star: StarType) -> String {
        switch star {
        case .s1: return "Star 1"
        case .s2: return "Star 2"
        case .s3: return "Star 3"
        case .remainder: return ""
        }
    }

    private func starOrder(_ star: StarType) -> Int {
        switch star {
        case .s1: return 0
        case .s2: return 1
        case .s3: return 2
        case .remainder: return 3
        }
    }
}

private struct StarAchievementTooltip: View {
    let rowTitle: String
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(rowTitle)
                .font(.caption2.weight(.bold))
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.caption2.weight(.semibold))
            }
        }
        .frame(width: 156, alignment: .leading)
    }
}
