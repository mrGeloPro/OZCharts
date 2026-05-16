# Selection And Annotations

OZCharts 3.0 uses one selection payload across point, bar, stacked bar, donut,
and annotation layers.

## Unified Selection

Prefer the unified callback for new product screens:

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

For low-level charts, use the matching modifier:

```swift
.chartSelectionChanged { selection in
    detailState = selection.state
}
```

`ChartSelection` carries `points`, `elements`, `annotations`, and a stable
`ChartSelectionState` for linked charts. The older point and element callbacks
remain available during the 3.0 transition, but new product code should use the
unified payload.

## Point Selection

```swift
.chartSelection(.nearestX, behavior: .tapAndDrag, hitboxRadius: 28)
.chartSelectionState($sharedSelection)
.chartCrosshair(.vertical())
.chartTooltipPlacement(.automatic, padding: 12)
.chartTooltipMaxWidth(220)
```

Use `ChartSelectionState` to link charts or drive an external detail panel.

## Element Selection

Bars, stacked bar segments, and donut segments expose `ChartSelectedElement` payloads. The payload includes stable ids, values, labels, series metadata, bounds, element-center `position`, and gesture `interactionPosition` when selection comes from direct interaction.

```swift
.chartSelectionChanged { selection in
    guard let selected = selection.primaryElement else { return }
    print(selected.kind, selected.label ?? "", selected.value ?? 0)
}
```

## Domain Annotations

```swift
RangeAnnotation(
    yRange: 70...180,
    label: "Target",
    color: .green,
    labelXPosition: .trailing
)

XRangeAnnotation(
    xRange: 7...9,
    label: "Sleep window",
    color: .gray
)

VerticalAnnotation(
    xValue: 9.5,
    label: "Now",
    color: .yellow
)

XYRangeAnnotation(
    xRange: 8...9,
    yRange: 250...400,
    label: "Risk window",
    color: .yellow,
    opacity: 0.08
)

ChartEventMarker(
    x: 12.5,
    y: 145,
    label: "Insulin 4U",
    shape: .diamond,
    color: .orange
)
```

Use range annotations for shaded context, x-range annotations for time windows, xy-range annotations for bounded plot regions, vertical annotations for full-height x markers, horizontal annotations for y thresholds, and event markers for selectable point-level domain events.

Range labels and custom annotation callouts use collision-aware placement and tooltip clamping so text does not escape the plot area.

## Product Callouts

Use built-in tooltip placement presets for common product patterns:

```swift
.chartTooltipPlacement(.trailing, padding: 12)
.chartTooltipMaxWidth(260)
```

Use custom SwiftUI annotations when the callout needs a branded layout, icons, or rich detail content.
