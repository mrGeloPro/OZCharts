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

Use fluent `stackedBar` with grouped points. Each row is a category, each
group is a milestone segment, and `StackedBarRemainderStyle` can draw a
non-legend background segment up to a row target.

```swift
OZChart(rows)
    .stackedBar(
        stackOrder: [.star1, .star2, .star3],
        colorMapper: palette.color,
        fillStyleMapper: palette.fill,
        rowLabel: { row in title(for: row) },
        rowEndLabel: { row, _ in scoreText(for: row) },
        layout: .achievement(
            leftAxisWidth: 92,
            rightAxisWidth: 58,
            rowLabelLineLimit: 2,
            barHeight: 20
        ),
        remainder: .achievementTarget(90),
        separatorStyle: StackedBarSeparatorStyle(color: .black, width: 2),
        interactionOptions: .achievement
    )
    .presentation(.productCard(selection: .persistentElement))
    .tooltipOptions(.hitPoint())
    .elementTooltipContext { context in
        ChartCallout(context: context, style: .productLight) {
            AchievementTooltip(elements: context.elements)
        }
    }
    .legend(.bottom)
```

Closure-driven remainder targets require a stable `signature` so SwiftUI
refreshes the stacked bar layout at the right time when external target data
changes.

For lower-level selected-row callouts, `ChartSelection.primaryAnchor` and
`ChartSelectedElement` include screen `position`, `interactionPosition`,
`bounds`, `rowLabel`, `rowIndex`, and `totalValue`. Use
`ChartAnchoredCalloutLayout.vertical` when a custom overlay needs its own arrow
geometry.

```swift
let layout = ChartAnchoredCalloutLayout.vertical(
    anchor: element.interactionPosition ?? element.position,
    calloutSize: CGSize(width: 220, height: 118),
    containerSize: canvasSize,
    preferredSide: .below
)
```

## Pixel-perfect Axis Labels

Use `labelInsets` for internal padding around each label and
`labelReservedSize` when Figma reserves a fixed label slot.

```swift
YAxisConfig(
    position: .leading,
    showTicks: false,
    explicitValues: [0, 25, 50, 75, 100],
    width: 76,
    labelSpacing: 12,
    labelInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8),
    labelReservedSize: CGSize(width: 56, height: 20),
    labelAlignment: .trailing
)
```

`labelSpacing` applies even when ticks are hidden, so designs can hide tick
marks without labels sticking to the plot area.

Use `contentInsets` to move the complete axes+plot block inside a card, and
`plotInsets` only when the marks need extra breathing room inside the plot
frame.

## Donut Score

Use ``OZDonutChart`` with `gapAngle`, `lineCap`, `thickness`, and
per-segment `DonutSegmentStyle` values to match product art direction without
declaring cartesian domains at the call site. Donut segment geometry is resolved
by the polar layout engine shared by rendering, hit-testing, and selected
segment overlays.

```swift
OZDonutChart(
    scoreShare,
    colors: [.cyan, .purple, .yellow],
    segmentStyles: [
        DonutSegmentStyle(fill: .gradient([.cyan, .mint])),
        DonutSegmentStyle(fill: .gradient([.purple, .pink]), explodedOffset: 10),
        DonutSegmentStyle(fill: .gradient([.yellow, .orange]), explodedOffset: 14)
    ],
    thickness: 42,
    gapAngle: .degrees(7),
    lineCap: .round
) {
    Text("82%")
}
.selection(.transientElement)
.onSegmentSelection { segment in
    pressedSegment = segment
}
```

Use `.persistentElement` instead when a tap should keep the segment selected
after the finger lifts, for example when a dashboard opens a detail panel.

## Stacked Points Distribution

Use fluent ``OZChart/stackedArea(id:stackOrder:colorMapper:fillStyleMapper:groupLabel:interpolation:lineWidth:fillOpacity:shadow:animation:zIndex:)`` with `.step` interpolation when data represents accumulated incremental events. This keeps each event step visible and avoids implying continuous change where the product has discrete scoring moments.
