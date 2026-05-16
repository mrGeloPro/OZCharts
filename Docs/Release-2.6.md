# OZCharts 2.6 Release Notes

OZCharts 2.6 focuses on API polish for production dashboard charts. The main
goal is to make advanced product series feel as natural as the existing fluent
line, area, bar, and scatter helpers.

## Highlights

* `OZChart.donut(...)`, `.stackedArea(...)`, `.stackedBar(...)`, and `.violin(...)`
  bring advanced series into the fluent API.
* `OZDonutChart` provides a dedicated donut wrapper with center content,
  dashboard defaults, legend support, and element selection without fake
  cartesian domains in app code.
* `OZChart.legend(...)`, `.staticChart()`, `.hiddenAxes()`, and
  `.compactAxes(...)` reduce boilerplate for static dashboard cards.
* `ChartRenderOptions.dashboard(...)`, `ChartTheme.dashboard`, and compact axis
  presets provide reusable mobile-dashboard defaults.
* `OZChart.stackedBar(... rowLabel:)` maps row values to y-axis labels without
  manual axis wiring.
* Element selection now honors overlapping selection behavior, so stacked bars,
  donut segments, bars, and other element marks can return all overlapping
  elements or cycle through them consistently with point selection.

## Migration Notes

Existing `CartesianChartView` and `AnyChartSeries` code remains valid. The new
helpers are additive and are intended as the preferred entry point for common
dashboard/result-screen charts.

Before:

```swift
CartesianChartView(
    series: [
        StackedBarSeries(
            data: rows,
            stackOrder: [.done, .missed, .remaining],
            colorMapper: palette.color
        )
    ],
    xDomain: .fixed(0...100),
    yDomain: .fixed(0...4),
    yAxes: [
        YAxisConfig(
            explicitValues: [1, 2, 3],
            labelFormatter: { rowLabel(for: $0) }
        )
    ]
) { _ in EmptyView() }
```

After:

```swift
OZChart(rows)
    .stackedBar(
        stackOrder: [.done, .missed, .remaining],
        colorMapper: palette.color,
        rowLabel: { rowLabel(for: $0) }
    )
    .domain(x: .fixed(0...100), y: .fixed(0...4))
    .legend(.bottom)
    .staticChart()
```

For donut-only dashboard cards, prefer:

```swift
OZDonutChart(scoreShare, colors: [.cyan, .purple, .orange], label: "Score") {
    Text("82%")
}
.selection { segments in
    selectedSegment = segments.first
}
```

## Verification

Run before cutting the release:

```bash
swift test
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```
