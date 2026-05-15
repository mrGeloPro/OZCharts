# OZCharts 2.5 API Stability Policy

OZCharts 2.5 is the first release intended to be treated as a stable integration
target for real projects.

## Stable Surface

The following APIs are considered stable within the 2.x line:

* `CartesianChartView` existing initializers and SwiftUI modifiers;
* `OZChart` fluent entry point for common line, area, bar, and scatter charts;
* `ChartInteractionOptions`, `ChartSelectionOptions`, `ChartTooltipOptions`,
  `ChartViewportOptions`, and `ChartRenderOptions`;
* core data models: `ChartDataPoint`, `Point2D`, `GroupedPoint2D`;
* core series: `LineSeries`, `AreaSeries`, `BarSeries`, `ScatterSeries`,
  `StackedAreaSeries`, `StackedBarSeries`, `DonutSeries`, and `ViolinSeries`;
* axis/domain types: `ChartDomain`, `XAxisConfig`, `YAxisConfig`,
  `AxisTransform`, `LinearScale`, `LogScale`, and `BandScale`;
* interaction state: `ChartSelectionState`, `ChartViewportState`,
  `ChartSelectedElement`, `ChartSelectedPoint`;
* diagnostics: `ChartDiagnostics`, `ChartDiagnostic`, and
  `ChartDiagnosticSeverity`.

Stable means these APIs should not be removed or renamed in a minor 2.x release.
New overloads, new options, and additive enum cases may still be introduced.

## Experimental But Supported

These APIs are production-usable, but their customization depth may expand in
minor releases:

* collision-aware custom annotation placement;
* live tracking paused behavior;
* selected element overlay styling;
* product callout layout helpers;
* render-context downsampling hooks through `ChartSeriesProtocol.renderContexts`.

Changes should remain source-compatible whenever possible. If a breaking change
is unavoidable, it should be reserved for 3.0 or accompanied by a migration
adapter.

## Deprecation Rules

For the 2.x line:

* prefer adding a new API before deprecating an old one;
* keep deprecated APIs available for at least one minor release;
* document replacements in release notes and DocC;
* avoid changing default behavior in a way that alters existing chart visuals
  unless the old behavior was clearly incorrect.

## Performance Contract

OZCharts does not promise fixed frame times across all data sizes, but 2.5
commits to these engineering rules:

* render contexts may be downsampled separately from interaction contexts;
* internal x-indexes and adaptive spatial grids may be cached lazily to keep
  hit-testing fast without adding layout cost;
* selection should preserve full data accuracy unless a series explicitly opts
  into a reduced interaction model;
* optional benchmarks should be run before release tags;
* dense data regressions should be tracked against `Docs/PerformanceBenchmarks.md`.

## Versioning

Use semantic versioning:

* patch releases fix bugs, tests, docs, and internal performance issues;
* minor releases add chart types, options, modifiers, and compatible behavior;
* major releases can reshape the public API.
