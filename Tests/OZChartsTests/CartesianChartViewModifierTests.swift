//
//  CartesianChartViewModifierTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics
@testable import OZCharts
import SwiftUI
import XCTest

final class CartesianChartViewModifierTests: XCTestCase {
    func testGestureModifierUpdatesOnlyProvidedOptions() {
        let view = makeChart()
            .chartGestures(
                horizontalScroll: false,
                verticalZoom: false,
                minZoomScale: 0.25
            )

        XCTAssertFalse(view.isHorizontalScrollEnabled)
        XCTAssertTrue(view.isHorizontalZoomEnabled)
        XCTAssertTrue(view.isVerticalScrollEnabled)
        XCTAssertFalse(view.isVerticalZoomEnabled)
        XCTAssertEqual(view.minZoomScale, 0.25)
    }

    func testOptionStructModifiersUpdateChartOptions() {
        let view = makeChart()
            .chartInteractionOptions(
                ChartInteractionOptions(
                    isHorizontalScrollEnabled: false,
                    isVerticalScrollEnabled: false,
                    minZoomScale: 0.2
                )
            )
            .chartSelectionOptions(.nearestX)
            .chartTooltipOptions(
                ChartTooltipOptions(
                    placement: .leading,
                    anchor: .tapLocation,
                    offset: CGPoint(x: 3, y: 4),
                    padding: 10,
                    maxWidth: 220
                )
            )
            .chartViewportOptions(
                ChartViewportOptions(
                    liveTrackingMode: .followLatest(),
                    initialViewport: .xWindow(length: 5, anchor: .trailing),
                    showsZoomControls: true,
                    zoomControlStep: 1.25
                )
            )
            .chartRenderOptions(
                ChartRenderOptions(
                    legendPosition: .bottom,
                    legendSpacing: 6,
                    selectedElementStyle: ChartSelectedElementStyle(lineWidth: 3),
                    canvasRenderOrder: [.coreChart],
                    plotBorderStyle: .visible(edges: [.top, .bottom], lineWidth: 2)
                )
            )

        XCTAssertFalse(view.isHorizontalScrollEnabled)
        XCTAssertFalse(view.isVerticalScrollEnabled)
        XCTAssertEqual(view.minZoomScale, 0.2)
        XCTAssertEqual(view.selectionMode, .nearestX)
        XCTAssertEqual(view.selectionBehavior, .tapAndDrag)
        XCTAssertEqual(view.selectionActivation, .immediate)
        XCTAssertEqual(view.nearestSelectionPolicy, .unbounded)
        XCTAssertEqual(view.tooltipPlacement, .leading)
        XCTAssertEqual(view.tooltipAnchor, .tapLocation)
        XCTAssertEqual(view.tooltipOffset, CGPoint(x: 3, y: 4))
        XCTAssertEqual(view.tooltipPadding, 10)
        XCTAssertEqual(view.tooltipMaxWidth, 220)
        XCTAssertTrue(view.isLiveTrackingEnabled)
        XCTAssertEqual(view.initialViewport, .xWindow(length: 5, anchor: .trailing))
        XCTAssertTrue(view.showsZoomControls)
        XCTAssertEqual(view.zoomControlStep, 1.25)
        XCTAssertEqual(view.legendPosition, .bottom)
        XCTAssertEqual(view.legendSpacing, 6)
        XCTAssertEqual(view.legendOptions.rowSpacing, 8)
        XCTAssertEqual(view.selectedElementStyle.lineWidth, 3)
        XCTAssertEqual(view.canvasRenderOrder, [.coreChart])
        XCTAssertEqual(view.plotBorderStyle.edges, [.top, .bottom])
        XCTAssertEqual(view.plotBorderStyle.lineWidth, 2)
    }

    func testLegendOptionsModifierUpdatesLegendConfiguration() {
        let view = makeChart()
            .chartLegend(.compact(position: .trailing, itemLimit: 2))

        XCTAssertEqual(view.legendPosition, .trailing)
        XCTAssertEqual(view.legendSpacing, 8)
        XCTAssertEqual(view.legendOptions.rowSpacing, 6)
        XCTAssertEqual(view.legendOptions.itemLimit, 2)
    }

