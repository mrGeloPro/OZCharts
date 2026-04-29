# OZCharts

A high-performance, fully customizable, and mathematically precise charting framework for SwiftUI. Built for developers who need more flexibility than standard solutions provide.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

* **Versatile chart types:** Line, area, vertical bar, scatter, stacked horizontal bar, donut, and mathematically accurate violin charts.
* **Canvas-first rendering:** Smooth interaction with off-screen culling and synchronous gesture layouts.
* **Advanced gestures:** Independent horizontal and vertical scrolling/zooming with conflict handling between pan and pinch.
* **Hybrid layering:** Combine Canvas-rendered series with SwiftUI custom annotations.
* **Auto domains and presets:** Start quickly with `.auto(...)`, nice ticks, collision-aware labels, `ChartTheme`, and axis presets.
* **Interaction toolkit:** Selection modes, crosshair, selection behavior, and live tracking.
* **Production helpers:** Legend, accessibility descriptors, LTTB downsampling, log/time/category scales, and smoke-tested rendering contracts.

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
        CartesianChartView(
            series: [
                LineSeries(data: data, color: .blue, lineWidth: 3)
            ],
            xDomain: .auto(padding: 0.05),
            yDomain: .auto(padding: 0.12, includeZero: true),
            theme: .light,
            xAxes: [.time(suffix: "s")]
        ) { points in
            if let point = points.first {
                Text("Value: \(Int(point.originalPoint.y))")
                    .padding(8)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                EmptyView()
            }
        }
        .frame(height: 300)
    }
}
```

## Common Patterns

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
    tickCount: 6
)
```

### Custom Annotations

```swift
CartesianChartView(
    series: [LineSeries(data: data, color: .blue)],
    xDomain: .auto(),
    yDomain: .auto(),
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
CartesianChartView(
    series: [
        LineSeries(data: current, color: .blue),
        LineSeries(data: previous, color: .green)
    ],
    xDomain: .auto(),
    yDomain: .auto(),
    selectionMode: .nearestX,
    crosshairStyle: .vertical(),
    onSelectionChanged: { points in
        print(points.map(\.originalPoint.y))
    }
) { points in
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
```

Available modes:

* `.pointsInRadius` selects every point inside `hitboxRadius`.
* `.nearestPoint` selects the closest point.
* `.nearestX` selects all points sharing the nearest x-value.
* `.none` disables selection and tooltips.

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

Share selection state when multiple charts should move together:

```swift
@State private var sharedSelection = ChartSelectionState.none

VStack {
    priceChart
        .chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
        .chartSelectionState($sharedSelection)
        .chartCrosshair(.vertical())

    volumeChart
        .chartSelection(.nearestX, behavior: .tapAndDrag, clearsOnEnd: false)
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
    clearsOnEnd: false
)
.chartTooltipPlacement(.automatic, padding: 12)
```

Tooltip placements: `.automatic`, `.top`, `.bottom`, `.leading`, `.trailing`, `.center`, `.fixed(CGPoint)`.

### Legend

Add a `label` to supported series and enable the built-in legend:

```swift
CartesianChartView(
    series: [
        LineSeries(data: current, color: .blue, label: "Current"),
        ScatterSeries(data: targets, color: .orange, label: "Target")
    ],
    xDomain: .auto(),
    yDomain: .auto()
) { _ in
    EmptyView()
}
.chartLegend(.bottom)
```

Legend positions: `.top`, `.bottom`, `.leading`, `.trailing`, `.hidden`.

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

Grouped series such as stacked bars and violin charts can expose group legend items through `groupLabel`.

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

## Running the Demo App

This repository includes a comprehensive `DemoApp` demonstrating advanced use cases like Hybrid Layering, Custom Axes, and Live Animations.

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
