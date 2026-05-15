# OZCharts Performance Benchmarks

Performance benchmarks are opt-in so normal development and CI stay fast.

## Command

```bash
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

## Current Local Baseline

Measured on May 15, 2026 in the release 2.5 preparation pass after the render-context split, lazy cached x-index hit-testing, and LTTB downsampling optimization:

| Benchmark | Average |
| --- | ---: |
| Dense hit testing | <0.001s |
| Donut element hit-testing | 0.005s |
| Large line layout | 0.015s |
| Live append and trim layout | 0.041s |
| Stacked area layout | 0.004s |
| Stacked bar selection element generation | 0.005s |

## How To Interpret

Small absolute-duration tests can show high relative standard deviation because the measured operation is only a few milliseconds. Treat these as regression smoke tests, not formal device performance certification.

For release decisions:

* watch for large absolute regressions first;
* re-run benchmarks after major rendering, hit-testing, or viewport changes;
* compare on the same machine and Xcode version when possible;
* manually check simulator scrolling and selection on dense live charts.

## Coverage

The current suite covers:

* dense line layout with automatic downsampling;
* stacked area layout;
* stacked bar selectable-element generation;
* dense point hit-testing;
* live append and trim updates;
* donut segment hit-testing.

## Current Optimization Notes

The point hit-testing path uses a lazily built x-sorted interaction index owned
by `ChartStore`. Layout and live-update paths only invalidate the cache; the
index is built on first point hit-test after layout, so live charts do not pay
index construction cost until interaction needs it. Nearest point, nearest x,
radius selection, selected point restoration, and selected x restoration all use
indexed lookups while preserving full interaction contexts.

Render contexts are now stored separately from full interaction contexts. A
dense line series can render an LTTB-downsampled context set while selection and
viewport state continue to use the full layout contexts. If product charts
regularly exceed hundreds of thousands of visible interactive points, the next
performance step should be a two-dimensional spatial grid for radius-heavy
selection patterns.

## Future CI Recommendation

Keep performance tests optional on every PR, then run them before release tags. If CI becomes noisy, store machine-specific baselines separately instead of failing the main test suite on tiny millisecond-level variance.
