# OZCharts 3.1 Release Notes Draft

OZCharts 3.1 focuses on product integration ergonomics. The rendering
foundation from 3.0 stays intact; this release makes selection, layout,
diagnostics, and achievement-style bars easier to use in real app screens.

## Highlights

* `ChartSelection.primaryAnchor`, `primaryPosition`, and `primaryBounds` provide
  one normalized selection anchor for custom SwiftUI popovers.
* `ChartPresentationPreset.productCard(...)` captures common dashboard/result
  card defaults without hiding lower-level options.
* `XAxisConfig` and `YAxisConfig` now support `labelReservedSize` and
  `labelAlignment` for pixel-perfect axis labels.
* `.plotInsets(...)` provides first-class plot-area padding for Figma layouts
  that need the rendered marks/grid inset independently from axis label slots.
* `ChartAxisMarker` and `.axisMarkers(...)` let product screens pin custom
  SwiftUI icons or badges to x/y axis values, for example DST/time-change
  markers, without adding fake data points or custom axis labels.
* Axis markers now support `priority`, compact fallback content, collision
  strategies, and opt-in selection/cycling for overlapping marker clusters.
* Achievement stacked bars now have convenience APIs for row/segment
  interaction and hatched remainder targets.
* The diagnostics layer now reports product-integration issues such as small
  plot areas, invalid domains, missed hitboxes, clamped tooltips, and data
  outside configured domains.
* README and DocC now include troubleshooting guidance for Xcode package cache
  issues and layout/selection tuning.

## Recommended Selection Pattern

```swift
OZChart(rows)
    .stackedBar(
        stackOrder: [.star1, .star2, .star3],
        colorMapper: palette.color,
        layout: .achievement(),
        remainder: .achievementTarget(90),
        interactionOptions: .achievement
    )
    .presentation(.productCard(selection: .persistentElement))
    .onSelection { selection in
        selectedAnchor = selection.primaryAnchor
    }
```

Use `primaryAnchor` when the product owns the popover UI. Use built-in tooltip
modifiers when the framework should render the callout.

## Recommended Axis Layout Pattern

```swift
YAxisConfig(
    position: .leading,
    showTicks: false,
    labelSpacing: 12,
    labelInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8),
    labelReservedSize: CGSize(width: 56, height: 20),
    labelAlignment: .trailing
)
```

Use `labelSpacing` for distance from the axis/plot area, `labelInsets` for
padding inside the label slot, and `labelReservedSize` when the design reserves
a fixed label column or row.

When the plot marks themselves need breathing room inside the axis frame, use
`plotInsets` instead of compensating with external SwiftUI padding:

```swift
OZChart(samples)
    .line(color: .cyan)
    .axes(x: [bottomAxis], y: [leadingAxis, trailingAxis])
    .plotInsets(top: 0, leading: 8, bottom: 0, trailing: 12)
```

`plotInsets` shrink the drawable plot area and keep axes, grid, annotations,
selection, tooltips, and axis markers aligned to the inset plot.

When the whole axes+plot block should be offset inside a product card, use
`contentInsets` instead. It keeps axes, plot marks, overlays, selection, and
tooltips moving together:

```swift
OZChart(samples)
    .line(color: .cyan)
    .axes(x: [bottomAxis], y: [leadingAxis])
    .contentInsets(leading: 12)
```

## Recommended Axis Marker Pattern

```swift
OZChart(samples)
    .line(color: .green)
    .axisMarkers(
        .x(
            value: daylightSavingTimestamp,
            placement: .bottom,
            offset: CGSize(width: 0, height: 18),
            accessibilityLabel: "Time changed"
        ) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption)
        }
    )
```

Axis markers are a presentation layer. They follow the active viewport and stay
hidden when their value is outside the visible plot range, but they do not
modify domains, ticks, grid lines, or selection hit-testing.

For dense axes, provide compact content and a collision policy:

```swift
OZChart(samples)
    .line(color: .green)
    .axisMarkers(
        .x(
            value: daylightSavingTimestamp,
            placement: .bottom,
            priority: 10,
            collisionStrategy: .automatic,
            compactContent: {
                Image(systemName: "clock")
                    .font(.caption2)
            },
            content: {
                Label("Time changed", systemImage: "clock")
                    .font(.caption)
            }
        )
    )
    .axisMarkerSelection(hitboxRadius: 24, overlapping: .cycle) { markers in
        selectedAxisMarker = markers.first
    }
```

Use `.hideLabel` when compact icon-only content should replace a label,
`.shift` or `.stack` when nearby markers should remain visible, and
`.hideLowerPriority` for low-importance decorations.

## Diagnostics

Attach `.diagnostics { diagnostics in ... }` during QA to surface integration
warnings without parsing console output.

New product-focused codes:

* `axis-layout-warning`
* `plot-area-too-small`
* `selection-missed-hitbox`
* `tooltip-clamped`
* `domain-empty-or-invalid`
* `series-outside-domain`

High-frequency runtime diagnostics are available through the callback but are
kept quiet in debug console output by default.

## Release Gate

Before tagging 3.1, run:

```bash
swift test
swiftlint lint --no-cache
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Also manually smoke-test:

* Star Achievement selection, tooltip placement, and scrolling behavior.
* Star Achievement/product callouts near the right edge with long localized
  labels so tooltips clamp, wrap, and stay above right-side labels.
* Accuracy Overview axis labels, plot border, and violin/secondary-axis layout.
* Real-world scenario charts with scroll-safe selection and diagnostics enabled.
* Product cards after zooming back to the full range and dragging in both axes.
* Explicit axis labels while zoomed, especially secondary axes with transformed
  labels.
