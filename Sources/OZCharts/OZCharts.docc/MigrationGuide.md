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

Dismissal is now configured with `dismissalPolicy` instead of the older
`clearsSelectionOnGestureEnd` flag:

```swift
OZChart(samples)
    .selection(.nearestX)
    .selectionDismissal(.persistent)
```

For low-level charts, pass `selectionDismissalPolicy` to `CartesianChartView`
or use `.chartSelectionDismissalPolicy(_:)`.

## Tooltip Anchors

Tooltip anchoring now uses four canonical names:

- `.selectedValue` for point-value tooltips.
- `.tapLocation` for gesture-centered overlays.
- `.elementCenter` for stable element-centered labels.
- `.hitPoint` for arrows that should point to the exact tap inside a bar,
  segment, or marker.

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
.selection(.persistentElement)
.onSegmentSelection { segment in
    selectedSegment = segment
}
```

Apps no longer need to provide fake cartesian domains for donut-only cards.

Use `.transientElement` when the highlight should exist only while the user is
pressing. This is the default for `OZDonutChart`.

## Tap Priority

If a product chart mixes event markers, bars, donut segments, and line points,
configure selection priority explicitly:

```swift
OZChart(samples)
    .line(color: .cyan)
    .annotations(events: events)
    .selection(.eventOnly)
    .annotationSelection(fallbackToPointSelection: false)
    .selectionPriority(.annotationsOnly)
    .tooltipAnchor(.tapLocation)
```

Use `.eventThenNearestPoint` or `.nearestX` when empty chart areas should still
resolve to the nearest point. Use `.scrollSafeNearestX` when scrollable
dashboards should ignore distant nearest values and wait for a completed tap.
Use `.chartEmptyTap` when empty areas should clear external UI instead of
selecting nearby data.

## Dashboard Presets

Start with presentation presets and adjust only what the screen needs:

```swift
OZChart(samples)
    .line(color: .cyan, label: "Current")
    .presentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))
    .legend(.compact(position: .bottom, itemLimit: 3))
```

Axis placement remains explicit through presets and direct axis configuration.
