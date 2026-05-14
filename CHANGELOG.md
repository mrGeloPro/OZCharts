# Changelog

## Unreleased

### Added

* Real-world JSON demo scenarios for medical, sport, financial, and operational chart examples.
* Product chart recipes and integration handoff documentation.
* `StackedAreaSeries` for cumulative grouped metrics.
* Product render styling helpers, including gradients, stripes, shadows, and callout presets.
* `AxisTransform` support for display-only secondary-axis values.
* Range annotation label positioning for dense product charts.
* Tooltip max-width support and safer automatic placement.
* `ChartSelectedElement` and element hit-testing for bars, stacked-bar segments, and donut segments.
* `.chartElementSelection(...)` for non-point interaction callbacks.
* `selectedElements` support in `ChartSelectionState`.
* `selectedElementFormatter` support in chart accessibility descriptors.
* Stable `id:` parameters for chart series and custom view annotations.
* Product snapshot signature tests and optional performance benchmark tests.

### Changed

* DemoApp now includes product-style graph recreations and event-driven scenarios.
* Donut segments can expose product labels through `segmentLabelMapper`.

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
