# OZCharts 2.1 Migration Guide

Use this guide when moving an app from 2.0-style examples to the 2.1 API surface.

## What Changed

2.1 keeps the core `CartesianChartView` and series-first API, then adds production-facing capabilities around product charts, live streams, richer selection, stable ids, and handoff documentation.

## Recommended Updates

### Use Stable Ids

Pass stable `id:` values to series and custom annotations when charts are recreated inside SwiftUI `body`:

```swift
LineSeries(data: readings, id: glucoseSeriesID, color: .cyan)
CustomViewAnnotation(id: targetLabelID, x: 12, y: 120) { TargetLabel() }
```

This keeps selection, element hit-testing, and animation continuity predictable.

### Prefer Element Selection For Non-Point Charts

Use `.chartElementSelection` for bars, stacked bars, and donut segments:

```swift
.chartElementSelection { elements in
    selectedElement = elements.first
}
```

`ChartSelectedElement` carries the selected element bounds, center position, optional interaction position, labels, ids, and domain values.

### Use AxisTransform For Display-Only Secondary Axes

Keep data and geometry in the source domain. Use `AxisTransform` only for labels:

```swift
YAxisConfig(
    position: .trailing,
    axisTransform: AxisTransform { milliseconds in 60_000 / milliseconds },
    labelFormatter: { "\(Int($0))" }
)
```

### Use LiveTrackingMode For Streaming Charts

For a live chart with scrollable history, use a full retained domain plus an initial trailing viewport:

```swift
.chartInitialViewport(xWindow: 60 * 60, anchor: .trailing)
.chartLiveTracking(.followLatest(pausedBehavior: .freezeVisibleWindow))
.chartViewport($viewport)
```

Use `viewport.requestJumpToLatest()` for a "Live" or "Latest" button.

### Use Anchored Callout Layout For Product Tooltips

When a product tooltip needs the triangle to point at the tap location while the card stays in a safe area, use `ChartAnchoredCalloutLayout` to calculate the card center and arrow offset:

```swift
let layout = ChartAnchoredCalloutLayout.vertical(
    anchor: selectedElement.interactionPosition ?? selectedElement.position,
    calloutSize: CGSize(width: 180, height: 92),
    containerSize: plotSize,
    preferredSide: .below
)
```

Then place the SwiftUI callout through `CustomViewAnnotation(placement: .fixed(layout.center))`.

## Compatibility Notes

2.1 is intended to be source-compatible with normal 2.0 line, area, bar, selection, annotation, and viewport usage. The main migration work is adopting stable ids and the newer modifiers where product-grade interactions require them.

## Pre-Release Checklist

Run:

```bash
swiftlint lint --no-cache
swift test
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```
