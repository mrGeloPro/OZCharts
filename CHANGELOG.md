# Changelog

## Unreleased

### 3.1 Product Ergonomics

* Added `ChartSelectionAnchor` plus `ChartSelection.primaryAnchor`,
  `primaryPosition`, and `primaryBounds` for product popovers that need one
  normalized anchor across points, stacked-bar segments, donut segments, and
  annotations.
* Added `ChartPresentationPreset.productCard(...)` for product-card defaults
  around theme, selection, tooltip, legend, zoom controls, and optional plot
  border.
* Added `labelReservedSize` and `labelAlignment` to `XAxisConfig` and
  `YAxisConfig` for pixel-level axis label layout without custom wrappers.
* Added `StackedBarInteractionOptions.achievement` and
  `StackedBarRemainderStyle.achievementTarget(...)` for achievement-style
  horizontal stacked bars.
* Added `ChartFillStyle.achievementRemainder(...)` for native hatched
  remainder segments.
* Added runtime/product diagnostics for `axis-layout-warning`,
  `plot-area-too-small`, `selection-missed-hitbox`, `tooltip-clamped`,
  `domain-empty-or-invalid`, and `series-outside-domain`.
* Added DocC and README troubleshooting guidance for Xcode package caches,
  axis layout tuning, selection/tooltip tuning, and diagnostics.
* Fixed full-range panning so dragging a chart at 100% zoom does not rebuild
  scales or visually shift axes when there is no remaining scrollable domain.
* Fixed axis labels and grid lines for explicit ticks so values outside the
  zoomed plot range no longer render outside the chart area.
* Fixed element tooltips so product callouts are constrained to the visible
  chart overlay and render above adjacent axis/value-label layers.

### Added

* `ChartSelection<Point>` and unified selection callbacks as the first 3.0 API-shaping step.
* `ChartPresentationPreset` with dashboard, sparkline, static report, interactive exploration, and dense timeline presets.
* `ChartLegendOptions` with compact/dashboard legend presets, item limits, overflow labels, and option-based fluent legend modifiers.
* OZCharts 3.0 migration guide for unified selection, advanced fluent series, donut wrappers, row labels, presets, and legend options.
* Dedicated polar donut layout API through `PolarDonutLayoutOptions` and `PolarSegmentLayout`, plus unified `.onSelection` support on `OZDonutChart`.
* OZCharts 3.0 roadmap for the upcoming architecture and migration work.
* `OZChart.donut(...)`, `.stackedArea(...)`, `.stackedBar(...)`, and `.violin(...)` fluent helpers for advanced dashboard series.
* `OZDonutChart` for donut-only cards with center content, dashboard defaults, legend support, and element selection without fake cartesian domains in app code.
* `OZChart.legend(...)`, `.staticChart()`, `.hiddenAxes()`, `.compactAxes(...)`, `ChartRenderOptions.dashboard(...)`, `ChartTheme.dashboard`, and compact axis presets for mobile dashboard charts.
* `OZChart.stackedBar(... rowLabel:)` for row labels without manual y-axis mapping.
* `OZChart.line(...)` and `.area(...)` now expose gradient strokes, shadows, area fills, baselines, dash styling, and line caps for polished dashboard charts without dropping to `LineSeries` or `AreaSeries`.
* Element selection now supports overlapping `.all` and `.cycle` behavior for bars, stacked-bar segments, donut segments, and other selectable element marks.
* OZCharts 3.0 release notes and README first-read examples for the new fluent product API.
* OZCharts 2.6 release notes and updated product-chart recipes for the new fluent API.

### Deprecated

* `OZChart.onSelectionChanged`, `OZChart.onElementSelectionChanged`, and low-level `.chartElementSelection(...)` now point new code to unified selection callbacks.
* `OZDonutChart.selection(_:onChange:)` now points new code to `selection(_:)` plus unified `.onSelection`.

## 2.5.2

### Added

* `XRangeAnnotation`, `VerticalAnnotation`, and `XYRangeAnnotation` for time windows, vertical event thresholds, and bounded plot regions.
* `CartesianChartView`, convenience initializers, and `OZChart.annotations(...)` support for the expanded annotation set.
* DemoApp JSON scenario support for x-range bands, xy-range regions, vertical lines, top-baseline bars, reference lines, per-scenario tick counts, explicit x-axis ticks, axis placement, fixed time zones, and presentation flags.

### Changed

* The real-world CGM demo now includes a reference-style night trend with pump activity bars, target bands, threshold lines, time-window shading, deterministic time labels, right/top axes, and a current-time marker.

## 2.5.1

### Fixed

* Chart layout now measures long axis labels before reserving plot insets, reducing clipping for localized or high-precision labels.
* Stable series ids now also track series layout/render style changes, so restyled charts refresh even when point values are unchanged.
* `ChartStore` remains public to avoid a source-compatibility regression from 2.5.0.

### Added

