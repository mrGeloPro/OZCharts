# OZCharts 3.0 Migration Guide

OZCharts 3.0 makes the fluent product API the recommended path for dashboard,
result, and event-timeline charts. Low-level `CartesianChartView` composition
remains available when an app needs custom scales, custom series composition,
or direct control over chart internals.

## Selection Callbacks

Use one unified selection callback for new code. It carries point selections,
element selections, annotations, and the shared `ChartSelectionState`.

Before:

```swift
OZChart(samples)
    .line(color: .cyan)
    .onSelectionChanged { points in
        selectedPoint = points.first?.originalPoint
    }
    .onElementSelectionChanged { elements in
        selectedElement = elements.first
    }
```

After:

```swift
OZChart(samples)
    .line(color: .cyan)
    .onSelection { selection in
        selectedPoint = selection.primaryPoint?.originalPoint
        selectedElement = selection.primaryElement
        selectedAnnotation = selection.primaryAnnotation
    }
```

For low-level charts, replace dedicated element callbacks with
`.chartSelectionChanged`:

```swift
CartesianChartView(...)
    .chartSelectionChanged { selection in
        selectedElement = selection.primaryElement
    }
```

Keep `.chartSelection(...)` for configuring the selection mode, behavior,
hitbox radius, and overlap behavior. Prefer `.chartSelectionChanged` for the
selection payload itself.

## Advanced Series

Prefer `OZChart` fluent helpers for advanced product series.

Before:

```swift
CartesianChartView(
    series: [
        StackedAreaSeries(
            data: samples,
            stackOrder: categories,
            colorMapper: palette.color
        )
    ],
    xDomain: .automatic,
    yDomain: .automatic
) { _ in EmptyView() }
```

After:

```swift
OZChart(samples)
    .stackedArea(
        stackOrder: categories,
        colorMapper: palette.color,
        groupLabel: label(for:)
    )
```

The same preferred path exists for `.donut(...)`, `.stackedBar(...)`, and
`.violin(...)`. Use `CartesianChartView` when the chart truly needs a custom
low-level composition.

## Donut Charts

Use `OZDonutChart` for donut-only cards. App code no longer needs fake
cartesian domains for donut presentation.

Before:

```swift
CartesianChartView(
    series: [DonutSeries(data: slices, colors: colors, label: "Score")],
    xDomain: .fixed(0...1),
    yDomain: .fixed(0...1)
) { _ in EmptyView() }
```

After:

```swift
OZDonutChart(slices, colors: colors, label: "Score") {
    Text("82%")
}
.selection { segments in
    selectedSegment = segments.first
}
.onSelection { selection in
    selectedSegment = selection.primaryElement
}
```

## Stacked Bar Rows

Use `rowLabel` instead of manually mapping y-axis values.

Before:

```swift
CartesianChartView(
    series: [
        StackedBarSeries(
            data: rows,
            stackOrder: groups,
            colorMapper: palette.color
        )
    ],
    xDomain: .fixed(0...100),
    yDomain: .fixed(0...4),
    yAxes: [
        YAxisConfig(explicitValues: [0, 1, 2, 3]) { value in
            label(forRow: Int(value))
        }
    ]
) { _ in EmptyView() }
```

After:

```swift
OZChart(rows)
    .stackedBar(
        stackOrder: groups,
        colorMapper: palette.color,
        rowLabel: { label(forRow: Int($0)) }
    )
    .domain(x: .fixed(0...100), y: .fixed(0...4))
```

## Presets And Legends

Use presentation and legend option presets for dashboard cards before dropping
to manual modifier chains.

```swift
OZChart(samples)
    .line(color: .cyan, label: "Current")
    .line(color: .orange, label: "Target")
    .presentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))
    .legend(.dashboard(position: .bottom, itemLimit: 4))
```

Manual axis placement is still supported through presets and direct axis
configuration. Top/bottom x-axes and leading/trailing y-axes remain explicit
API, not hidden theme behavior.

## Temporary Compatibility

The 2.x selection callbacks remain available during the 3.0 transition, but
new code should use `.onSelection` or `.chartSelectionChanged`. Deprecated
callbacks will continue to compile with migration messages so product apps can
move screen by screen.
