# OZCharts 2.0 Release Checklist

## API Surface

* Use `series: [LineSeries(...), ScatterSeries(...)]` as the primary entry point.
* Use `AreaSeries` for filled trends and `BarSeries` for vertical bars.
* Prefer `xDomain` and `yDomain` convenience initializers for simple charts.
* Use `.nice` ticks and `.hideOverlapping(...)` labels for dense axes.
* Use modifiers for optional behavior:
  * `.chartSelection(...)`
  * `.chartAnnotationSelection(...)`
  * `.chartAnnotationTooltip(...)`
  * `.chartCrosshair(...)`
  * `.chartLegend(...)`
  * `.chartAccessibility(...)`
  * `.chartGestures(...)`
  * `.chartLiveTracking(...)`
  * `.chartInitialViewport(...)`
  * `.chartViewport(...)`
  * `.chartSelectionState(...)`
  * `.chartZoomControls(...)`

## Verification

Run before tagging:

```bash
swift test
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Manual visual QA:

* Open DemoApp.
* Verify static line/scatter charts.
* Verify zoom and pan on hybrid charts.
* Verify viewport controls and initial viewport.
* Verify selectable annotations.
* Verify linked charts and shared crosshair.
* Verify area and bar series.
* Verify live chart updates stay synchronized.
* Verify selection, tooltip, crosshair, and legend.
* Verify accessibility labels with VoiceOver.

## Tagging

After verification:

```bash
git tag 2.0.0
git push origin 2.0.0
```
