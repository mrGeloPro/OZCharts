# Product Charts

Product-style charts usually need tighter control than default analytics views. OZCharts provides reusable primitives for the chart types shown in the demo app.

## Violin Distribution With Secondary Axis

Use a violin series for distribution density, scatter points for samples, a target range or line for a product goal, and `AxisTransform` for derived axis values.

```swift
YAxisConfig(
    position: .trailing,
    explicitValues: [330, 400, 500, 600, 700, 800, 900],
    axisTransform: AxisTransform { delta in
        Int(delta.rounded()) == 330 ? 200 : 60_000 / delta
    },
    labelFormatter: { "\(Int($0))" },
    title: "Rhythm (bpm)"
)
```

## Stacked Achievement Times

Use `StackedBarSeries` with grouped points. Each row is a category, each group is a milestone segment, and striped fills can represent unavailable or remaining time.

```swift
StackedBarSeries(
    data: rows,
    stackOrder: [.star1, .star2, .star3, .remainder],
    colorMapper: palette.color,
    fillStyleMapper: palette.fill,
    valueLabelStyle: ChartValueLabelStyle(position: .outside)
)
```

For selected-row callouts, use `ChartAnchoredCalloutLayout.vertical` to keep the
pointer attached to the tap while the callout card clamps into readable space.
This is useful when the user taps near the chart edge or near the first/last
row.

```swift
let layout = ChartAnchoredCalloutLayout.vertical(
    anchor: element.interactionPosition ?? element.position,
    calloutSize: CGSize(width: 220, height: 118),
    containerSize: canvasSize,
    preferredSide: .below
)
```

## Donut Score

Use `DonutSeries` with `gapAngle`, `lineCap`, `thickness`, and per-segment `DonutSegmentStyle` values to match product art direction.

```swift
DonutSeries(
    data: scoreShare,
    colors: [.cyan, .purple, .yellow],
    segmentStyles: [
        DonutSegmentStyle(fill: .gradient([.cyan, .mint])),
        DonutSegmentStyle(fill: .gradient([.purple, .pink]), explodedOffset: 10),
        DonutSegmentStyle(fill: .gradient([.yellow, .orange]), explodedOffset: 14)
    ],
    thickness: 42,
    gapAngle: .degrees(7),
    lineCap: .round
)
```

## Stacked Points Distribution

Use `StackedAreaSeries` with `.step` interpolation when data represents accumulated incremental events. This keeps each event step visible and avoids implying continuous change where the product has discrete scoring moments.
