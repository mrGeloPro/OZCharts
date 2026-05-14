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
.chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
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

## Non-Point Selection

Bars, stacked-bar segments, and donut segments publish `ChartSelectedElement`.

```swift
chart
    .chartElementSelection { elements in
        selectedElement = elements.first
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
* `bounds`

Use this for product callouts, selected segment highlighting, or external detail panels.

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
