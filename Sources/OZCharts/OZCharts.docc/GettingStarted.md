# Getting Started

Create charts from domain values, not drawing coordinates. OZCharts maps your data into plot space through scales, axes, and viewport state.

## Basic Line Chart

```swift
import SwiftUI
import OZCharts

struct LatencyChart: View {
    let samples: [Point2D]

    var body: some View {
        CartesianChartView(
            series: [
                LineSeries(
                    data: samples,
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    color: .cyan,
                    lineWidth: 3,
                    interpolation: .monotone
                )
            ],
            xDomain: .auto(padding: 0.02),
            yDomain: .auto(padding: 0.12, includeZero: true),
            theme: .dark,
            xAxes: [.time(suffix: "s")]
        ) { points in
            if let point = points.first {
                Text("\(Int(point.originalPoint.y)) ms")
                    .padding(8)
                    .background(.black.opacity(0.8))
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
        }
        .chartSelection(.nearestX, hitboxRadius: 28)
        .chartCrosshair(.vertical())
        .chartLegend(.bottom)
        .frame(height: 300)
    }
}
```

## Integration Rules

Use stable `id:` values for series that are recreated in a SwiftUI `body`. Stable ids preserve selection, animation continuity, linked chart state, and element identity.

Prefer fixed domains when the chart range is part of the product contract, such as 0...100 percent, glucose target bands, or a 24-hour live window. Prefer `.auto(...)` when the chart is exploratory.

Use grouped points for stacked, violin, and grouped product charts. Use `ChartEventMarker`, `RangeAnnotation`, and `CustomViewAnnotation` for domain events instead of manually positioning labels.
