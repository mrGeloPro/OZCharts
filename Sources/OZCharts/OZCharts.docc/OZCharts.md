# ``OZCharts``

Build production-grade SwiftUI charts for live data, analytics, event timelines, and product-style dashboards.

## Overview

OZCharts is a Canvas-first charting framework with SwiftUI composition around it. The core keeps chart geometry, axes, selection, hit-testing, annotations, legends, and viewport state predictable across chart types.

Use OZCharts when a product needs more control than a standard chart view can provide:

* Dense line and area charts with downsampling.
* Smooth, step, and linear interpolation.
* Scrollable and zoomable viewports.
* Live data tracking that can follow latest data or let users inspect history.
* Selectable points, bars, stacked bars, donut segments, event markers, and custom annotations.
* Axis transforms for secondary axes and derived display units.
* Product-style donut, violin, stacked bar, and stacked area charts.

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:FluentAPI>
- <doc:LiveCharts>
- <doc:SelectionAndAnnotations>
- <doc:ProductCharts>
- <doc:Diagnostics>
- <doc:APIStability>

### Core Views

- ``OZChart``
- ``CartesianChartView``

### Data Models

- ``Point2D``
- ``GroupedPoint2D``
- ``ChartDataPoint``
- ``GroupedChartDataPoint``

### Series

- ``LineSeries``
- ``AreaSeries``
- ``BarSeries``
- ``ScatterSeries``
- ``StackedAreaSeries``
- ``StackedBarSeries``
- ``DonutSeries``
- ``ViolinSeries``

### Axes and Viewport

- ``XAxisConfig``
- ``YAxisConfig``
- ``AxisTransform``
- ``ChartInitialViewport``
- ``ChartViewportState``
- ``ChartLiveTrackingMode``

### Interaction

- ``ChartSelectionState``
- ``ChartSelectionMode``
- ``ChartSelectedElement``
- ``ChartSelectedPoint``
- ``ChartEventMarker``
- ``RangeAnnotation``
- ``PointAnnotation``
- ``CustomViewAnnotation``

### Release Readiness

- ``ChartInteractionOptions``
- ``ChartSelectionOptions``
- ``ChartTooltipOptions``
- ``ChartViewportOptions``
- ``ChartRenderOptions``
- ``ChartDiagnostics``
- ``ChartDiagnostic``
- ``ChartDiagnosticSeverity``
