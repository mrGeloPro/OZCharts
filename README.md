# OZCharts

A high-performance, fully customizable, and mathematically precise charting framework for SwiftUI. Built for developers who need more flexibility than standard solutions provide.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![CI](https://github.com/mrGeloPro/OZCharts/actions/workflows/ci.yml/badge.svg)](https://github.com/mrGeloPro/OZCharts/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

* **Versatile chart types:** Line, area, vertical bar, scatter, stacked horizontal bar, donut, and mathematically accurate violin charts.
* **Canvas-first rendering:** Smooth interaction with off-screen culling and synchronous gesture layouts.
* **Two API levels:** Use `OZChart` for fluent line, area, bar, scatter, donut, stacked, and violin charts, or `CartesianChartView` for fully custom composition.
* **Advanced gestures:** Independent horizontal and vertical scrolling/zooming with conflict handling between pan and pinch.
* **Hybrid layering:** Combine Canvas-rendered series with collision-aware SwiftUI custom annotations.
* **Auto domains and presets:** Start quickly with `.auto(...)`, nice ticks, collision-aware labels, `ChartTheme`, and axis presets.
* **Interaction toolkit:** Selection modes, centralized hit-testing, selected-element overlays, crosshair, selection behavior, and live tracking.
* **Production helpers:** Legend, accessibility descriptors, range annotations, event markers, LTTB downsampling, log/time/category scales, input diagnostics, and smoke-tested rendering contracts.

## Installation (Swift Package Manager)

Add `OZCharts` to your project via Xcode:
1. `File` > `Add Package Dependencies...`
2. Enter the repository URL: `https://github.com/mrGeloPro/OZCharts.git`
3. Choose the version rule (e.g., "Up to Next Major").

## Quick Start

```swift
import SwiftUI
import OZCharts

struct ContentView: View {
    let data = [
        Point2D(x: 0, y: 120),
        Point2D(x: 1, y: 160),
        Point2D(x: 2, y: 90),
        Point2D(x: 3, y: 210)
    ]
    
    var body: some View {
        OZChart(data, theme: .light)
            .line(color: .blue, lineWidth: 3)
            .domain(
                x: .auto(padding: 0.05),
                y: .auto(padding: 0.12, includeZero: true)
            )
            .axes(x: [.time(suffix: "s")])
            .selection(.nearestX)
            .tooltip { points in
                if let point = points.first {
                    Text("Value: \(Int(point.originalPoint.y))")
                        .padding(8)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(height: 300)
    }
}
```

## Fluent API

For most dashboard and result-screen charts, start with `OZChart`:

```swift
OZChart(data)
    .line(color: .blue, lineWidth: 3, downsampling: .automatic())
    .selection(.nearestX)
    .onSelection { selection in
        selectedValue = selection.primaryPoint?.originalPoint.y
    }
    .domain(y: .auto(padding: 0.12, includeZero: true))
    .tooltip { points in
        if let point = points.first {
            Text("Value: \(Int(point.originalPoint.y))")
                .padding(8)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    .frame(height: 300)
```

Advanced product series are available through the same fluent style:

```swift
OZChart(groupedRows)
    .stackedBar(
        stackOrder: [.completed, .missed, .remaining],
        colorMapper: palette.color,
        rowLabel: { row in dayLabel(for: row) }
    )
    .compactAxes(xPosition: .top, yPosition: .leading)
    .legend(.bottom)
    .staticChart()
```

For score rings that should not expose cartesian domains at the call site, use
`OZDonutChart`:

```swift
OZDonutChart(scoreShare, colors: [.cyan, .purple, .orange], label: "Score") {
    Text("82%")
        .font(.title.bold())
}
.selection(.persistentElement)
.onSelection { selection in
    selectedSegment = selection.primaryElement
}
.frame(height: 220)
```

Use `CartesianChartView` directly only when a screen needs fully custom
multi-series composition, custom scale objects, or specialized overlays.

## Common Patterns

For product integration, start with the [Integration Guide](Docs/IntegrationGuide.md).
For recreating polished product charts, use [Product Chart Recipes](Docs/ProductCharts.md).
For external-team onboarding, use the [Handoff Guide](Docs/HandoffGuide.md).
For handoff readiness, use the [Delivery Checklist](Docs/DeliveryChecklist.md).
For prerelease scope, see [OZCharts 2.1 Prerelease Notes](Docs/Release-2.1.md).
For the 2.5 release, see [OZCharts 2.5 Release Notes](Docs/Release-2.5.md).
For the 2.5.2 patch, see [OZCharts 2.5.2 Release Notes](Docs/Release-2.5.2.md).
For the 2.6 release plan, see [OZCharts 2.6 Release Notes](Docs/Release-2.6.md).
For the 3.0 release plan, see [OZCharts 3.0 Release Notes](Docs/Release-3.0.md).
For the 3.0 migration path, see the [OZCharts 3.0 Migration Guide](Docs/Migration-3.0.md).
For API compatibility expectations, see [OZCharts 2.5 API Stability Policy](Docs/APIStability-2.5.md).
For migration details, see the [OZCharts 2.1 Migration Guide](Docs/Migration-2.1.md).
For performance expectations, see [Performance Benchmarks](Docs/PerformanceBenchmarks.md).
For manual demo validation, see [DemoApp QA Guide](Docs/DemoAppQA.md).
For architectural risks and priorities, see the [Framework Review](Docs/FrameworkReview.md).

### Explicit Domains

Use fixed domains when the visual range is part of the product design:

```swift
CartesianChartView(
    series: [LineSeries(data: data, color: .cyan)],
    xDomain: .fixed(0...10),
    yDomain: .fixed(0...250),
    theme: .dark
) { _ in EmptyView() }
```

### Axis Presets

```swift
let xAxis = XAxisConfig.time(tickCount: 6, suffix: "s")
let yAxis = YAxisConfig.percent(fractionValues: true)
let hiddenAxis = XAxisConfig.hidden()
let cleanAxis = XAxisConfig(
    tickStrategy: .nice,
    labelCollisionStrategy: .hideOverlapping(minSpacing: 44),
    labelInsets: EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6),
    tickCount: 6
)
```

`labelSpacing` controls the label's distance from the axis/plot edge even when
`showTicks` is `false`; visible ticks add their own `tickLength` before that gap.
Use `labelInsets` for extra padding around the label content itself when a
pixel-perfect layout needs more room without changing tick geometry.

Use `LineSeriesStyle` when the same chart family sometimes needs a fill and
sometimes should render as a plain line:

```swift
let style = LineSeriesStyle(
    color: .cyan,
    lineWidth: 3,
    interpolation: .monotone,
    showsFill: showsArea,
    fillOpacity: 0.18
)

OZChart(samples)
    .line(style: style, label: "Height")
```

Use a plot border when a chart needs a true frame around the plot area. This is
drawn on the canvas boundary, so the corners join cleanly without adding a
separate top axis or annotation line:

```swift
OZChart(points)
    .line(color: .blue)
    .plotBorder(edges: .all, color: .white.opacity(0.35), lineWidth: 1)
```

Use `axisTransform` when chart geometry should stay in the source domain, but an axis should display derived units. This is useful for secondary axes such as ΔT in milliseconds on the left and rhythm in bpm on the right:

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

### Custom Annotations

```swift
CartesianChartView(
    series: [LineSeries(data: data, color: .blue)],
    xDomain: .auto(),
    yDomain: .auto(),
    xRangeAnnotations: [
        XRangeAnnotation(xRange: 1.0...2.0, label: "Sleep", color: .gray)
    ],
    xyRangeAnnotations: [
        XYRangeAnnotation(xRange: 2.0...3.0, yRange: 250...400, label: "Risk", color: .yellow)
    ],
    rangeAnnotations: [
        RangeAnnotation(yRange: 70...180, label: "Target range", color: .green)
    ],
    verticalAnnotations: [
        VerticalAnnotation(xValue: 3.2, label: "Now", color: .yellow)
    ],
    eventMarkers: [
        ChartEventMarker(
            x: 2.4,
            y: 145,
            label: "Insulin 4U",
            shape: .diamond,
            color: .orange
        )
    ],
    pointAnnotations: [
        PointAnnotation(
            x: 2,
            y: 90,
            label: "Milestone",
            shape: .star,
            color: .yellow,
            isSelectable: true
        )
    ],
    customViewAnnotations: [
        CustomViewAnnotation(
            x: 3,
            y: 210,
            label: "Peak",
            isSelectable: true
        ) {
            Text("Peak")
                .font(.caption.bold())
                .foregroundColor(.yellow)
        }
    ]
) { _ in EmptyView() }
```

Use `RangeAnnotation` for Y target bands such as glucose, heart-rate zones, latency SLOs, or portfolio guardrails. Use `XRangeAnnotation` for time windows, `VerticalAnnotation` for event thresholds, and `XYRangeAnnotation` for bounded plot regions such as high-risk windows. Use `ChartEventMarker` when the app has domain events and wants selectable chart markers without manually building `PointAnnotation` values.

Range labels can be nudged away from dense data with `labelXPosition`, `labelAnchor`, and `labelYOffset`.

Selectable annotations can show their own detail overlay without replacing the data-point tooltip:

```swift
.chartAnnotationSelection(hitboxRadius: 28, overlapping: .cycle)
.chartAnnotationTooltip { annotations in
    VStack(alignment: .leading) {
        ForEach(annotations) { annotation in
            Text(annotation.label ?? "Event")
        }
    }
    .padding(8)
    .background(Color.black.opacity(0.8))
    .foregroundColor(.white)
    .cornerRadius(8)
}
```

### Selection Modes

Use `selectionMode` when you want predictable tooltip behavior:

```swift
OZChart(current)
    .line(color: .blue, label: "Current")
    .line(color: .green, label: "Previous")
    .selection(.nearestX)
    .onSelection { selection in
        print(selection.points.map(\.originalPoint.y))
    }
    .tooltip { points in
        VStack(alignment: .leading) {
            ForEach(points, id: \.id) { point in
                Text("\(Int(point.originalPoint.y))")
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    .rendering(.dashboard())
```

Available modes:

* `.pointsInRadius` selects every point inside `hitboxRadius`.
* `.nearestPoint` selects the closest point.
* `.nearestX` selects all points sharing the nearest x-value.
* `.none` disables selection and tooltips.

For scrollable dashboard charts, prefer `.scrollSafeNearestX`. It waits for a
completed tap and limits nearest selection to the hitbox, so a scroll gesture
does not briefly show a distant tooltip.

### Crosshair

Enable a built-in crosshair when selected points should be visually anchored to the plot:

```swift
CartesianChartView(
    series: [LineSeries(data: data, color: .blue)],
    xDomain: .auto(),
    yDomain: .auto(),
    selectionMode: .nearestX,
    crosshairStyle: .vertical(color: .blue.opacity(0.6))
) { points in
    EmptyView()
}
```

Available styles are `.vertical()`, `.horizontal()`, `.both()`, and `.hidden`.

### SwiftUI Modifiers

Most interaction options can be configured with modifiers when that reads better than a long initializer:

```swift
CartesianChartView(
    series: [LineSeries(data: data, color: .blue)],
    xDomain: .auto(),
    yDomain: .auto()
) { points in
    EmptyView()
}
.chartSelection(.nearestX, hitboxRadius: 28)
.chartCrosshair(.vertical())
.chartGestures(horizontalScroll: true, verticalZoom: false)
.chartInitialViewport(x: 0...8)
.chartZoomControls()
.chartTooltipOffset(x: 0, y: -24)
```

Use an initial viewport when the full domain should stay scrollable, but the first render should start zoomed into a smaller window:

```swift
// Full chart domain can be 0...24, while the first screen shows 8 hours.
.chartInitialViewport(xWindow: 8, anchor: .leading)

// For live charts, start from the newest visible window.
.chartInitialViewport(xWindow: 8, anchor: .trailing)
```

Bind the viewport when external UI should control or observe zoom and pan:

```swift
@State private var viewport = ChartViewportState(visibleXDomain: 0...8)

CartesianChartView(
    series: [LineSeries(data: data, color: .blue)],
    xDomain: .fixed(0...24),
    yDomain: .auto()
) { _ in
    EmptyView()
}
.chartViewport($viewport)
.chartZoomControls(step: 2)
```

For live charts, keep the full data range wider than the visible window and
let OZCharts pause follow mode when the user scrolls back into history:

```swift
@State private var viewport = ChartViewportState.automatic

CartesianChartView(
    series: [LineSeries(data: samples, id: signalSeriesID, color: .cyan)],
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

Button("Live") {
    viewport.requestJumpToLatest()
}
```

`viewport.liveTrackingStatus` reports whether the chart is following latest
data or paused because the user is viewing history.

Use `.freezeVisibleWindow` when history should stay completely stable while the
user inspects it. Use `.preserveTrailingOffset` when the user should keep the
same delay from live data and continue seeing a moving delayed window.

Share selection state when multiple charts should move together:

```swift
@State private var sharedSelection = ChartSelectionState.none

VStack {
    priceChart
        .chartSelectionOptions(.scrollSafeNearestX)
        .chartSelectionState($sharedSelection)
        .chartCrosshair(.vertical())

    volumeChart
        .chartSelectionOptions(.scrollSafeNearestX)
        .chartSelectionState($sharedSelection)
        .chartCrosshair(.vertical())
}
```

For overlapping points, cycle one selected item at a time and keep the details visible after tap:

```swift
.chartSelection(
    .pointsInRadius,
    behavior: .tap,
    overlapping: .cycle,
    hitboxRadius: 24,
    dismissalPolicy: .persistent
)
.chartTooltipPlacement(.automatic, padding: 12)
.chartTooltipMaxWidth(220)
```

Tooltip placements: `.automatic`, `.top`, `.bottom`, `.leading`, `.trailing`, `.center`, `.fixed(CGPoint)`.
`ChartSelectionState` keeps the old `selectedX` behavior for linked crosshair charts and also exposes `selectedPoints` with stable point ids, series ids, series indices, and domain values for richer product interactions.

Non-point charts publish selected visual elements through the unified selection
payload:

```swift
.chartSelectionChanged { selection in
    guard let element = selection.primaryElement else { return }
    print(element.kind, element.label ?? "", element.value ?? 0)
}
```

`ChartSelectedElement` is used by bars, stacked bar segments, and donut
segments. It includes stable ids, series metadata, `bounds`, element-center
`position`, gesture `interactionPosition`, domain values, labels, and the
element kind, which makes product callouts and external detail panels much
easier to implement.

Use `ChartAnchoredCalloutLayout` when the tooltip card should remain readable
while its arrow points at the exact tap location:

```swift
let layout = ChartAnchoredCalloutLayout.vertical(
    anchor: element.interactionPosition ?? element.position,
    calloutSize: CGSize(width: 180, height: 92),
    containerSize: plotSize,
    preferredSide: .below
)
```

Pass `layout.center` to a fixed custom annotation placement and use
`layout.arrowXOffset` to offset the callout triangle.

When a series is created inside a SwiftUI `body`, pass a stable `id:` if
selection, animation continuity, or linked chart state matters:

```swift
LineSeries(data: readings, id: glucoseSeriesID, color: .cyan)
```

### Legend

Add a `label` to supported series and enable the built-in legend:

```swift
OZChart(current)
    .line(color: .blue, label: "Current")
    .legend(.bottom)
```

Legend positions: `.top`, `.bottom`, `.leading`, `.trailing`, `.hidden`.
Use `CartesianChartView` when the legend needs to combine independent data
arrays in one chart.

For full control, provide custom legend content:

```swift
.chartLegend(.top) { items in
    HStack {
        ForEach(items) { item in
            Text(item.title)
        }
    }
}
```

Grouped series such as stacked bars, stacked areas, and violin charts expose
legend items through `groupLabel`.

### Accessibility

```swift
.chartAccessibility(
    label: "Revenue chart",
    summary: "Monthly revenue from January to December",
    selectedValueFormatter: { points in
        points.first.map { "Selected value \(Int($0.originalPoint.y))" }
    }
)
```

### Downsampling

Use LTTB downsampling for dense line charts:

```swift
LineSeries(
    data: samples,
    color: .blue,
    downsampling: .automatic(maxPointsPerPixel: 1)
)
```

### Smooth Lines

Use monotone interpolation when the line should be smooth without introducing artificial overshoot between measured values:

```swift
LineSeries(
    data: glucoseReadings,
    color: .green,
    lineWidth: 3,
    interpolation: .monotone
)
```

Available interpolation modes are `.linear`, `.step`, and `.monotone`.

### Product Styling

Use reusable render styles when matching polished product charts:

```swift
OZChart(streaks)
    .line(
        color: .purple,
        lineWidth: 4,
        interpolation: .monotone,
        strokeStyle: .gradient([.purple, .pink], startPoint: .leading, endPoint: .trailing),
        shadow: ChartShadowStyle(color: .purple.opacity(0.35), radius: 8),
        area: AreaStyle(
            fillStyle: .gradient([.purple.opacity(0.34), .purple.opacity(0.02)]),
            baseline: 0
        )
    )
```

`ChartFillStyle` supports solid colors, linear gradients, and striped fills. Stripes are useful for remainder or unavailable segments in stacked bars.

```swift
OZChart(achievementRows)
    .stackedBar(
        stackOrder: [.star1, .star2, .star3, .remainder],
        colorMapper: palette.color,
        fillStyleMapper: { group in
            group == .remainder
                ? .stripes(foreground: .white.opacity(0.14), background: .gray.opacity(0.2))
                : .color(palette.color(group))
        },
        rowLabel: { row in achievementLabel(for: row) },
        valueLabelStyle: ChartValueLabelStyle(position: .outside)
    )
    .legend(.bottom)
```

Donut segments can be rounded, separated, gradient-filled, shadowed, and offset:

```swift
OZDonutChart(
    scoreShare,
    colors: [.cyan, .purple, .yellow],
    segmentStyles: [
        DonutSegmentStyle(fill: .gradient([.cyan, .mint])),
        DonutSegmentStyle(fill: .gradient([.purple, .pink]), explodedOffset: 10),
        DonutSegmentStyle(fill: .gradient([.yellow, .orange]), explodedOffset: 14)
    ],
    label: "Score",
    segmentLabelMapper: { point in label(for: point) },
    thickness: 42,
    gapAngle: .degrees(7),
    lineCap: .round
) {
    Text("82%")
        .font(.title.bold())
}
```

Control donut spacing with `gapAngle`, per-segment `explodedOffset`,
`thickness`, and `lineCap`. Use `segmentLabelMapper` when selection or
accessibility should speak in product terms such as "Basic", "Bonus", or
"Streak". Use smaller gaps for dashboard summaries and larger exploded offsets
when the chart needs to match a product mockup with separated arcs.

Use `StackedAreaSeries` when values are incremental and should accumulate visually by group:

```swift
OZChart(pointEvents)
    .stackedArea(
        stackOrder: [.basic, .bonus, .streak],
        colorMapper: palette.color,
        fillStyleMapper: palette.fill,
        interpolation: .step
    )
    .rendering(.dashboard())
    .staticChart()
```

### Real-World Event Data

The demo app includes `DemoScenarios.json`, which models chart inputs as domain events instead of drawing coordinates. This is closer to how production apps usually receive data from an API:

For product-style recreations of the demo charts, see [Product Chart Recipes](Docs/ProductCharts.md).

```json
{
  "timestamp": "2026-04-24T07:10:00Z",
  "kind": "insulin",
  "value": 4.5,
  "unit": "U",
  "label": "Breakfast bolus"
}
```

The demo adapter maps measured events into series points, maps domain events into `ChartEventMarker`, and maps target ranges, time windows, plot regions, and reference lines into annotation models. The included scenarios cover glucose care, interval training, portfolio tracking, and API latency.

### Area And Bar Series

```swift
AreaSeries(
    data: trend,
    color: .cyan,
    fillOpacity: 0.18,
    baseline: 0,
    label: "Trend"
)

BarSeries(
    data: volume,
    color: .orange,
    label: "Volume",
    barWidth: 12,
    baseline: 0
)
```

### Scales

```swift
let linear = LinearScale(domain: 0...100)
let log = LogScale(domain: 1...10_000)
let time = LinearScale.time(domain: startDate...endDate)
let band = BandScale(categories: ["Low", "Medium", "High"])
let dateAxis = XAxisConfig.date()
```

## Documentation

The package includes a DocC catalog in `Sources/OZCharts/OZCharts.docc`.
Open the package in Xcode and build documentation to browse the public API,
live chart guidance, selection and annotations, and product-chart recipes.

## Code Style

The repository includes SwiftFormat and SwiftLint configs for consistent handoff
style:

```bash
swiftlint lint --no-cache
```

The configs are intentionally conservative. They focus on readable diffs,
reasonable function/file size limits, import hygiene, and common Swift clarity
checks without forcing a broad rewrite of the public API. The SwiftFormat config
is available for targeted files and for a dedicated mechanical formatting change
when the team is ready for that diff.

## Running the Demo App

This repository includes a comprehensive `DemoApp`. The first section is tuned
for handoff review and shows product-like charts, live telemetry, and
real-world JSON event streams. The second section is a focused component
catalog for developers.

1. Clone the repository.
2. Open `DemoApp/DemoApp.xcodeproj` in Xcode.
3. Build and run on your simulator or device.

## Author

OZCharts was designed, implemented, and is maintained by **Oleh Hulovatyi**.

If you use, fork, or reference this framework, please keep the copyright and author attribution included in the source headers and license files.

## Community & Resources

Want to see the architecture behind this framework and learn advanced iOS development? Check out the **[OZ pro iOS](https://www.youtube.com/@OZ_pro_iOS)** YouTube channel for deep dives into Swift, SwiftUI, and mobile architecture.

## License

OZCharts is released under the MIT license. See [LICENSE](LICENSE) and [AUTHORS.md](AUTHORS.md) for details.
