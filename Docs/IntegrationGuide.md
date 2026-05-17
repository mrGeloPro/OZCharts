# OZCharts Integration Guide

This guide is the short path for a product team adopting OZCharts in a real SwiftUI app.

## Requirements

* Swift 5.9+
* iOS 16+
* Xcode version that supports Swift Package Manager and SwiftUI Canvas

## Install

Add the package in Xcode:

1. Open `File > Add Package Dependencies...`
2. Enter the repository URL.
3. Select the `OZCharts` library product.

Then import the framework:

```swift
import OZCharts
```

## Data Model

Prefer domain data over drawing coordinates. The app should pass values such as timestamp, glucose, score, bpm, price, or duration. OZCharts handles scale mapping.

```swift
let readings = [
    Point2D(id: glucoseID1, x: 0, y: 118),
    Point2D(id: glucoseID2, x: 5, y: 142)
]
```

Use stable point ids whenever the chart needs persistent selection, stable violin jitter, or deterministic detail panels.

For grouped charts:

```swift
enum ScoreGroup: Hashable {
    case basic
    case bonus
    case streak
}

let points = [
    GroupedPoint2D(id: eventID, x: 20, y: 4, group: ScoreGroup.basic)
]
```

## Stable Series Identity

When a series is created inside a SwiftUI `body`, pass a stable `id`. This prevents unnecessary layout resets and keeps selection restoration predictable.

```swift
LineSeries(
    data: readings,
    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
    color: .cyan
)
```

The same `id:` pattern is available on line, area, scatter, bar, stacked bar, stacked area, violin, and donut series.

## Basic Chart

```swift
CartesianChartView(
    series: [
        LineSeries(
            data: readings,
            id: glucoseSeriesID,
            color: .cyan,
            interpolation: .monotone
        )
    ],
    xDomain: .fixed(0...24),
    yDomain: .fixed(40...240),
    theme: .dark,
    xAxes: [.time(suffix: "h")]
) { selectedPoints in
    if let point = selectedPoints.first {
        Text("\(Int(point.originalPoint.y)) mg/dL")
            .chartCalloutStyle(.productDark)
    }
}
.chartSelection(.nearestX, behavior: .tapAndDrag, dismissalPolicy: .persistent)
.chartTooltipPlacement(.automatic, padding: 10)
.chartTooltipMaxWidth(220)
```

## Events And Annotations

Use `ChartEventMarker` for domain events such as insulin dose, workout lap, milestone, alert, or financial transaction.

```swift
ChartEventMarker(
    id: eventID,
    x: 7.5,
    y: 145,
    label: "Insulin 4U",
    shape: .diamond,
    color: .orange
)
```

Use `RangeAnnotation` for target zones and bands.

```swift
RangeAnnotation(
    yRange: 70...180,
    label: "Target range",
    color: .green,
    opacity: 0.14,
    showsLabel: true
)
```

Custom annotations can be anchored to chart values while still using collision-aware placement and clamping. Prefer this for value labels, selected row callouts, badges, and product-specific overlays.

```swift
CustomViewAnnotation(
    id: calloutID,
    x: selectedX,
    y: selectedY,
    label: "Selected point",
    placement: .automatic,
    collisionPriority: 10,
    avoidsCollisions: true,
    padding: 10
) {
    Text("Target 120 bpm")
        .chartCalloutStyle(.productLight)
}
```

When space is tight, higher-priority annotations are kept first. Lower-priority annotations can be moved or hidden so labels do not cover each other or clip outside the plot.

## Non-Point Selection

Bars, stacked-bar segments, and donut segments publish `ChartSelectedElement`.

```swift
chart
    .chartSelectionChanged { selection in
        selectedElement = selection.primaryElement
    }
```

`ChartSelectedElement` includes:

* `kind`
* `seriesID`
* `seriesIndex`
* `pointID`
* `segmentIndex`
* `label`
* `groupLabel`
* `value`
* `position`
* `interactionPosition`
* `bounds`

Use this for product callouts, selected segment highlighting, or external detail panels.

Hit-testing is resolved through a shared core path:

* element hit-testing for bars, stacked bars, donut segments, and future custom element shapes
* point hit-testing for line, area, scatter, and other point-based series
* deterministic z-index ordering when interactive elements overlap
* cycle support for overlapping point clusters

This keeps tap behavior predictable across chart types.

Selected bars, stacked-bar segments, and donut segments also get a built-in
overlay. Tune or disable it with `chartSelectedElementStyle`.

