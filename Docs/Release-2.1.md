# OZCharts 2.1 Prerelease Notes

This prerelease focuses on product-chart readiness, live viewport behavior, and external-team handoff.

## Highlights

* Product-style chart support for violin distribution, donut score composition, stacked achievement bars, and stacked area point distribution.
* JSON demo scenarios based on domain events rather than drawing coordinates.
* Unified plot-area, axis, annotation, tooltip, and hit-testing infrastructure.
* Axis display transforms for secondary-axis use cases.
* Live viewport tracking with follow-latest, paused history, delayed live window, and jump-to-latest behavior.
* Tooltip and callout presets with clamped placement.
* Product snapshot signature tests and optional performance benchmarks.
* DocC and handoff documentation for external integration.

## Verification

Run the standard suite:

```bash
swift test
```

Run optional load benchmarks:

```bash
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

Build the demo app:

```bash
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## Known Follow-Ups

* Add automated rendered snapshot tests when a stable visual snapshot runner is chosen.
* Decide final semantic version tag name before sharing the prerelease externally.
* Capture fresh simulator screenshots for the handoff deck after final visual QA.
