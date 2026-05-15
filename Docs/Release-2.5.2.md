# OZCharts 2.5.2 Release Notes

OZCharts 2.5.2 is a focused patch release that expands annotation coverage and
adds a real-world CGM demo scenario for timeline-style health charts.

## Highlights

* Added `XRangeAnnotation` for full-height x-domain windows.
* Added `XYRangeAnnotation` for bounded plot-area regions.
* Added `VerticalAnnotation` for full-height x markers.
* Extended `CartesianChartView`, convenience initializers, and
  `OZChart.annotations(...)` to accept the expanded annotation set.
* Preserved `CanvasLayer` source compatibility by rendering new annotation
  types through existing range and horizontal annotation layers.
* Added a CGM Night Trend demo with top-baseline pump activity bars, target
  bands, threshold lines, time-window shading, fixed top/right axes, and
  deterministic time labels.
* Extended DemoApp JSON scenarios with axis placement, explicit x ticks, fixed
  time zones, reference lines, top-baseline bars, and presentation flags.

## Migration

No migration is required from 2.5.1. Existing chart initializers, modifiers, and
canvas render orders continue to work.

Adopt the new annotations incrementally:

```swift
CartesianChartView(
    series: series,
    xRangeAnnotations: [
        XRangeAnnotation(xRange: start...end, color: .gray, opacity: 0.16)
    ],
    xyRangeAnnotations: [
        XYRangeAnnotation(xRange: riskStart...riskEnd, yRange: 250...400, color: .yellow, opacity: 0.08)
    ],
    verticalAnnotations: [
        VerticalAnnotation(xValue: now, label: "Now", color: .yellow, lineWidth: 1.2, dash: [3, 4])
    ]
) { points in
    Tooltip(points: points)
}
```

## Verification

The release was verified with:

```bash
swift test
swiftlint lint --no-cache
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

The performance baseline remains in `Docs/PerformanceBenchmarks.md`.
