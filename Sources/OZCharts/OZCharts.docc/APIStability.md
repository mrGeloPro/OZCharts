# API Stability

OZCharts 2.5 defines a stable 2.x integration surface.

## Stable APIs

The existing ``CartesianChartView`` initializers and modifiers remain supported.
New option structs provide grouped configuration without replacing existing
call sites:

* ``ChartInteractionOptions``
* ``ChartSelectionOptions``
* ``ChartTooltipOptions``
* ``ChartViewportOptions``
* ``ChartRenderOptions``

The fluent ``OZChart`` API is also stable for common line, area, bar, and scatter
charts.

## Diagnostics

Use ``ChartDiagnostics`` directly in tests or `.chartDiagnostics` on chart views
to detect common integration mistakes such as duplicate ids, non-finite values,
empty series, or unusably small canvases.

## Versioning

OZCharts follows semantic versioning:

* patch releases fix bugs and internal implementation details;
* minor releases add compatible API and behavior;
* major releases can reshape public API.

For the full policy, see `Docs/APIStability-2.5.md` in the repository.