* `OZChart` fluent API for common line, area, bar, and scatter charts.
* `OZChart` selection callbacks plus viewport and selection state binding modifiers.
* `ChartInteractionOptions`, `ChartSelectionOptions`, `ChartTooltipOptions`, `ChartViewportOptions`, and `ChartRenderOptions` for grouped, stable chart configuration.
* Real-world JSON demo scenarios for medical, sport, financial, and operational chart examples.
* Product chart recipes and integration handoff documentation.
* `StackedAreaSeries` for cumulative grouped metrics.
* Product render styling helpers, including gradients, stripes, shadows, and callout presets.
* `AxisTransform` support for display-only secondary-axis values.
* Composable `AxisTransform` helpers for offset, percentage, clamping, finite fallback, and transform chaining.
* `ChartLayoutEngine` / `ChartPlotLayout` for shared plot-area and axis inset calculations.
* `ChartLabelCollisionResolver` and `ChartLabelPlacement` for collision-aware custom annotation placement.
* `ChartHitTestResolver` for centralized element and point hit-testing.
* `ChartSelectedElementStyle` and built-in selected element overlay rendering.
* Range annotation label positioning for dense product charts.
* Tooltip max-width support and safer automatic placement.
* `ChartAnchoredCalloutLayout` for product callouts whose arrow must point to the tap location while the card stays readable.
* `ChartSelectedElement` and element hit-testing for bars, stacked-bar segments, and donut segments.
* `.chartElementSelection(...)` for non-point interaction callbacks.
* `selectedElements` support in `ChartSelectionState`.
* `selectedElementFormatter` support in chart accessibility descriptors.
* `ChartLiveTrackingMode`, live viewport status, paused live behaviors, and jump-to-latest viewport commands.
* Stable `id:` parameters for chart series and custom view annotations.
* Placement, collision priority, and padding controls for `CustomViewAnnotation`.
* Product snapshot signature tests and optional performance benchmark tests.
* Demo app source-structure regression tests.
* GitHub Actions CI for SwiftPM tests, linting, DemoApp builds, and manually triggered performance benchmarks.
* `ChartDiagnostics` for testable release checks around empty series, duplicate ids, non-finite points, and too-small canvases.
* `.chartDiagnostics(...)` for consuming diagnostics from chart views.
* OZCharts 2.5 release notes and API stability policy.

### Changed

* DemoApp now includes product-style graph recreations and event-driven scenarios.
* DemoApp examples are split into `Home`, `Showcase`, `Shared`, `Scenarios`, and typed demo folders for easier external handoff.
* Donut segments can expose product labels through `segmentLabelMapper`.
* Custom SwiftUI annotations are clamped and resolved through the shared label collision engine.
* Canvas-drawn range and value labels now use shared collision/clamping rules.
* Live tracking now supports frozen history and delayed-live paused windows when users scroll away from latest.
* Live viewports are clamped safely when older data is trimmed from the domain.
* Dense hit-testing now avoids extra collection passes and sort work on the hot interaction path.
* Point hit-testing now uses a lazy cached x-index and adaptive 2D spatial grid owned by `ChartStore` for dense interactive datasets.
* Render contexts are separated from full interaction contexts so dense series can draw downsampled data while selection remains precise.
* `OZChart` default series ids are deterministic across SwiftUI rebuilds.

### Fixed

* Stable series ids now still trigger chart layout updates when point values change, fixing live chart redraws and animation demos without returning to unstable UUID-driven refreshes.

## 2.0.0

### Added

* Series-first chart API with type-erased `AnyChartSeries`.
* `AreaSeries` and vertical `BarSeries`.
* `ChartStore` state orchestration for layout, gestures, animation state, and live tracking.
* Auto domains via `ChartDomain`.
* Nice tick generation and collision-aware axis labels.
* Themes and axis presets through `ChartTheme`, `XAxisConfig`, and `YAxisConfig`.
* Selection modes: `.pointsInRadius`, `.nearestPoint`, `.nearestX`, `.none`.
* Selection behavior control: `.tap`, `.drag`, `.tapAndDrag`, `.disabled`.
* Overlapping selection cycling for stacked or closely clustered points.
* Selectable point and custom-view annotations with dedicated annotation tooltip content.
* Tooltip placement modes with edge clamping.
* Initial viewport API for charts that should start zoomed into a smaller visible domain.
* Bindable viewport state for external zoom, pan, reset, and linked chart workflows.
* Bindable selection state for linked charts and shared crosshair interactions.
* Built-in zoom controls for zoom in, zoom out, and reset.
* Built-in crosshair styles.
* SwiftUI-style chart modifiers.
* Built-in legend with top, bottom, leading, trailing, wrapping, custom content, and grouped-series items.
* Accessibility descriptor API.
* LTTB downsampling for dense line charts.
* `LogScale`, `BandScale`, date axis preset, and time scale convenience.
* Expanded unit and rendering smoke tests.
* Professional DemoApp showcase with a feature dashboard, catalog cards, and an all-features composition.
* DemoApp examples for viewport controls, linked charts, selectable annotations, and area/bar charts.

### Changed

* Minimum iOS version is iOS 16.
* Rendering is organized around Canvas layers plus optional SwiftUI annotation overlays.
* Gesture layout updates are synchronous while panning and zooming to avoid visible lag.

### Fixed

* Zero-size Canvas rendering guards for simulator/runtime stability.
* Annotation clipping during zoom and pan.
* Pan/zoom gesture conflict where icons and line layers could move out of sync.
* Animation double-rendering for series that use animatable overlays.
