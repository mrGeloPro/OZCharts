# Fluent API

Use ``OZChart`` when a screen needs a clear, compact chart declaration.

## Overview

``CartesianChartView`` remains the lowest-level SwiftUI entry point. ``OZChart``
is a fluent facade for dashboard and result-screen charts where a single data
array drives one or more related series.

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
* ``OZChart/scatter(id:color:label:pointSize:symbol:zIndex:)``;
* ``OZChart/donut(id:colors:segmentStyles:label:segmentLabelMapper:thickness:gapAngle:startAngle:lineCap:animation:zIndex:)``;
* ``OZChart/stackedArea(id:stackOrder:colorMapper:fillStyleMapper:groupLabel:interpolation:lineWidth:fillOpacity:shadow:animation:zIndex:)``;
* ``OZChart/stackedBar(id:stackOrder:colorMapper:fillStyleMapper:groupLabel:rowLabel:valueLabelStyle:barHeight:cornerRadius:segmentGap:animation:zIndex:)``;
* ``OZChart/violin(id:centerX:maxHalfWidth:sideMapper:colorMapper:fillStyleMapper:groupLabel:fillOpacity:strokeWidth:showScatter:scatterSize:scatterOpacity:shadow:bandwidth:sampleCount:animation:zIndex:)``.

When no explicit `id` is provided, `OZChart` assigns deterministic series ids so
SwiftUI body rebuilds do not create artificial chart data changes.

## Advanced Dashboard Series

```swift
OZChart(rows)
    .stackedBar(
        stackOrder: [.completed, .missed, .remaining],
        colorMapper: palette.color,
        groupLabel: label(for:),
        rowLabel: { row in dayLabel(for: row) }
    )
    .compactAxes(xPosition: .top, yPosition: .leading)
    .legend(.dashboard(position: .bottom, itemLimit: 4))
    .staticChart()
```

Use ``OZDonutChart`` when a donut is the whole chart and the call site should
not declare cartesian domains:

```swift
OZDonutChart(scoreShare, colors: [.cyan, .purple, .orange], label: "Score") {
    Text("82%")
}
.selection { segments in
    selectedSegment = segments.first
}
```

For compact dashboard cards, prefer a presentation preset:

```swift
OZChart(samples)
    .line(color: .cyan)
    .presentation(.dashboardCompact(xPosition: .top, yPosition: .trailing))
```

Use lower-level modifiers such as ``ChartRenderOptions/dashboard(legend:spacing:)``,
``ChartTheme/dashboard``, ``OZChart/staticChart()``, ``OZChart/hiddenAxes()``,
and ``OZChart/compactAxes(xTickCount:yTickCount:xPosition:yPosition:)`` when a
screen needs custom composition beyond a preset.

For dense multi-series dashboards, use ``ChartLegendOptions`` to keep legend
layout readable without custom SwiftUI plumbing:

```swift
OZChart(samples)
    .line(color: .cyan, label: "Current")
    .line(color: .orange, label: "Target")
    .legend(.compact(position: .bottom, itemLimit: 3))
```

## Configure Behavior

Use option structs to keep chart configuration readable:

```swift
OZChart(samples)
    .line(color: .blue)
    .interaction(.automatic)
    .selection(.nearestX)
    .selectionState($selectionState)
    .viewportState($viewportState)
    .onSelection { selection in
        selectedSample = selection.primaryPoint?.originalPoint
        selectedElement = selection.primaryElement
    }
    .tooltipOptions(.automatic)
    .viewport(.automatic)
    .rendering(.automatic)
```

For advanced multi-series composition, custom scales, or deeply customized
product views, use ``CartesianChartView`` directly.
