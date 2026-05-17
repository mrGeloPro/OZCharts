//
//  RealWorldScenarioViews.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

struct RealWorldScenariosView: View {
    @State private var selectedScenarioID = DemoScenarioStore.scenarios.first?.id
    @State private var viewport = ChartViewportState.automatic
    @State private var selection = ChartSelectionState.none
    @State private var lineMode = RealWorldLineMode.smooth
    @State private var showsEvents = true

    private let scenarios = DemoScenarioStore.scenarios

    private var selectedScenario: DemoScenario? {
        scenarios.first { $0.id == selectedScenarioID } ?? scenarios.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Real-world Scenarios")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Domain events from JSON are adapted into chart series, markers, thresholds and tooltips.")
                        .font(.subheadline)
                        .foregroundColor(DemoColors.secondaryText)
                }

                scenarioPicker
                displayControls

                if let selectedScenario {
                    RealWorldScenarioPanel(
                        scenario: selectedScenario,
                        lineMode: lineMode,
                        showsEvents: showsEvents && selectedScenario.allowsEventMarkers,
                        viewport: $viewport,
                        selection: $selection
                    )
                    .id(selectedScenario.id)

                    EventFeedView(scenario: selectedScenario)
                } else {
                    DemoHint(text: "DemoScenarios.json was not found in the app bundle.")
                }
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Real-world Data")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedScenarioID) { _, _ in
            viewport = .automatic
            selection = .none
        }
    }

    private var scenarioPicker: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 152), spacing: 12)], spacing: 12) {
            ForEach(scenarios) { scenario in
                Button {
                    selectedScenarioID = scenario.id
                } label: {
                    RealWorldScenarioCard(
                        scenario: scenario,
                        isSelected: scenario.id == selectedScenario?.id
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var displayControls: some View {
        HStack(spacing: 10) {
            Picker("Line", selection: $lineMode) {
                ForEach(RealWorldLineMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $showsEvents) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(eventsControlColor)
            }
            .labelsHidden()
            .toggleStyle(.switch)
            .frame(width: 56)
            .disabled(!(selectedScenario?.allowsEventMarkers ?? true))
            .opacity((selectedScenario?.allowsEventMarkers ?? true) ? 1 : 0.5)
        }
        .padding(10)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(DemoColors.border, lineWidth: 1)
        )
        .cornerRadius(14)
    }

    private var eventsControlColor: Color {
        guard selectedScenario?.allowsEventMarkers ?? true else { return DemoColors.secondaryText }
        return showsEvents ? DemoColors.orange : DemoColors.secondaryText
    }
}

private enum RealWorldLineMode: String, CaseIterable, Identifiable {
    case smooth
    case linear

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smooth:
            return "Smooth"
        case .linear:
            return "Linear"
        }
    }
}

