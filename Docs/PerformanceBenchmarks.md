# OZCharts Performance Benchmarks

Performance benchmarks are opt-in so normal development and CI stay fast.

## Command

```bash
RUN_OZCHARTS_PERFORMANCE_TESTS=1 swift test --filter PerformanceBenchmarkTests
```

## Current Local Baseline

Measured on May 15, 2026 in the prerelease 2.1.0 branch:

| Benchmark | Average |
| --- | ---: |
| Dense hit testing | 0.396s |
| Donut element hit-testing | 0.005s |
| Large line layout | 0.006s |
| Live append and trim layout | 0.022s |
| Stacked area layout | 0.003s |
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

## Future CI Recommendation

Keep performance tests optional on every PR, then run them before release tags. If CI becomes noisy, store machine-specific baselines separately instead of failing the main test suite on tiny millisecond-level variance.