```swift
chart
    .chartSelectedElementStyle(
        ChartSelectedElementStyle(
            strokeColor: .white.opacity(0.95),
            fillColor: .white.opacity(0.14),
            lineWidth: 2,
            cornerRadius: 4
        )
    )
```

## Layout And Plot Area

OZCharts uses `ChartLayoutEngine` to calculate axis insets and plot area consistently. Apps usually do not need to call it directly, but it is public for custom containers and snapshot checks.

```swift
let layout = ChartLayoutEngine.layout(
    in: CGSize(width: 320, height: 240),
    xAxes: [.init(position: .bottom, height: 32)],
    yAxes: [.init(position: .leading, width: 44)]
)

print(layout.plotArea)
```

Use this when building custom chart wrappers that need to align external controls, legends, or overlays with the chart plot area.

## Axis Display Transforms

Use `AxisTransform` when an axis should render labels in a derived unit while the chart still uses the original domain values.

```swift
YAxisConfig(
    position: .trailing,
    explicitValues: [900, 800, 700, 600, 500, 400, 330],
    axisTransform: .reciprocal(numerator: 60_000).replacingNonFinite(with: 0),
    labelFormatter: { "\(Int($0))" },
    title: "Rhythm (bpm)"
)
```

Useful transforms include `.linear`, `.offset`, `.percentage(of:)`, `.reciprocal`, `.clamped(to:)`, `.replacingNonFinite(with:)`, and `.combined(with:)`.

## Live Viewports

For telemetry, medical monitoring, finance ticks, workout streams, or logs,
keep the chart domain wider than the visible viewport. The chart can show the
latest hour while retaining a scrollable 24 hour history.

```swift
@State private var viewport = ChartViewportState.automatic

CartesianChartView(
    series: [LineSeries(data: events, id: liveSeriesID, color: .cyan)],
    xDomain: .fixed(historyStart...latestTimestamp),
    yDomain: .fixed(0...100)
) { selectedPoints in
    EmptyView()
}
.chartInitialViewport(xWindow: 60 * 60, anchor: .trailing)
.chartLiveTracking(
    .followLatest(
        pauseOnUserInteraction: true,
        pausedBehavior: .freezeVisibleWindow
    )
)
.chartViewport($viewport)
```

When the user stays near the trailing edge, new events keep the viewport pinned
to the latest data. When the user scrolls back, `viewport.liveTrackingStatus`
becomes `.pausedByUser`; incoming events update the data without snapping the
viewport forward. Resume live mode from external UI by requesting a jump:

```swift
Button("Live") {
    viewport.requestJumpToLatest()
}
```

If old data is trimmed from the app-side buffer, OZCharts clamps the paused
viewport into the remaining domain instead of jumping to the latest window.

Paused live mode supports two product behaviors:

* `.freezeVisibleWindow`: keep the inspected history window fixed while new data arrives.
* `.preserveTrailingOffset`: keep the same delay from the latest data, so the visible window continues moving as a delayed live stream.

## Linked Charts

Use `ChartSelectionState` and `ChartViewportState` when charts should share selection or zoom.

```swift
@State private var selection = ChartSelectionState.none
@State private var viewport = ChartViewportState()

priceChart
    .chartSelectionState($selection)
    .chartViewport($viewport)

volumeChart
    .chartSelectionState($selection)
    .chartViewport($viewport)
```

## Accessibility

Always set a chart label and a selected value formatter on product screens.

```swift
.chartAccessibility(
    label: "Glucose trend",
    summary: "24 hour glucose readings",
    selectedValueFormatter: { points in
        points.first.map { "Glucose \(Int($0.originalPoint.y)) milligrams per deciliter" }
    },
    selectedElementFormatter: { elements in
        elements.first?.label.map { "Selected \($0)" }
    }
)
```

## Performance

For dense line or area charts:

```swift
LineSeries(
    data: samples,
    id: samplesSeriesID,
    color: .cyan,
    downsampling: .automatic(maxPointsPerPixel: 1)
)
```

Run the optional benchmark when changing layout or rendering code:

```bash
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

## Verification

Before shipping:

```bash
swift test
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Manual QA should cover:

* Dark and light backgrounds.
* Small iPhone width.
* Dynamic Type where applicable.
* VoiceOver summary and selected value.
* Tap/drag selection.
* Zoom and pan.
* Empty data state.
* Large data sets.
