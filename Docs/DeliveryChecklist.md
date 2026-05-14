# OZCharts Delivery Checklist

Use this checklist before sending the framework to an external company or using it in a production project.

## Repository

* `Package.swift` builds the `OZCharts` library product.
* Minimum supported versions are documented: Swift 5.9+, iOS 16+.
* `LICENSE` and `AUTHORS.md` are present.
* `README.md` explains install, core API, selection, annotations, product styling, and demo app.
* `Docs/ProductCharts.md` explains how to recreate the product-style demo charts.
* `Docs/IntegrationGuide.md` explains adoption patterns for app teams.

## Demo

* Demo app builds with `xcodebuild`.
* Demo scenarios use JSON domain events, not drawing coordinates.
* Product-like charts are represented:
  * smooth line and area chart
  * violin distribution with target annotation
  * stacked achievement bars
  * donut score composition
  * stacked area point distribution
  * real-world medical, sport, financial, and operational scenarios

## API Readiness

* Series support stable `id:` values for SwiftUI body-created charts.
* Points support stable ids through `Point2D` and `GroupedPoint2D`.
* Event markers and custom view annotations support stable ids.
* Non-point interaction uses `ChartSelectedElement`.
* Linked interaction uses `ChartSelectionState`.
* Linked viewport uses `ChartViewportState`.
* Axis display transforms use `AxisTransform`.
* Tooltip placement clamps content inside the plot bounds.
* Tooltip width can be capped with `.chartTooltipMaxWidth`.

## Tests

Run:

```bash
swift test
```

Expected coverage:

* series layout tests
* axis and scale tests
* viewport and selection tests
* element-selection tests for bar, stacked bar, and donut
* annotation tests
* tooltip placement tests
* rendering smoke tests
* product snapshot signature tests
* JSON scenario decoding tests

Optional:

```bash
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

## Manual QA

* Verify charts on a small iPhone simulator.
* Verify charts on a larger iPhone simulator.
* Verify dark theme contrast.
* Verify selection remains readable and unclipped.
* Verify tap targets feel correct.
* Verify linked charts keep selection and viewport in sync.
* Verify empty data screens.
* Verify VoiceOver chart summary and selected values.
* Capture final screenshots for the handoff deck or proposal.

## Handoff Package

Send:

* repository URL or source archive
* README
* Integration Guide
* Product Chart Recipes
* Release notes or changelog
* DemoApp instructions
* latest screenshots
* known limitations and critical follow-up list