    func testPresentationPresetUpdatesChartOptions() {
        let view = makeChart()
            .chartPresentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))

        XCTAssertFalse(view.isHorizontalScrollEnabled)
        XCTAssertFalse(view.isVerticalScrollEnabled)
        XCTAssertEqual(view.selectionMode, .none)
        XCTAssertEqual(view.selectionBehavior, .disabled)
        XCTAssertEqual(view.legendPosition, .bottom)
        XCTAssertEqual(view.xAxes.first?.position, .top)
        XCTAssertEqual(view.yAxes.first?.position, .trailing)
    }

    func testSelectionModifierUpdatesModeHitboxAndCallback() {
        var callbackWasCalled = false
        var unifiedCallbackWasCalled = false
        var emptyTapLocation: CGPoint?
        let view = makeChart()
            .chartSelection(
                .nearestX,
                behavior: .tapAndDrag,
                overlapping: .cycle,
                hitboxRadius: 32,
                dismissalPolicy: .persistent,
                activation: .onTapEnd,
                nearestSelectionPolicy: .withinHitbox
            )
            .chartAnnotationSelection(
                hitboxRadius: 40,
                overlapping: .all,
                fallbackToPointSelection: false
            ) { _ in
                callbackWasCalled = true
            }
            .chartSelectionChanged { selection in
                unifiedCallbackWasCalled = selection.isEmpty
            }
            .chartSelectionPriority(.seriesFirst)
            .chartEmptyTap { location in
                emptyTapLocation = location
            }

        XCTAssertEqual(view.selectionMode, .nearestX)
        XCTAssertEqual(view.selectionBehavior, .tapAndDrag)
        XCTAssertEqual(view.overlappingSelectionMode, .cycle)
        XCTAssertEqual(view.hitboxRadius, 32)
        XCTAssertFalse(view.selectionDismissalPolicy.contains(.gestureEnd))
        XCTAssertEqual(view.selectionActivation, .onTapEnd)
        XCTAssertEqual(view.nearestSelectionPolicy, .withinHitbox)
        XCTAssertTrue(view.isAnnotationSelectionEnabled)
        XCTAssertEqual(view.annotationHitboxRadius, 40)
        XCTAssertEqual(view.annotationOverlappingSelectionMode, .all)
        XCTAssertFalse(view.annotationFallbackToPointSelection)
        XCTAssertEqual(view.selectionPriority, .seriesFirst)

        view.onAnnotationSelectionChanged([])
        XCTAssertTrue(callbackWasCalled)

        view.onChartSelectionChanged(.none)
        XCTAssertTrue(unifiedCallbackWasCalled)

        view.onEmptyTap(CGPoint(x: 7, y: 8))
        XCTAssertEqual(emptyTapLocation, CGPoint(x: 7, y: 8))
    }

    func testAnnotationTooltipModifierInstallsBuilder() {
        let view = makeChart().chartAnnotationTooltip { annotations in
            Text("\(annotations.count)")
        }

        XCTAssertNotNil(view.annotationTooltipContent)
    }

    func testVisualModifiersUpdateChartOptions() {
        let view = makeChart()
            .chartCrosshair(.both())
            .chartTooltipOffset(x: 4, y: -12)
            .chartTooltipPlacement(.trailing, padding: 14)
            .chartTooltipAnchor(.tapLocation)
            .chartTooltipMaxWidth(180)
            .chartSelectionDismissalPolicy(.pinned)
            .chartLiveTracking()
            .chartInitialViewport(xWindow: 8, anchor: .trailing)
            .chartViewport(.constant(ChartViewportState(visibleXDomain: 0 ... 8)))
            .chartSelectionState(.constant(ChartSelectionState(selectedX: 4)))
            .chartZoomControls(step: 1.5)
            .chartLegend(.trailing, spacing: 8)
            .chartSelectedElementStyle(ChartSelectedElementStyle(lineWidth: 4, cornerRadius: 9))
            .chartCanvasRenderOrder([.coreChart, .grid])
            .chartPlotBorder(edges: [.top, .leading], lineWidth: 2)

        XCTAssertEqual(view.crosshairStyle.mode, .both)
        XCTAssertEqual(view.tooltipOffset, CGPoint(x: 4, y: -12))
        XCTAssertEqual(view.tooltipPlacement, .trailing)
        XCTAssertEqual(view.tooltipAnchor, .tapLocation)
        XCTAssertEqual(view.tooltipPadding, 14)
        XCTAssertEqual(view.tooltipMaxWidth, 180)
        XCTAssertEqual(view.selectionDismissalPolicy, .pinned)
        XCTAssertTrue(view.isLiveTrackingEnabled)
        XCTAssertEqual(view.liveTrackingMode, .followLatest())
        XCTAssertEqual(view.initialViewport, .xWindow(length: 8, anchor: .trailing))
        XCTAssertEqual(view.viewportBinding?.wrappedValue.visibleXDomain, 0 ... 8)
        XCTAssertEqual(view.selectionStateBinding?.wrappedValue.selectedX, 4)
        XCTAssertTrue(view.showsZoomControls)
        XCTAssertEqual(view.zoomControlStep, 1.5)
        XCTAssertEqual(view.legendPosition, .trailing)
        XCTAssertEqual(view.legendSpacing, 8)
        XCTAssertEqual(view.selectedElementStyle.lineWidth, 4)
        XCTAssertEqual(view.selectedElementStyle.cornerRadius, 9)
        XCTAssertEqual(view.canvasRenderOrder, [.coreChart, .grid])
        XCTAssertEqual(view.plotBorderStyle.edges, [.top, .leading])
        XCTAssertEqual(view.plotBorderStyle.lineWidth, 2)
    }

    func testCustomLegendModifierInstallsBuilder() {
        let view = makeChart().chartLegend(.bottom) { items in
            Text("\(items.count)")
        }

        XCTAssertNotNil(view.customLegendContent)
    }

    func testCustomLegendOptionsModifierInstallsBuilder() {
        let view = makeChart()
            .chartLegend(.dashboard(position: .top, itemLimit: 3)) { items in
                Text("\(items.count)")
            }

        XCTAssertEqual(view.legendPosition, .top)
        XCTAssertEqual(view.legendOptions.itemLimit, 3)
        XCTAssertNotNil(view.customLegendContent)
    }

    func testLiveTrackingModifierAcceptsExplicitMode() {
        let view = makeChart().chartLiveTracking(
            .followLatest(
                pauseOnUserInteraction: false,
                trailingToleranceRatio: 0.1,
                pausedBehavior: .preserveTrailingOffset
            )
        )

        XCTAssertTrue(view.isLiveTrackingEnabled)
        XCTAssertEqual(view.liveTrackingMode.pauseOnUserInteraction, false)
        XCTAssertEqual(view.liveTrackingMode.trailingToleranceRatio, 0.1)
        XCTAssertEqual(view.liveTrackingMode.pausedBehavior, .preserveTrailingOffset)
    }

    func testSeriesChangeSignatureTracksDataChangesForStableSeriesIDs() throws {
        let seriesID = try XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000123"))
        let first = CartesianChartView(
            series: [
                LineSeries(
                    data: [Point2D(x: 0, y: 1)],
                    id: seriesID,
                    color: .blue
                )
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in EmptyView() }

        let updated = CartesianChartView(
            series: [
                LineSeries(
                    data: [Point2D(x: 0, y: 1), Point2D(x: 1, y: 2)],
                    id: seriesID,
                    color: .blue
                )
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in EmptyView() }

        XCTAssertNotEqual(first.seriesChangeSignature, updated.seriesChangeSignature)
    }

    func testSeriesChangeSignatureIgnoresPointIDsWhenValuesAreUnchanged() throws {
        let seriesID = try XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000124"))
        let first = CartesianChartView(
            series: [
                LineSeries(
                    data: [Point2D(id: UUID(), x: 0, y: 1)],
                    id: seriesID,
                    color: .blue
                )
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in EmptyView() }

        let rerendered = CartesianChartView(
            series: [
                LineSeries(
                    data: [Point2D(id: UUID(), x: 0, y: 1)],
                    id: seriesID,
                    color: .blue
                )
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in EmptyView() }

        XCTAssertEqual(first.seriesChangeSignature, rerendered.seriesChangeSignature)
    }

    func testSeriesChangeSignatureTracksStyleChangesForStableSeriesIDs() throws {
        let seriesID = try XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000125"))
        let data = [Point2D(id: UUID(), x: 0, y: 1), Point2D(id: UUID(), x: 1, y: 2)]
        let first = CartesianChartView(
            series: [
                LineSeries(
                    data: data,
                    id: seriesID,
                    color: .blue,
                    interpolation: .linear,
                    downsampling: .none
                )
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in EmptyView() }

        let restyled = CartesianChartView(
            series: [
                LineSeries(
                    data: data,
                    id: seriesID,
                    color: .blue,
                    interpolation: .monotone,
                    downsampling: .automatic(maxPointsPerPixel: 1)
                )
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in EmptyView() }

        XCTAssertNotEqual(first.seriesChangeSignature, restyled.seriesChangeSignature)
    }

    func testAccessibilityModifierInstallsDescriptor() {
        let view = makeChart().chartAccessibility(label: "Sales", summary: "Monthly sales")

        XCTAssertEqual(view.accessibilityDescriptor?.label, "Sales")
        XCTAssertEqual(view.accessibilityDescriptor?.summary, "Monthly sales")
    }

    func testEmptyStateModifierInstallsEmptyStateBuilder() {
        let view = makeChart().chartEmptyState {
            Text("No data")
        }

        XCTAssertNotNil(view.emptyState?())
    }

    func testDiagnosticsModifierInstallsCallback() {
        var receivedDiagnostics: [ChartDiagnostic] = []
        let view = makeChart().chartDiagnostics { diagnostics in
            receivedDiagnostics = diagnostics
        }

        view.onDiagnosticsChanged([
            ChartDiagnostic(code: "test", severity: .warning, message: "Test")
        ])

        XCTAssertEqual(receivedDiagnostics.map(\.code), ["test"])
    }

    func testOZChartBuilderCompilesCommonFluentAPI() {
        let data = [Point2D(x: 0, y: 1), Point2D(x: 1, y: 3)]
        let chart = OZChart(data)
            .line(
                color: .blue,
                lineWidth: 3,
                dash: [4, 2],
                lineCap: .round,
                interpolation: .monotone,
                strokeStyle: .gradient([.blue, .cyan]),
                shadow: ChartShadowStyle(color: .blue.opacity(0.2), radius: 4),
                area: AreaStyle(fillStyle: .gradient([.blue.opacity(0.2), .clear]), baseline: 0),
                downsampling: .automatic()
            )
            .line(
                style: LineSeriesStyle(
                    color: .cyan,
                    interpolation: .monotone,
                    showsFill: true,
                    fillOpacity: 0.18
                ),
                label: "Styled"
            )
            .area(
                color: .green,
                fillStyle: .gradient([.green.opacity(0.2), .clear]),
                baseline: 0,
                lineWidth: 2,
                strokeStyle: .color(.green),
                shadow: ChartShadowStyle(color: .green.opacity(0.2), radius: 3)
            )
            .presentation(.interactiveExploration())
            .selection(.nearestX)
            .selectionPriority(.seriesFirst)
            .annotationSelection(fallbackToPointSelection: false) { _ in }
            .domain(y: .fixed(0 ... 5))
            .annotations(
                xRanges: [XRangeAnnotation(xRange: 0.2 ... 0.6)],
                xyRanges: [XYRangeAnnotation(xRange: 0.6 ... 0.8, yRange: 3 ... 5)],
                ranges: [RangeAnnotation(yRange: 1 ... 4)],
                vertical: [VerticalAnnotation(xValue: 1, label: "Now")],
                horizontal: [HorizontalAnnotation(yValue: 3, label: "Target")]
            )
            .viewportState(.constant(ChartViewportState()))
            .selectionState(.constant(ChartSelectionState()))
            .onSelection { _ in }
            .tooltipAnchor(.tapLocation)
            .plotBorder(edges: .all, color: .gray, lineWidth: 1)
            .onEmptyTap { _ in }
            .tooltip { points in
                Text("\(points.count)")
            }

        XCTAssertNotNil(chart.body)
    }

    func testOZChartBuilderCompilesAdvancedFluentAPI() {
        let grouped = [
            GroupedPoint2D(x: 12, y: 0, group: "A"),
            GroupedPoint2D(x: 8, y: 0, group: "B"),
            GroupedPoint2D(x: 6, y: 1, group: "A"),
            GroupedPoint2D(x: 10, y: 1, group: "B")
        ]

        let chart = OZChart(grouped)
            .stackedBar(
                stackOrder: ["A", "B"],
                colorMapper: { $0 == "A" ? .blue : .green },
                groupLabel: { $0 },
                rowLabel: { $0 == 0 ? "Today" : "Yesterday" },
                rowEndLabel: { row, total in "\(Int(row)):\(Int(total))" },
                layout: .achievement(rowLabelLineLimit: 2),
                remainder: .target(
                    { _ in 32 },
                    signature: "advanced-fluent-target",
                    fillStyle: .stripes(foreground: .gray.opacity(0.4)),
                    accessibilityLabel: "Remaining"
                ),
                separatorStyle: StackedBarSeparatorStyle(color: .black, width: 1),
                interactionOptions: .rowsAndSegments
            )
            .stackedArea(
                stackOrder: ["A", "B"],
                colorMapper: { $0 == "A" ? .blue : .green },
                groupLabel: { $0 }
            )
            .violin(
                centerX: 0.5,
                sideMapper: { $0 == "A" ? .left : .right },
                colorMapper: { $0 == "A" ? .blue : .green },
                groupLabel: { $0 }
            )
            .legend(.dashboard(position: .bottom, itemLimit: 3))
            .compactAxes()
            .elementTooltip { elements in
                Text("\(elements.count)")
            }
            .elementTooltipContext { context in
                Text("\(context.elements.count)")
            }
            .tooltipAnchor(.hitPoint)
            .selection(.pinnedElement)
            .onStackedBarSelection { _ in }

        XCTAssertNotNil(chart.body)
    }

    func testStackedBarRowEndLabelTotalsOnlyIncludeVisibleStackOrderGroups() {
        enum Group: Hashable {
            case first
            case second
            case hidden
        }

        let data = [
            GroupedPoint2D(x: 2, y: 0, group: Group.first),
            GroupedPoint2D(x: 3, y: 0, group: Group.second),
            GroupedPoint2D(x: 99, y: 0, group: Group.hidden)
        ]

        let chart = OZChart(data)
            .stackedBar(
                stackOrder: [.first, .second],
                colorMapper: { _ in .blue },
                rowEndLabel: { _, total in "\(Int(total))" }
            )

        let axes = mirroredYAxes(from: chart)

        XCTAssertEqual(axes?.first?.labelFormatter(0), "5")
    }

    func testStackedBarRowAxesOnlyIncludeVisibleStackOrderRows() {
        enum Group: Hashable {
            case first
            case hidden
        }

        let data = [
            GroupedPoint2D(x: 2, y: 0, group: Group.first),
            GroupedPoint2D(x: 99, y: 9, group: Group.hidden)
        ]

        let chart = OZChart(data)
            .stackedBar(
                stackOrder: [.first],
                colorMapper: { _ in .blue },
                rowLabel: { "row-\(Int($0))" },
                rowEndLabel: { _, total in "\(Int(total))" }
            )

        let axes = mirroredYAxes(from: chart)

        XCTAssertEqual(axes?.count, 2)
        XCTAssertEqual(axes?.first?.explicitValues, [0])
        XCTAssertEqual(axes?.last?.explicitValues, [0])
    }

    func testOZChartBuilderCompilesDonutFluentAPI() {
        let data = [Point2D(x: 0, y: 35), Point2D(x: 1, y: 65)]
        let chart = OZChart(data)
            .donut(colors: [.blue, .green], label: "Score") { point in
                point.x == 0 ? "Won" : "Remaining"
            }
            .legend(.bottom)

        XCTAssertNotNil(chart.body)
    }

    func testOZDonutChartWrapperCompilesWithoutFakeDomainsAtCallSite() {
        let data = [Point2D(x: 0, y: 35), Point2D(x: 1, y: 65)]
        let chart = OZDonutChart(data, colors: [.blue, .green], label: "Score")
            .center {
                Text("65%")
            }
            .legend(.bottom)
            .selection(.persistentElement)
            .onSelection { _ in }
            .onSegmentSelection { _ in }

        XCTAssertNotNil(chart.body)
    }

    func testOZChartDefaultSeriesIDsAreStableAcrossRebuilds() {
        let data = [Point2D(x: 0, y: 1), Point2D(x: 1, y: 3)]
        let first = OZChart(data)
            .line(color: .blue)
            .scatter(color: .green)
        let rebuilt = OZChart(data)
            .line(color: .blue)
            .scatter(color: .green)

        XCTAssertEqual(first.seriesIDs, rebuilt.seriesIDs)
        XCTAssertEqual(Set(first.seriesIDs).count, 2)
    }

    private func makeChart() -> CartesianChartView<Point2D, LinearScale, LinearScale, EmptyView> {
        CartesianChartView(
            series: [
                LineSeries(data: [Point2D(x: 1, y: 2)], color: .blue)
            ],
            xScale: LinearScale(domain: 0 ... 10),
            yScale: LinearScale(domain: 0 ... 10)
        ) { _ in
            EmptyView()
        }
    }

    private func mirroredYAxes<Point, TooltipContent>(
        from chart: OZChart<Point, TooltipContent>
    ) -> [YAxisConfig]? where Point: ChartDataPoint, Point.XValue == Double, Point.YValue == Double {
        guard let value = Mirror(reflecting: chart).children.first(where: { $0.label == "yAxes" })?.value else {
            return nil
        }
        if let axes = value as? [YAxisConfig] {
            return axes
        }
        return Mirror(reflecting: value).children.first?.value as? [YAxisConfig]
    }
}
