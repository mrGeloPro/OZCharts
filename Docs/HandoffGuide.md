# OZCharts Handoff Guide

This guide is the shortest path for an external team to evaluate and integrate OZCharts.

## What To Review First

1. Open `README.md` for install, API examples, live charts, selection, annotations, and product styling.
2. Open `Docs/ProductCharts.md` to recreate the supplied product-style charts.
3. Run `DemoApp/DemoApp.xcodeproj` and start with the Handoff Scenarios section.
4. Check `Docs/DeliveryChecklist.md` before using the package in a client project.

## Integration Path

Add the Swift package, import `OZCharts`, and begin with `CartesianChartView` for cartesian charts or `DonutSeries` for score composition. Feed the chart domain values from app data or API events. Avoid precomputing screen coordinates in the host app.

Use fixed domains for product contracts and `.auto(...)` for exploratory charts. Use stable series ids whenever SwiftUI recreates series inside `body`.

## Data Ownership

The host app owns:

* API decoding and domain modeling.
* Retention and trimming policy for live streams.
* Business formulas used by `AxisTransform`.
* Product copy, colors, and final visual tuning.

OZCharts owns:

* Scale mapping and plot-area layout.
* Axis labels, grid lines, and display transforms.
* Selection and hit-testing.
* Tooltip and annotation placement.
* Live viewport tracking behavior.
* Rendering performance for dense chart layers.

## Live Chart Recommendation

For a 24-hour live chart, keep the full x-domain equal to retained history and set an initial trailing viewport for the visible window.

```swift
.chartInitialViewport(xWindow: 60 * 60, anchor: .trailing)
.chartLiveTracking(.followLatest(pausedBehavior: .freezeVisibleWindow))
.chartViewport($viewport)
```

Use `.freezeVisibleWindow` for investigation mode and `.preserveTrailingOffset` for delayed live monitoring.

## Verification Commands

```bash
swift test
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

The performance benchmarks are opt-in so normal CI stays fast.

## Current Handoff Contents

* Swift package source.
* Demo app with handoff scenarios and component catalog.
* Product chart recipes.
* Integration guide.
* Delivery checklist.
* Framework review with priorities.
* Optional performance benchmarks.
* DocC catalog for Xcode documentation.

## Remaining Manual QA

Before a paid integration starts, capture final screenshots on a small iPhone and a large iPhone, verify VoiceOver summaries on the most important charts, and agree on semantic versioning rules for breaking API changes.
