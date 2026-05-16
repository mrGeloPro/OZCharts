# Getting Started

Create charts from domain values, not drawing coordinates. OZCharts maps your data into plot space through scales, axes, and viewport state.

## Basic Line Chart

```swift
import SwiftUI
import OZCharts

struct LatencyChart: View {
    private static let latencySeriesID = UUID()
    @State private var selectedSample: Point2D?
    let samples: [Point2D]

    var body: some View {
        OZChart(samples, theme: .dark)
            .line(
                id: Self.latencySeriesID,
                color: .cyan,
                lineWidth: 3,
                interpolation: .monotone
            )
            .domain(
                x: .auto(padding: 0.02),
                y: .auto(padding: 0.12, includeZero: true)
            )
            .axes(x: [.time(suffix: "s")])
            .selection(.nearestX)
            .onSelection { selection in
                selectedSample = selection.primaryPoint?.originalPoint
            }
            .tooltip { points in
                if let point = points.first {
                    Text("\(Int(point.originalPoint.y)) ms")
                        .padding(8)
                        .background(.black.opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
            .rendering(.dashboard())
            .frame(height: 300)
    }
}
```

## Integration Rules

Use stable `id:` values for series that are recreated in a SwiftUI `body`. Stable ids preserve selection, animation continuity, linked chart state, and element identity.

Prefer fixed domains when the chart range is part of the product contract, such as 0...100 percent, glucose target bands, or a 24-hour live window. Prefer `.auto(...)` when the chart is exploratory.

Use grouped points for stacked, violin, and grouped product charts. Use `ChartEventMarker`, `RangeAnnotation`, and `CustomViewAnnotation` for domain events instead of manually positioning labels.
