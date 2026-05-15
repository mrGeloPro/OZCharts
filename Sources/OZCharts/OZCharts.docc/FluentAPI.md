# Fluent API

Use ``OZChart`` when a screen needs a clear, compact chart declaration.

## Overview

``CartesianChartView`` remains the lowest-level SwiftUI entry point. ``OZChart``
is a fluent facade for common chart setups where a single data array drives one
or more simple series.

```swift
OZChart(samples)
    .line(color: .blue, downsampling: .automatic())
    .selection(.nearestX)
    .domain(y: .auto(padding: 0.12, includeZero: true))
    .tooltip { points in
        if let point = points.first {
            Text("\(Int(point.originalPoint.y))")
        }
    }
```

## Add Series

```swift
OZChart(samples)
    .line(color: .cyan, label: "Current")
    .scatter(color: .white, pointSize: 4)
```

Available fluent series helpers:

* ``OZChart/line(id:color:label:lineWidth:interpolation:downsampling:animation:zIndex:)``;
* ``OZChart/area(id:color:fillColor:label:fillOpacity:interpolation:downsampling:animation:zIndex:)``;
* ``OZChart/bar(id:color:label:barWidth:cornerRadius:baseline:zIndex:)``;
* ``OZChart/scatter(id:color:label:pointSize:symbol:zIndex:)``.

When no explicit `id` is provided, `OZChart` assigns deterministic series ids so
SwiftUI body rebuilds do not create artificial chart data changes.

## Configure Behavior

Use option structs to keep chart configuration readable:

```swift
OZChart(samples)
    .line(color: .blue)
    .interaction(.automatic)
    .selection(.nearestX)
    .selectionState($selectionState)
    .viewportState($viewportState)
    .onSelectionChanged { points in
        selectedSample = points.first?.originalPoint
    }
    .onElementSelectionChanged { elements in
        selectedElement = elements.first
    }
    .tooltipOptions(.automatic)
    .viewport(.automatic)
    .rendering(.automatic)
```

For advanced multi-series composition, custom scales, or deeply customized
product views, use ``CartesianChartView`` directly.
