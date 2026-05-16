# OZCharts 3.0 Roadmap

OZCharts 3.0 is the API-shaping release. The goal is to turn the framework from
a powerful chart toolkit into a cleaner chart grammar for product teams building
SwiftUI dashboards, result screens, and rich interactive visualizations.

## Product Goals

* Make the recommended API obvious for every chart family.
* Keep advanced charts expressive without exposing internal composition details
  unless the app explicitly chooses the low-level API.
* Unify selection, tooltip, legend, axes, and presets around one mental model.
* Use breaking changes only when they remove real ambiguity from the public API.

## 3.0 Workstreams

### 1. Unified Selection

Introduce `ChartSelection<Point>` as the single selection payload:

```swift
chart.onSelection { selection in
    selection.points
    selection.elements
    selection.annotations
    selection.state
}
```

This replaces the need to coordinate separate point, element, and annotation
callbacks in product code. The 2.x callbacks can remain temporarily while 3.0
docs move examples to the unified form.

Acceptance criteria:

* `CartesianChartView` can emit a unified selection snapshot.
* `OZChart` exposes a fluent `.onSelection { ... }` callback.
* Annotation, point, and element selections all clear/update the unified payload
  predictably.
* Tests cover empty, point, element, and annotation payloads.

### 2. Chart Entry Points

Recommended public entry points:

* `OZChart` for fluent cartesian dashboard/result charts.
* `OZDonutChart` for donut-only cards.
* Future `OZPolarChart` only if we add a real polar family beyond donut.
* `CartesianChartView` remains the low-level escape hatch.

Breaking candidates:

* Move low-level naming and examples out of first-read docs.
* Deprecate product examples that require `AnyChartSeries` at the app call site.
* Rename ambiguous modifiers where 2.x naming mixes behavior and callback setup.

### 3. Presets And Themes

Create first-class `ChartPresentationPreset` values for common product surfaces:

* dashboard compact
* sparkline/no axes
* static report
* interactive exploration
* dense event timeline

Recommended usage:

```swift
OZChart(samples)
    .line(color: .cyan)
    .presentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))
```

For low-level chart composition:

```swift
CartesianChartView(...)
    .chartPresentation(.interactiveExploration())
```

Acceptance criteria:

* Presets combine interaction, axes, legend, tooltip, render style, and theme
  defaults where appropriate.
* Axis placement remains explicit: top/bottom and leading/trailing continue to
  work through presets and manual configs.
* Low-level views can apply presentation presets after initialization.

### 4. Legend API

Make multi-series legends easier to use without custom view plumbing.

Acceptance criteria:

* Fluent charts can opt into grouped legends with one modifier.
* Custom legend content remains possible.
* Grouped series legend labels are documented consistently.

### 5. Polar And Donut Architecture

Donut already has `OZDonutChart`; 3.0 should decide whether the internal
implementation stays cartesian-backed or moves to a dedicated polar container.

Acceptance criteria:

* App code never needs fake `0...1` cartesian domains for donut charts.
* Hit-testing, legends, accessibility, and selected-element rendering stay
  consistent with cartesian charts.

### 6. Migration And Deprecations

3.0 should ship with an explicit migration guide:

* 2.x callbacks to unified selection.
* `CartesianChartView + AnyChartSeries` examples to fluent `OZChart` when
  possible.
* Donut composition to `OZDonutChart`.
* Manual stacked-bar row axes to `rowLabel`.

## Release Gate

Before cutting 3.0:

* `swift test`
* DemoApp iOS simulator build
* DocC symbol link check
* Public API compile tests
* Product snapshot smoke tests
* Migration guide reviewed against all DemoApp product screens
