# DemoApp QA Guide

Use this checklist when validating the demo before sharing OZCharts with an external team.

## Automated Checks

```bash
swiftlint lint --no-cache
swift test
xcodebuild -project DemoApp/DemoApp.xcodeproj -scheme DemoApp -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

`DemoAppStructureTests` protects the demo from drifting back into a single large file and verifies that the main handoff routes remain visible.

## Manual Screens

Check these first:

* Live Telemetry
* Real-world Data
* Violin Accuracy
* Stacked Bar
* Donut Score
* Stacked Area
* All Features
* Viewport Controls
* Selectable Events

## Interaction QA

Verify:

* stacked achievement tooltip arrow points to the tapped segment;
* top rows show the callout below and lower rows show it above;
* violin target label stays readable and does not cover dense points;
* donut spacing and exploded segments match the configured values;
* live charts do not jump when the user scrolls into history;
* "Jump to Latest" resumes following the newest data;
* linked charts share selection without fighting user gestures;
* annotation tooltips stay clamped inside the chart card;
* empty-state screen renders without console warnings from our code.

## Device Matrix

Minimum manual pass:

* compact iPhone simulator;
* large iPhone simulator;
* light/dark contrast if the host product changes theme;
* VoiceOver summary on at least one product chart and one live chart.
