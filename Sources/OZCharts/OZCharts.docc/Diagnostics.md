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
    canvasSize: CGSize(width: 390, height: 260),
    plotAreaSize: CGSize(width: 300, height: 220),
    xDomain: 0 ... 24,
    yDomain: 40 ... 220
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
* plot areas that become too small after layout;
* empty or invalid x/y domains;
* data points outside the active domains;
* axis layouts that consume too much of the chart area.

In debug builds, ``CartesianChartView`` also reports these diagnostics when the
view appears, resizes, or receives changed series data. Runtime diagnostics can
also report product-integration friction:

* `selection-missed-hitbox` when a tap does not hit a point, element, or
  annotation;
* `tooltip-clamped` when a tooltip is moved to remain visible.

Use `.diagnostics { diagnostics in ... }` on ``OZChart`` or
``CartesianChartView`` to surface these events in a custom logger during product
QA without parsing console output.
