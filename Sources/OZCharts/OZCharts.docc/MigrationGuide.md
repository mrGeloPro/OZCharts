# Migration Guide

Use this guide when moving 2.x product screens to the 3.0 API shape.

## Selection

Prefer one callback for all selected content:

```swift
OZChart(samples)
    .line(color: .cyan)
    .selection(.nearestX)
    .onSelection { selection in
        selectedPoint = selection.primaryPoint?.originalPoint
        selectedElement = selection.primaryElement
        selectedAnnotation = selection.primaryAnnotation
    }
```

For low-level charts:

```swift
CartesianChartView(...)
    .chartSelectionChanged { selection in
        detailState = selection.state
    }
```

`onSelectionChanged` and `onElementSelectionChanged` are still available for
incremental migration, but new screens should use the unified selection payload.

## Advanced Series

Prefer fluent `OZChart` helpers for advanced series:

```swift
OZChart(rows)
    .stackedBar(
        stackOrder: groups,
        colorMapper: palette.color,
        rowLabel: rowLabel(for:)
    )
    .legend(.dashboard(position: .bottom, itemLimit: 4))
```

Use `CartesianChartView` as the low-level escape hatch for custom scales,
custom series composition, or integration points that cannot be expressed by
the fluent API.

## Donut Charts

Use `OZDonutChart` when a donut is the whole chart:

```swift
OZDonutChart(slices, colors: colors, label: "Score") {
    Text("82%")
}
```

Apps no longer need to provide fake cartesian domains for donut-only cards.

## Dashboard Presets

Start with presentation presets and adjust only what the screen needs:

```swift
OZChart(samples)
    .line(color: .cyan, label: "Current")
    .presentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))
    .legend(.compact(position: .bottom, itemLimit: 3))
```

Axis placement remains explicit through presets and direct axis configuration.
