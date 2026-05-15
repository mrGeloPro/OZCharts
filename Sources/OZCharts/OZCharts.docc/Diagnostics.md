# Diagnostics

Catch common integration mistakes before a chart reaches production.

## Overview

OZCharts is intentionally tolerant at render time: empty data, hidden axes, and
small canvases should not crash an app. For release preflight checks, use
``ChartDiagnostics`` to detect inputs that usually indicate a broken integration.

```swift
let diagnostics = ChartDiagnostics.validate(
    series: [
        LineSeries(data: glucoseSamples, color: .cyan).eraseToAnyChartSeries()
    ],
    canvasSize: CGSize(width: 390, height: 260)
)

for diagnostic in diagnostics {
    print(diagnostic.code, diagnostic.severity, diagnostic.message)
}
```

The validator currently reports:

* empty series lists;
* empty individual series;
* duplicate series ids;
* duplicate point ids;
* non-finite point values;
* canvases that are too small to render reliably.

In debug builds, ``CartesianChartView`` also reports these diagnostics when the
view appears, resizes, or receives changed series data.
