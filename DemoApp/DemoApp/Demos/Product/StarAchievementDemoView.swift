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
    @State private var selectedElement: ChartSelectedElement?

    private let tooltipContentWidth: CGFloat = 156
    private let tooltipHorizontalPadding: CGFloat = 10
    private let tooltipCanvasPadding: CGFloat = 6
    private let tooltipArrowInset: CGFloat = 16
    private let tooltipEstimatedHeight: CGFloat = 92
    private let tooltipArrowOutset: CGFloat = 7
    private let tooltipPreferredSideShiftRatio: CGFloat = 0.95

    /// y=0 Current, y=1 Last, y=2 Average, y=3 High score.
    let mockData: [GroupedPoint2D<StarType>] = [
        // Current
        GroupedPoint2D(x: 12, y: 0, group: .s1),
        GroupedPoint2D(x: 20, y: 0, group: .s2),
        GroupedPoint2D(x: 23, y: 0, group: .s3),
        GroupedPoint2D(x: 0, y: 0, group: .remainder),
        // Last
        GroupedPoint2D(x: 10, y: 1, group: .s1),
        GroupedPoint2D(x: 18, y: 1, group: .s2),
        GroupedPoint2D(x: 14, y: 1, group: .s3),
        GroupedPoint2D(x: 43, y: 1, group: .remainder),
        // Average
        GroupedPoint2D(x: 13, y: 2, group: .s1),
        GroupedPoint2D(x: 22, y: 2, group: .s2),
        GroupedPoint2D(x: 18, y: 2, group: .s3),
        GroupedPoint2D(x: 32, y: 2, group: .remainder),
        // High score
        GroupedPoint2D(x: 10, y: 3, group: .s1),
        GroupedPoint2D(x: 20, y: 3, group: .s2),
        GroupedPoint2D(x: 40, y: 3, group: .s3),
        GroupedPoint2D(x: 16, y: 3, group: .remainder)
    ]

    let yLabels: [Int: String] = [0: "Current", 1: "Last", 2: "Average", 3: "High score"]
    let totals:  [Int: Double] = [0: 5.50, 1: 4.20, 2: 5.10, 3: 4.40]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    OZChart(mockData)
                        .stackedBar(
                            id: DemoSeriesID.starAchievement,
                            stackOrder: [.s1, .s2, .s3, .remainder],
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
                            barHeight: 26,
                            cornerRadius: 3,
                            segmentGap: 2
                        )
                        .domain(x: .fixed(0...100), y: .fixed(-0.8...3.8))
                        .axes(
                            x: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: false,
                                explicitValues: stride(from: 0.0, through: 90.0, by: 10.0).map { $0 },
                                labelFormatter: { "\(Int($0))" },
                                showAxisLine: true
                            )
                            ],
                            y: [
                            YAxisConfig(
                                position: .leading,
                                showGrid: false,
                                explicitValues: [0, 1, 2, 3],
                                tickCount: 4,
                                labelFormatter: { [yLabels] v in yLabels[Int(v.rounded())] ?? "" },
                                width: 78,
                                showAxisLine: true,
                                customLabelBuilder: { [yLabels] value in
                                    let index = Int(value.rounded())
                                    let title = yLabels[index] ?? ""
                                    let display = index == 3 ? "High\nscore" : title
                                    return AnyView(
                                        Text(display)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: true, vertical: true)
                                    )
                                }
                            )
                            ]
                        )
                        .annotations(customViews: starAnnotations)
                        .interaction(.static)
                        .selection(ChartSelectionOptions(
                            mode: .none,
                            behavior: .tapAndDrag,
                            overlappingSelectionMode: .cycle,
                            hitboxRadius: 24,
                            clearsSelectionOnGestureEnd: false
                        ))
                        .onElementSelectionChanged { elements in
                            selectedElement = elements.first
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

    private var starAnnotations: [CustomViewAnnotation<Double, Double>] {
        var annotations = scoreLabels
        if let tooltipAnnotation {
            annotations.append(tooltipAnnotation)
        }
        return annotations
    }

    private var scoreLabels: [CustomViewAnnotation<Double, Double>] {
        totals.map { row, score in
            CustomViewAnnotation(id: DemoAnnotationID.starScore(row: row), x: 94, y: Double(row)) {
                Text(String(format: "%.2f", score))
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .fixedSize()
            }
        }
    }

    private var tooltipAnnotation: CustomViewAnnotation<Double, Double>? {
        guard
            let selectedElement,
            let rowValue = selectedElement.y,
            let pointID = selectedElement.pointID,
            let selectedPoint = mockData.first(where: { $0.id == pointID })
        else { return nil }

        let row = Int(rowValue.rounded())
        let placement = tooltipPlacement(for: row)
        let geometry = tooltipGeometry(
            for: selectedElement,
            targetX: segmentCenterX(row: row, group: selectedPoint.group),
            placement: placement
        )
        return CustomViewAnnotation(
            id: DemoAnnotationID.starTooltip,
            x: geometry.centerX,
            y: Double(row),
            placement: .fixed(geometry.center),
            collisionPriority: 100,
            avoidsCollisions: false,
            padding: 6
        ) {
            StarAchievementTooltip(
                rowTitle: yLabels[row] ?? "Result",
                lines: selectedStarLines(for: row),
                arrowEdge: placement.arrowEdge,
                arrowXOffset: geometry.arrowXOffset
            )
        }
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

    private func tooltipPlacement(for row: Int) -> StarTooltipPlacement {
        switch row {
        case 0, 1: return .above
        default: return .below
        }
    }

    private func segmentCenterX(row: Int, group selectedGroup: StarType) -> Double {
        var cursor = 0.0
        for segment in visibleSegments(for: row, includingRemainder: true) {
            let center = cursor + segment.value / 2
            if segment.group == selectedGroup {
                return center
            }
            cursor += segment.value
        }
        return 50
    }

    private func tooltipGeometry(
        for element: ChartSelectedElement,
        targetX: Double,
        placement: StarTooltipPlacement
    ) -> StarTooltipGeometry {
        guard
            let value = element.value,
            value > 0,
            element.bounds.width > 0
        else {
            return StarTooltipGeometry(centerX: targetX, center: element.position, arrowXOffset: 0)
        }

        let pointsPerDomainUnit = element.bounds.width / CGFloat(value)
        let canvasWidth = max(pointsPerDomainUnit * 100, 1)
        let halfTooltipWidth = (tooltipContentWidth + tooltipHorizontalPadding * 2) / 2
        let minCenterX = tooltipCanvasPadding + halfTooltipWidth
        let maxCenterX = max(minCenterX, canvasWidth - tooltipCanvasPadding - halfTooltipWidth)
        let anchor = element.interactionPosition ?? element.position
        let layout = ChartAnchoredCalloutLayout.vertical(
            anchor: anchor,
            calloutSize: CGSize(
                width: tooltipContentWidth + tooltipHorizontalPadding * 2,
                height: tooltipEstimatedHeight
            ),
            containerSize: CGSize(width: canvasWidth, height: .greatestFiniteMagnitude),
            preferredSide: placement.calloutSide,
            padding: tooltipCanvasPadding,
            arrowInset: tooltipArrowInset,
            arrowOutset: tooltipArrowOutset,
            sideShiftRatio: tooltipPreferredSideShiftRatio
        )
        let centerPixelX = min(max(layout.center.x, minCenterX), maxCenterX)
        let centerX = Double(centerPixelX / canvasWidth * 100)
        return StarTooltipGeometry(
            centerX: centerX,
            center: CGPoint(x: centerPixelX, y: layout.center.y),
            arrowXOffset: layout.arrowXOffset
        )
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

private struct StarTooltipGeometry {
    let centerX: Double
    let center: CGPoint
    let arrowXOffset: CGFloat
}

private enum StarTooltipPlacement: Equatable {
    case above
    case below

    var calloutSide: ChartAnchoredCalloutVerticalSide {
        switch self {
        case .above: return .above
        case .below: return .below
        }
    }

    var arrowEdge: StarTooltipArrowEdge {
        switch self {
        case .above: return .bottom
        case .below: return .top
        }
    }
}

private enum StarTooltipArrowEdge {
    case top
    case bottom
}

private struct StarAchievementTooltip: View {
    let rowTitle: String
    let lines: [String]
    let arrowEdge: StarTooltipArrowEdge
    let arrowXOffset: CGFloat

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
        .chartCalloutStyle(.productLight)
        .overlay(alignment: arrowEdge == .top ? .top : .bottom) {
            TooltipTriangle(pointsTo: arrowEdge)
                .fill(Color.white)
                .frame(width: 14, height: 8)
                .offset(x: arrowXOffset, y: arrowEdge == .top ? -7 : 7)
        }
    }
}

private struct TooltipTriangle: Shape {
    let pointsTo: StarTooltipArrowEdge

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch pointsTo {
        case .top:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        case .bottom:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
        path.closeSubpath()
        return path
    }
}
