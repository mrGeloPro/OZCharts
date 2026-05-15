# OZCharts 2.5 Release Notes

OZCharts 2.5 turns the prerelease product-demo framework into a stronger
real-project integration target. The focus is API clarity, performance headroom,
diagnostics, and release discipline.

## Highlights

* `OZChart` fluent API for common chart construction.
* `OZChart` assigns deterministic default series ids across SwiftUI rebuilds.
* `OZChart` exposes selection callbacks plus viewport and selection state bindings.
* Option structs for stable, grouped configuration:
  * `ChartInteractionOptions`
  * `ChartSelectionOptions`
  * `ChartTooltipOptions`
  * `ChartViewportOptions`
  * `ChartRenderOptions`
* Render contexts are now separated from full interaction contexts.
* Dense hit-testing avoids avoidable extra passes and sort work.
* Point hit-testing uses a lazy cached x-index for dense interactive datasets.
* `ChartDiagnostics` can be consumed directly or through `.chartDiagnostics`.
* CI covers SwiftPM tests, SwiftLint, DemoApp build, and manual benchmarks.
* API stability policy is documented for 2.x adoption.

## Fluent API Example

```swift
OZChart(samples)
    .line(color: .blue, downsampling: .automatic())
    .selection(.nearestX)
    .domain(y: .auto(padding: 0.12, includeZero: true))
    .tooltip { points in
        if let point = points.first {
            Text("\(Int(point.originalPoint.y))")
                .padding(8)
                .background(.black.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    .frame(height: 300)
```

The existing `CartesianChartView` API remains supported for advanced charts,
multiple series, custom scales, and product-specific composition.

## Migration

No migration is required from 2.1-style code. Existing initializers and modifiers
continue to work.

Adopt the new API incrementally:

* use option structs when a chart has many interaction or rendering settings;
* use `OZChart` for straightforward single-dataset charts;
* bind `OZChart` to `ChartViewportState` or `ChartSelectionState` when a product screen needs external controls or linked charts;
* use `.chartDiagnostics` in integration tests or debug screens;
* keep `CartesianChartView` for highly customized product charts.

## Verification

Before tagging 2.5:

```bash
swift test
swiftlint lint --no-cache
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

## Remaining 2.x Opportunities

* Add a two-dimensional spatial grid only if product charts exceed hundreds of
  thousands of visible interactive points with radius-heavy selection.
* Add pixel/perceptual screenshot baselines for final product charts.
* Expand accessibility navigation beyond summary and selected-value text.
* Run a broad SwiftFormat-only cleanup as a separate mechanical change.
