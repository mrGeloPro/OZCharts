# Selection And Annotations

OZCharts uses one interaction model across point, bar, stacked bar, donut, and annotation layers.

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

Bars, stacked bar segments, and donut segments expose `ChartSelectedElement` payloads. The payload includes stable ids, values, labels, series metadata, bounds, and display position.

```swift
.chartElementSelection { elements in
    guard let selected = elements.first else { return }
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

ChartEventMarker(
    x: 12.5,
    y: 145,
    label: "Insulin 4U",
    shape: .diamond,
    color: .orange
)
```

Annotations use collision-aware placement and tooltip clamping so labels do not escape the plot area.

## Product Callouts

Use built-in tooltip placement presets for common product patterns:

```swift
.chartTooltipPlacement(.trailing, padding: 12)
.chartTooltipMaxWidth(260)
```

Use custom SwiftUI annotations when the callout needs a branded layout, icons, or rich detail content.