private struct RealWorldScenarioCard: View {
    let scenario: DemoScenario
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: scenario.icon)
                    .font(.headline)
                    .foregroundColor(scenario.tint.color)
                    .frame(width: 34, height: 34)
                    .background(scenario.tint.color.opacity(0.14))
                    .clipShape(Circle())

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(scenario.tint.color)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(scenario.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                Text(scenario.domain.capitalized)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(scenario.tint.color)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(14)
        .background(isSelected ? scenario.tint.color.opacity(0.12) : DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? scenario.tint.color.opacity(0.56) : DemoColors.border, lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

private struct RealWorldScenarioPanel: View {
    let scenario: DemoScenario
    let lineMode: RealWorldLineMode
    let showsEvents: Bool
    @Binding var viewport: ChartViewportState
    @Binding var selection: ChartSelectionState

    var body: some View {
        DemoChartPanel {
            header
            chart

            TargetRangeSummary(scenario: scenario)
            DemoLegend(items: scenario.legendItems(includeEvents: showsEvents))
        }
    }

    private var chart: some View {
        CartesianChartView(
            series: scenario.chartSeries(useSmoothLines: lineMode == .smooth),
            xDomain: .fixed(scenario.xDomain),
            yDomain: .fixed(scenario.yDomain),
            xAxes: [
                XAxisConfig(
                    position: scenario.xAxis.resolvedPosition,
                    explicitValues: scenario.xAxis.explicitValues,
                    tickStrategy: scenario.xAxis.explicitValues == nil ? .nice : .regular,
                    labelCollisionStrategy: .hideOverlapping(minSpacing: 42),
                    tickCount: scenario.xAxis.tickCount ?? 6,
                    labelFormatter: scenario.xAxisLabel
                )
            ],
            yAxes: [
                YAxisConfig(
                    position: scenario.yAxis.resolvedPosition,
                    tickStrategy: .nice,
                    gridColor: .white.opacity(0.10),
                    tickCount: scenario.yAxis.tickCount ?? 5,
                    labelFormatter: { "\(Int($0))" },
                    textColor: DemoColors.secondaryText
                )
            ],
            xRangeAnnotations: scenario.xRangeAnnotations(),
            xyRangeAnnotations: scenario.xyRangeAnnotations(),
            rangeAnnotations: scenario.rangeAnnotations(),
            verticalAnnotations: scenario.verticalAnnotations(),
            horizontalAnnotations: scenario.horizontalAnnotations(),
            eventMarkers: showsEvents ? scenario.eventMarkers() : []
        ) { points in
            RealWorldPointTooltip(scenario: scenario, points: points)
        }
        .chartInitialViewport(xWindow: viewportWindow, anchor: .leading)
        .chartViewport($viewport)
        .chartSelection(.nearestX, behavior: .tapAndDrag, dismissalPolicy: .persistent)
        .chartSelectionState($selection)
        .chartZoomControls(scenario.showsZoomControls, step: viewportWindow / 4)
        .chartAnnotationSelection(hitboxRadius: 32, overlapping: .cycle)
        .chartAnnotationTooltip { annotations in
            RealWorldAnnotationTooltip(scenario: scenario, annotations: annotations)
        }
        .chartTooltipPlacement(.automatic, padding: 12)
        .chartCrosshair(.both(color: scenario.tint.color.opacity(0.72), lineWidth: 1, dash: [3, 5]))
        .frame(height: 340)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(scenario.title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Text(scenario.subtitle)
                    .font(.caption)
                    .foregroundColor(DemoColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(scenario.measurementCount)")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                Text("readings")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(scenario.tint.color)
            }
        }
    }

    private var viewportWindow: Double {
        let domain = scenario.xDomain
        return (domain.upperBound - domain.lowerBound) * scenario.initialViewportFraction
    }
}

private extension DemoScenario {
    var allowsEventMarkers: Bool {
        presentation?.resolvedShowsEventMarkers ?? true
    }

    var showsZoomControls: Bool {
        presentation?.resolvedShowsZoomControls ?? true
    }

    var initialViewportFraction: Double {
        presentation?.resolvedInitialViewportFraction ?? 0.55
    }
}

private struct TargetRangeSummary: View {
    let scenario: DemoScenario

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(scenario.tint.color.opacity(0.28))
                .frame(width: 22, height: 10)

            Text(summary)
                .font(.caption.weight(.semibold))
                .foregroundColor(DemoColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(DemoColors.surface)
        .cornerRadius(10)
    }

    private var summary: String {
        if let min = scenario.yAxis.targetMin, let max = scenario.yAxis.targetMax {
            return "Target range \(Int(min))-\(Int(max)) \(scenario.yAxis.unit)"
        }
        if let max = scenario.yAxis.targetMax {
            return "Target below \(Int(max)) \(scenario.yAxis.unit)"
        }
        return "\(scenario.yAxis.label) \(scenario.yAxis.unit)"
    }
}

private struct RealWorldPointTooltip: View {
    let scenario: DemoScenario
    let points: [ChartPointContext<Point2D>]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(points, id: \.originalPoint.id) { point in
                Text(scenario.valueText(point.originalPoint.y))
                    .font(.caption.bold())
                Text(scenario.xAxisLabel(point.originalPoint.x))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.72))
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.84))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

private struct RealWorldAnnotationTooltip: View {
    let scenario: DemoScenario
    let annotations: [ChartAnnotationContext]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(annotations) { annotation in
                Text(annotation.label ?? "Event")
                    .font(.caption.bold())
                Text("\(scenario.xAxisLabel(annotation.x))  \(scenario.valueText(annotation.y))")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.72))
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.84))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

private struct EventFeedView: View {
    let scenario: DemoScenario

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Event Source")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(scenario.events.prefix(8)) { event in
                HStack(spacing: 10) {
                    Circle()
                        .fill(event.kind.colorToken.color)
                        .frame(width: 9, height: 9)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.tooltipTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text("\(event.kind.displayName)  \(scenario.xAxisLabel(event.date.timeIntervalSince1970))")
                            .font(.caption2)
                            .foregroundColor(DemoColors.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DemoColors.border, lineWidth: 1)
        )
        .cornerRadius(18)
    }
}
