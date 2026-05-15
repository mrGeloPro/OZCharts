# Live Charts

Live charts should let data continue arriving without fighting the user. OZCharts separates the full data domain from the visible viewport so a chart can show a small window inside a larger history range.

## Follow Latest

```swift
@State private var viewport = ChartViewportState.automatic

CartesianChartView(
    series: [
        LineSeries(
            data: samples,
            id: signalSeriesID,
            color: .cyan,
            downsampling: .automatic(maxPointsPerPixel: 1)
        )
    ],
    xDomain: .fixed(historyStart...latestTimestamp),
    yDomain: .fixed(0...100)
) { _ in
    EmptyView()
}
.chartInitialViewport(xWindow: 60 * 60, anchor: .trailing)
.chartLiveTracking(
    .followLatest(
        pauseOnUserInteraction: true,
        pausedBehavior: .freezeVisibleWindow
    )
)
.chartViewport($viewport)
```

When the user is at the right edge, the visible window follows new data. When the user scrolls back, OZCharts pauses follow mode and preserves the visible range.

## Delayed Live Window

Use `.preserveTrailingOffset` when a user scrolls back but still wants a moving delayed window.

```swift
.chartLiveTracking(
    .followLatest(
        pauseOnUserInteraction: true,
        pausedBehavior: .preserveTrailingOffset
    )
)
```

This keeps the same delay from the latest timestamp while new events arrive.

## Return to Latest

```swift
Button("Live") {
    viewport.requestJumpToLatest()
}
```

Use `viewport.liveTrackingStatus` to show whether the user is viewing live data or history.

## Trimming History

Keep the chart's fixed domain aligned with the retained history window. When old points are trimmed, keep the visible range clamped to the new full domain. OZCharts handles the viewport math; the app owns the retention policy.
