# Troubleshooting

Resolve common integration issues when using OZCharts through Swift Package Manager and Xcode.

## Stale Package Or Module Cache

After updating OZCharts, Xcode can occasionally keep an older Swift module or
package resolution result. This can look like a valid API does not exist even
though the package version contains it.

Try these steps in order:

1. In Xcode, choose **File > Packages > Reset Package Caches**.
2. Choose **File > Packages > Resolve Package Versions**.
3. Choose **Product > Clean Build Folder**.
4. If Xcode still reports stale symbols, close Xcode and remove the app's
   DerivedData folder.

## Layout Looks Different From Figma

Use explicit layout controls before reaching for custom overlays:

```swift
YAxisConfig(
    position: .leading,
    showTicks: false,
    labelSpacing: 12,
    labelInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4),
    labelReservedSize: CGSize(width: 72, height: 20),
    labelAlignment: .trailing
)
```

For plot-area borders, prefer `.plotBorder(...)` over a fake top axis or a
border annotation.

## Selection Or Tooltip Feels Wrong

For scrollable product screens, prefer a selection preset that does not select
far-away content when a user starts a scroll:

```swift
OZChart(samples)
    .selection(.scrollSafeNearestX)
    .onSelection { selection in
        let anchor = selection.primaryAnchor
        let position = selection.primaryPosition
    }
```

Use `.diagnostics { diagnostics in ... }` while tuning a screen. Useful runtime
codes include `selection-missed-hitbox` and `tooltip-clamped`.

## Invalid Or Surprising Data

Run ``ChartDiagnostics`` in tests or QA builds when integrating real product
data. It can flag empty domains, non-finite points, duplicate ids, small plot
areas, and series values outside the configured domain.

```swift
let diagnostics = ChartDiagnostics.validate(
    series: series,
    canvasSize: CGSize(width: 390, height: 260),
    plotAreaSize: CGSize(width: 300, height: 220),
    xDomain: 0 ... 24,
    yDomain: 40 ... 220
)
```
