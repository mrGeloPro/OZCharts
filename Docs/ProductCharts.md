# Product Chart Recipes

These recipes show how to recreate the product-style charts used in the demo app. The goal is to keep source data realistic: apps should pass domain values and events, while OZCharts handles scaling, drawing, annotations, and interaction.

## Accuracy Overview

Use a `ViolinSeries` for mirrored distributions, scatter points for observed samples, a dashed `HorizontalAnnotation` for the target, and a `RangeAnnotation` label for readable target text.

```swift
CartesianChartView(
    series: [resultViolin, bestViolin],
    xScale: LinearScale(domain: 0...100),
    yScale: LinearScale(domain: 330...900),
    yAxes: [
        YAxisConfig(position: .leading, explicitValues: deltaTicks, title: "ΔT (ms)"),
        YAxisConfig(
            position: .trailing,
            explicitValues: deltaTicks,
            axisTransform: AxisTransform
                .reciprocal(numerator: 60_000)
                .replacingNonFinite(with: 0),
            labelFormatter: { "\(Int($0))" },
            title: "Rhythm (bpm)"
        )
    ],
    rangeAnnotations: [
        RangeAnnotation(
            yRange: 496...504,
            label: "Target 120 bpm",
            color: .yellow,
            opacity: 0,
            labelColor: .yellow,
            showsLabel: true,
            labelXPosition: 0.57,
            labelAnchor: .leading,
            labelYOffset: -16
        )
    ],
    horizontalAnnotations: [
        HorizontalAnnotation(yValue: 500, color: .yellow)
    ]
) { _ in EmptyView() }
```

Keep the target label above the line and away from dense points by adjusting `labelXPosition`, `labelAnchor`, and `labelYOffset`.

## Star Achievement Times

Use `StackedBarSeries` for segmented achievement time, a striped fill for unavailable or remaining time, value labels as `CustomViewAnnotation`, and a compact tooltip. For dense horizontal bars, prefer row-aware fixed anchors: the callout follows the selected row vertically, but uses a safe x-position inside the plot so text never clips at the axis edge.

```swift
StackedBarSeries(
    data: rows,
    stackOrder: [.s1, .s2, .s3, .remainder],
    colorMapper: palette.color,
    fillStyleMapper: { group in
        group == .remainder
            ? .stripes(foreground: .white.opacity(0.14), background: .gray.opacity(0.2))
            : .gradient(palette.gradient(group))
    },
    barHeight: 28,
    cornerRadius: 4
)
```

For callouts, build the content as normal SwiftUI and apply the preset:

```swift
VStack(alignment: .leading) {
    Text("High score").bold()
    Text("Star 1: 1.00min")
    Text("Star 2: 3.00min (total)")
}
.frame(width: 168, alignment: .leading)
.chartCalloutStyle(.productLight)
```

For production screens, cap rich callouts so they wrap instead of forcing the
chart to place an oversized fixed-width view:

```swift
chart
    .chartTooltipPlacement(.automatic, padding: 10)
    .chartTooltipMaxWidth(220)
```

The placement engine clamps the callout to the plot bounds and resolves a final
attachment side, so custom arrow/pointer styles can follow the real placement
instead of assuming that the preferred side always fit.

For anchored SwiftUI overlays such as selected-row detail panels or value
labels, use `CustomViewAnnotation` placement metadata instead of manual screen
offsets:

```swift
CustomViewAnnotation(
    id: selectedRowID,
    x: selectedX,
    y: selectedRowY,
    placement: .automatic,
    collisionPriority: 20,
    avoidsCollisions: true,
    padding: 10
) {
    achievementCallout
        .frame(width: 176, alignment: .leading)
        .chartCalloutStyle(.productLight)
}
```

Use element selection for row/segment callouts. `StackedBarSeries` now exposes
the tapped segment as `ChartSelectedElement`, so apps can position their detail
panel from `element.interactionPosition ?? element.position` and read stable
`pointID`, `segmentIndex`, `groupLabel`, `value`, and `bounds`.

```swift
chart
    .chartElementSelection { elements in
        selectedAchievement = elements.first
    }
    .chartSelectionState($selection)
```

For product-like tooltips, prefer a fixed content width plus automatic
placement. This keeps the callout visually close to the tapped row while the
layout engine avoids clipping at the left/right edges.

## Total Score

Use `DonutSeries` for score composition. `gapAngle` controls arc spacing, `thickness` controls ring weight, `lineCap` controls rounded ends, and each `DonutSegmentStyle` can use `explodedOffset` for separated segments.

```swift
DonutSeries(
    data: scoreShare,
    colors: [.cyan, .purple, .yellow],
    segmentStyles: [
        DonutSegmentStyle(fill: .gradient([.cyan, .mint])),
        DonutSegmentStyle(fill: .gradient([.purple, .pink]), explodedOffset: 10),
        DonutSegmentStyle(fill: .gradient([.yellow, .orange]), explodedOffset: 14)
    ],
    segmentLabelMapper: { point in scoreLabel(for: point) },
    thickness: 42,
    gapAngle: .degrees(7),
    lineCap: .round
)
```

`gapAngle`, `thickness`, `lineCap`, and per-segment `explodedOffset` are the
main spacing controls. Use `segmentLabelMapper` when donut selection or
accessibility should say "Basic", "Bonus", or "Streak" instead of a generic
series label.

## Points Distribution

Use `StackedAreaSeries` with `.step` interpolation for cumulative score events. This keeps point additions visually discrete and closer to game or training telemetry than a smoothed trend line.

```swift
StackedAreaSeries(
    data: pointEvents,
    stackOrder: [.basic, .bonus, .streak],
    colorMapper: palette.color,
    fillStyleMapper: palette.fill,
    interpolation: .step
)
```

## Production Notes

Prefer JSON event inputs over drawing coordinates. Keep values in real units, define chart domains explicitly for product screens, and use `AxisTransform` only for display labels. For large datasets, downsample dense line and area series before rendering while keeping event markers and selected points in full fidelity.

Persist linked chart selection with `ChartSelectionState`. The legacy
`selectedX` field remains useful for crosshair-style charts, while
`selectedPoints` carries stable point ids, series ids, series indices, and
domain `x/y` values. Non-point marks such as bars, stacked bar segments, and
donut slices use `selectedElements`, which carries the selected element kind,
stable ids, series metadata, bounds, center position, label, and value.

Product data should provide stable point ids when visual stability matters,
especially for scatter jitter in violin charts and for restoring selected
stacked-bar or donut segments.

## Verification Checklist

Before handing a product recreation to an app team:

* Add a smoke render test for the chart.
* Add a product snapshot signature test for major visual templates.
* Add element-selection tests for any non-point chart used with callouts.
* Run `swift test` locally.
* Run performance benchmarks only when needed with
  `RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests`.
