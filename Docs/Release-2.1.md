# OZCharts 2.1 Prerelease Notes

This prerelease focuses on product-chart readiness, live viewport behavior, and external-team handoff.

## Highlights

* Product-style chart support for violin distribution, donut score composition, stacked achievement bars, and stacked area point distribution.
* JSON demo scenarios based on domain events rather than drawing coordinates.
* Unified plot-area, axis, annotation, tooltip, and hit-testing infrastructure.
* Axis display transforms for secondary-axis use cases.
* Live viewport tracking with follow-latest, paused history, delayed live window, and jump-to-latest behavior.
* Tooltip and callout presets with clamped placement.
* Anchored callout layout helper for tap-point aligned product tooltips.
* Product snapshot signature tests and optional performance benchmarks.
* GitHub Actions CI for package tests, linting, DemoApp builds, and manually triggered benchmarks.
* Chart input diagnostics for common integration mistakes such as non-finite data, duplicate ids, and unusably small canvases.
* Demo app source split into handoff, product, core, advanced, shared, and scenario folders.
* DocC and handoff documentation for external integration.
* Stable series ids now track point-value changes, so live updates and animated data transitions redraw correctly.

## Verification

Run the standard suite:

```bash
swift test
```

Run lint locally before tagging:

```bash
swiftlint lint --no-cache
```

`swiftformat --lint .` is useful as a follow-up once the current prerelease
branch is intentionally formatted. At the moment, broad formatting would touch
many existing files and should be done as its own reviewable change.

Run optional load benchmarks:

```bash
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

Build the demo app:

```bash
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## Known Follow-Ups

* Add full rendered DemoApp screenshot tests when a stable simulator snapshot runner is chosen.
* Decide final semantic version tag name before sharing the prerelease externally.
* Capture fresh simulator screenshots for the handoff deck after final visual QA.

## Handoff Links

* `Docs/Migration-2.1.md`
* `Docs/PerformanceBenchmarks.md`
* `Docs/DemoAppQA.md`
