//
//  AxisMarkersDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

struct AxisMarkersDemoView: View {
    @State private var selectedMarkers: [ChartAxisMarkerContext] = []

    private var selectedMarkerID: UUID? {
        selectedMarkers.first?.marker.id
    }

    private let data: [Point2D] = [
        Point2D(x: 0, y: 42),
        Point2D(x: 1, y: 58),
        Point2D(x: 2, y: 52),
        Point2D(x: 3, y: 74),
        Point2D(x: 4, y: 66),
        Point2D(x: 5, y: 82),
        Point2D(x: 6, y: 70),
        Point2D(x: 7, y: 78),
        Point2D(x: 8, y: 64),
        Point2D(x: 9, y: 72),
        Point2D(x: 10, y: 61)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel(minHeight: 470) {
                    header

                    CartesianChartView(
                        series: [
                            LineSeries(
                                data: data,
                                id: DemoSeriesID.axisMarkerLine,
                                color: DemoColors.cyan,
                                lineWidth: 3,
                                interpolation: .monotone,
                                area: AreaStyle(fillColor: DemoColors.cyan, fillOpacity: 0.16)
                            )
                        ],
                        xDomain: .fixed(0...10),
                        yDomain: .fixed(30...90),
                        xAxes: [
                            XAxisConfig(
                                position: .bottom,
                                showGrid: true,
                                showTicks: true,
                                explicitValues: [0, 2, 4, 6, 8, 10],
                                labelFormatter: { "\(Int($0))h" },
                                textColor: DemoColors.secondaryText,
                                height: 42,
                                showAxisLine: false,
                                labelSpacing: 8
                            ),
                            XAxisConfig(
                                position: .top,
                                showGrid: false,
                                showTicks: false,
                                explicitValues: [],
                                labelFormatter: { _ in "" },
                                height: 34,
                                showAxisLine: false
                            )
                        ],
                        yAxes: [
                            YAxisConfig(
                                position: .leading,
                                explicitValues: [40, 55, 70, 85],
                                labelFormatter: { "\(Int($0))" },
                                textColor: DemoColors.secondaryText,
                                width: 44,
                                showAxisLine: false,
                                labelSpacing: 8
                            ),
                            YAxisConfig(
                                position: .trailing,
                                showGrid: false,
                                showTicks: false,
                                explicitValues: [55, 82],
                                labelFormatter: { "\(Int($0))%" },
                                textColor: DemoColors.secondaryText,
                                width: 52,
                                showAxisLine: false,
                                labelSpacing: 8
                            )
                        ],
                        axisMarkers: axisMarkers
                    ) { _ in
                        EmptyView()
                    }
                    .chartPlotBorder(edges: .all, color: Color.white.opacity(0.18), lineWidth: 1)
                    .chartPlotInsets(leading: 8, trailing: 8)
                    .chartAxisMarkerSelection(hitboxRadius: 28, overlapping: .cycle) { markers in
                        selectedMarkers = markers
                    }
                    .frame(height: 330)

                    selectedMarkerCard

                    DemoLegend(
                        items: [
                            ("Auto", DemoColors.cyan),
                            ("Compact", DemoColors.purple),
                            ("Shift", DemoColors.green),
                            ("Stack", DemoColors.orange)
                        ]
                    )
                }

                DemoHint(
                    text: "Tap the clustered axis badges repeatedly to cycle overlapping markers."
                )
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Axis Markers")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Axis Marker Collisions")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Text("Priority, compact fallback, shifting, stacking and tap cycling.")
                    .font(.caption)
                    .foregroundColor(DemoColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Text("\(axisMarkers.count)")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DemoColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var selectedMarkerCard: some View {
        if let marker = selectedMarkers.first {
            HStack(spacing: 10) {
                Circle()
                    .fill(color(for: marker.marker.id))
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(marker.marker.accessibilityLabel ?? "Axis marker")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text("value \(String(format: "%.1f", marker.marker.value)) · \(marker.usesCompactContent ? "compact" : "full")")
                        .font(.caption)
                        .foregroundColor(DemoColors.secondaryText)
                }

                Spacer()

                Text("\(selectedMarkers.count)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(DemoColors.cyan)
            }
            .padding(12)
            .background(DemoColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Text("No marker selected")
                .font(.caption.weight(.semibold))
                .foregroundColor(DemoColors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(DemoColors.surface.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var axisMarkers: [ChartAxisMarker] {
        [
            ChartAxisMarker.x(
                id: DemoAxisMarkerID.highPriority,
                value: 5,
                placement: .bottom,
                offset: CGSize(width: 0, height: 18),
                priority: 30,
                collisionStrategy: .automatic,
                accessibilityLabel: "DST change",
                compactContent: {
                    axisBadge(
                        icon: "clock.arrow.circlepath",
                        color: DemoColors.cyan,
                        isSelected: isSelected(DemoAxisMarkerID.highPriority)
                    )
                },
                content: {
                    axisLabel(
                        "DST",
                        icon: "clock.arrow.circlepath",
                        color: DemoColors.cyan,
                        isSelected: isSelected(DemoAxisMarkerID.highPriority)
                    )
                }
            ),
            ChartAxisMarker.x(
                id: DemoAxisMarkerID.compactFallback,
                value: 5.08,
                placement: .bottom,
                offset: CGSize(width: 0, height: 18),
                priority: 20,
                collisionStrategy: .hideLabel,
                accessibilityLabel: "Maintenance window",
                compactContent: {
                    axisBadge(
                        icon: "wrench.adjustable",
                        color: DemoColors.purple,
                        isSelected: isSelected(DemoAxisMarkerID.compactFallback)
                    )
                },
                content: {
                    axisLabel(
                        "Maint",
                        icon: "wrench.adjustable",
                        color: DemoColors.purple,
                        isSelected: isSelected(DemoAxisMarkerID.compactFallback)
                    )
                }
            ),
            ChartAxisMarker.x(
                id: DemoAxisMarkerID.shifted,
                value: 5.16,
                placement: .bottom,
                offset: CGSize(width: 0, height: 18),
                priority: 10,
                collisionStrategy: .shift(maxOffset: 56),
                accessibilityLabel: "Deployment marker"
            ) {
                axisLabel(
                    "Shift",
                    icon: "arrow.left.and.right",
                    color: DemoColors.green,
                    isSelected: isSelected(DemoAxisMarkerID.shifted)
                )
            },
            ChartAxisMarker.x(
                id: DemoAxisMarkerID.stacked,
                value: 5.24,
                placement: .bottom,
                offset: CGSize(width: 0, height: 18),
                priority: 8,
                collisionStrategy: .stack(spacing: 5),
                accessibilityLabel: "Backup marker"
            ) {
                axisLabel(
                    "Stack",
                    icon: "square.stack.3d.up",
                    color: DemoColors.orange,
                    isSelected: isSelected(DemoAxisMarkerID.stacked)
                )
            },
            ChartAxisMarker.y(
                id: DemoAxisMarkerID.leadingThreshold,
                value: 55,
                placement: .leading,
                offset: CGSize(width: -18, height: 0),
                priority: 12,
                collisionStrategy: .automatic,
                accessibilityLabel: "Lower threshold",
                compactContent: {
                    axisBadge(
                        icon: "arrow.down",
                        color: DemoColors.pink,
                        isSelected: isSelected(DemoAxisMarkerID.leadingThreshold)
                    )
                },
                content: {
                    axisLabel(
                        "Low",
                        icon: "arrow.down",
                        color: DemoColors.pink,
                        isSelected: isSelected(DemoAxisMarkerID.leadingThreshold)
                    )
                }
            ),
            ChartAxisMarker.y(
                id: DemoAxisMarkerID.trailingThreshold,
                value: 82,
                placement: .trailing,
                offset: CGSize(width: 20, height: 0),
                priority: 14,
                collisionStrategy: .automatic,
                accessibilityLabel: "Upper threshold",
                compactContent: {
                    axisBadge(
                        icon: "arrow.up",
                        color: DemoColors.yellow,
                        isSelected: isSelected(DemoAxisMarkerID.trailingThreshold)
                    )
                },
                content: {
                    axisLabel(
                        "High",
                        icon: "arrow.up",
                        color: DemoColors.yellow,
                        isSelected: isSelected(DemoAxisMarkerID.trailingThreshold)
                    )
                }
            )
        ]
    }

    private func isSelected(_ id: UUID) -> Bool {
        selectedMarkerID == id
    }

    private func axisLabel(
        _ text: String,
        icon: String,
        color: Color,
        isSelected: Bool = false
    ) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(text)
                .font(.caption2.weight(.bold))
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(color.opacity(isSelected ? 1 : 0.9))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(.white.opacity(isSelected ? 0.9 : 0), lineWidth: 2)
        }
        .shadow(color: color.opacity(isSelected ? 0.45 : 0), radius: 8)
        .scaleEffect(isSelected ? 1.08 : 1)
    }

    private func axisBadge(
        icon: String,
        color: Color,
        isSelected: Bool = false
    ) -> some View {
        Image(systemName: icon)
            .font(.caption2.weight(.bold))
            .foregroundColor(.white)
            .frame(width: 24, height: 24)
            .background(color)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(.white.opacity(isSelected ? 0.95 : 0), lineWidth: 2)
            }
            .shadow(color: color.opacity(isSelected ? 0.45 : 0), radius: 8)
            .scaleEffect(isSelected ? 1.14 : 1)
    }

    private func color(for id: UUID) -> Color {
        switch id {
        case DemoAxisMarkerID.highPriority: return DemoColors.cyan
        case DemoAxisMarkerID.compactFallback: return DemoColors.purple
        case DemoAxisMarkerID.shifted: return DemoColors.green
        case DemoAxisMarkerID.stacked: return DemoColors.orange
        case DemoAxisMarkerID.leadingThreshold: return DemoColors.pink
        default: return DemoColors.yellow
        }
    }
}
