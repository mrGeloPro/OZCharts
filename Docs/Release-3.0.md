# OZCharts 3.0 Release Notes

OZCharts 3.0 is the API-shaping release. The focus is a cleaner SwiftUI chart
grammar for dashboard cards, result screens, and interactive product charts,
while keeping `CartesianChartView` available as the low-level escape hatch.

## Highlights

* `OZChart` is now the recommended entry point for cartesian charts.
* Advanced series have fluent helpers: `.donut(...)`, `.stackedArea(...)`,
  `.stackedBar(...)`, and `.violin(...)`.
* `OZDonutChart` is the recommended entry point for donut-only cards, so app
  code no longer needs fake cartesian domains.
* Unified selection uses one `ChartSelection<Point>` payload for points,
  visual elements, annotations, and linked `ChartSelectionState`.
* `.scrollSafeNearestX` avoids noisy distant selections on scrollable dashboard
  charts by waiting for a completed tap and limiting nearest lookup to the hitbox.
* Dashboard presets and legend options reduce repeated configuration for static,
  compact, dense timeline, and interactive charts.
* `OZChart.line(...)` and `.area(...)` expose product styling options such as
  gradient strokes, shadows, area fills, baselines, dash styling, and line caps.
* `LineSeriesStyle` lets apps keep one line-series declaration and toggle area
  fill through `showsFill`.
* `XAxisConfig` and `YAxisConfig` expose `labelInsets` for explicit axis-label
  padding that works independently from tick visibility.

## Migration Priorities

Prefer:

```swift
OZChart(samples)
    .line(color: .cyan, label: "Current")
    .presentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))
    .selection(.nearestX)
    .onSelection { selection in
        selectedPoint = selection.primaryPoint?.originalPoint
    }
```

Instead of new product code based on separate point and element callbacks.

For donut cards:

```swift
OZDonutChart(slices, colors: colors, label: "Score") {
    Text("82%")
}
.selection(.persistentElement)
.onSelection { selection in
    selectedSegment = selection.primaryElement
}
```

Use `CartesianChartView` directly only for custom scale objects, deeply custom
composition, or advanced overlays that cannot be expressed by the fluent API.

## Deprecated In 3.0

* `OZChart.onSelectionChanged`
* `OZChart.onElementSelectionChanged`
* `CartesianChartView.chartElementSelection`
* `OZDonutChart.selection(_:onChange:)`

These APIs remain available for incremental migration. New code should use
`.onSelection` or `.chartSelectionChanged`.

## Release Gate

Before tagging 3.0, run:

```bash
swift test
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild docbuild -scheme OZCharts -destination 'generic/platform=iOS'
```

Also review the DemoApp product screens and DocC pages against
`Docs/Migration-3.0.md`.
