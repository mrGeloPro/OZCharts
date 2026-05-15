//
//  OZDemoHomeView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct OZDemoHomeView: View {
    private let handoffRoutes: [DemoRoute] = [
        DemoRoute(
            title: "Live Telemetry",
            subtitle: "Streaming data, history scroll and live tracking",
            icon: "waveform.path.ecg",
            tint: DemoColors.green,
            destination: AnyView(LiveTrackingDemoView())
        ),
        DemoRoute(
            title: "Real-world Data",
            subtitle: "JSON event streams adapted into scenarios",
            icon: "list.bullet.rectangle.portrait",
            tint: DemoColors.purple,
            destination: AnyView(RealWorldScenariosView())
        ),
        DemoRoute(
            title: "Violin Accuracy",
            subtitle: "Distribution density, target annotation and dual axes",
            icon: "chart.dots.scatter",
            tint: DemoColors.cyan,
            destination: AnyView(AccuracyDemoView())
        ),
        DemoRoute(
            title: "Stacked Bar",
            subtitle: "Star achievement times with segment details",
            icon: "chart.bar.fill",
            tint: DemoColors.orange,
            destination: AnyView(StarAchievementDemoView())
        ),
        DemoRoute(
            title: "Donut Score",
            subtitle: "Polar score composition and custom legend",
            icon: "circle.dotted",
            tint: DemoColors.purple,
            destination: AnyView(DonutScoreDemoView())
        ),
        DemoRoute(
            title: "Stacked Area",
            subtitle: "Layered step interpolation for point distribution",
            icon: "chart.line.uptrend.xyaxis",
            tint: DemoColors.green,
            destination: AnyView(PointsDistributionDemoView())
        )
    ]

    private let catalogRoutes: [DemoRoute] = [
        DemoRoute(
            title: "All Features",
            subtitle: "Selection, crosshair, viewport, annotations, area and bars",
            icon: "sparkles",
            tint: DemoColors.cyan,
            destination: AnyView(AllFeaturesShowcaseView())
        ),
        DemoRoute(
            title: "Linked Charts",
            subtitle: "Shared selection across multiple charts",
            icon: "link",
            tint: DemoColors.orange,
            destination: AnyView(LinkedChartsDemoView())
        ),
        DemoRoute(
            title: "Selectable Events",
            subtitle: "Tap overlapping markers and custom annotations",
            icon: "cursorarrow.click.2",
            tint: DemoColors.pink,
            destination: AnyView(SelectableAnnotationsDemoView())
        ),
        DemoRoute(
            title: "Line and Empty State",
            subtitle: "Axes, tooltip and no-data UI",
            icon: "chart.xyaxis.line",
            tint: DemoColors.purple,
            destination: AnyView(HeightDemoView())
        ),
        DemoRoute(
            title: "Area + Bar",
            subtitle: "Mixed cartesian composition",
            icon: "chart.bar.xaxis",
            tint: DemoColors.cyan,
            destination: AnyView(AreaAndBarDemoView())
        ),
        DemoRoute(
            title: "Viewport Controls",
            subtitle: "Initial zoom, scroll and programmatic zoom",
            icon: "plus.magnifyingglass",
            tint: DemoColors.green,
            destination: AnyView(ViewportControlsDemoView())
        ),
        DemoRoute(
            title: "Animation",
            subtitle: "Draw, morph and fade transitions",
            icon: "play.circle.fill",
            tint: DemoColors.orange,
            destination: AnyView(AnimationShowcaseView())
        ),
        DemoRoute(
            title: "Hybrid Layers",
            subtitle: "Lines, symbols and custom views",
            icon: "square.3.layers.3d",
            tint: DemoColors.pink,
            destination: AnyView(HybridChartDemoView())
        ),
        DemoRoute(
            title: "Event Stack",
            subtitle: "Multi-layer event markers",
            icon: "square.stack.3d.up.fill",
            tint: DemoColors.pink,
            destination: AnyView(EventStackDemoView())
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero

                MetricsStrip()

                DemoSectionHeader(
                    title: "Handoff Scenarios",
                    subtitle: "Start here when evaluating OZCharts for a product integration."
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: 12)], spacing: 12) {
                    ForEach(handoffRoutes) { route in
                        DemoRouteCard(route: route, style: .featured)
                    }
                }

                DemoSectionHeader(
                    title: "Developer Catalog",
                    subtitle: "Focused screens for each chart type and interaction."
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: 12)], spacing: 12) {
                    ForEach(catalogRoutes) { route in
                        DemoRouteCard(route: route, style: .compact)
                    }
                }
            }
            .padding(18)
        }
        .background(DemoColors.background.ignoresSafeArea())
        .navigationTitle("OZCharts")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        NavigationLink(destination: AllFeaturesShowcaseView()) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("OZCharts 2.1")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        Text("Production-style charting for live data, analytics, events and rich interactions.")
                            .font(.subheadline)
                            .foregroundColor(DemoColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 12)

                    Image(systemName: "arrow.up.right")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(DemoColors.cyan)
                        .frame(width: 36, height: 36)
                        .background(DemoColors.surface)
                        .clipShape(Circle())
                }

                ShowcaseHeroChart()
                    .frame(height: 176)
                    .allowsHitTesting(false)

                HStack(spacing: 8) {
                    FeaturePill(title: "Area", color: DemoColors.cyan)
                    FeaturePill(title: "Bars", color: DemoColors.orange)
                    FeaturePill(title: "Events", color: DemoColors.pink)
                    FeaturePill(title: "Live", color: DemoColors.green)
                }
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.12, green: 0.15, blue: 0.20),
                        Color(red: 0.07, green: 0.08, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DemoColors.border, lineWidth: 1)
            )
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

private struct DemoRoute: Identifiable {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let destination: AnyView

    var id: String { title }
}

private enum DemoRouteCardStyle {
    case featured
    case compact
}

private struct DemoRouteCard: View {
    let route: DemoRoute
    let style: DemoRouteCardStyle

    var body: some View {
        NavigationLink(destination: route.destination) {
            VStack(alignment: .leading, spacing: style == .featured ? 14 : 10) {
                HStack {
                    Image(systemName: route.icon)
                        .font(.headline)
                        .foregroundColor(route.tint)
                        .frame(width: 34, height: 34)
                        .background(route.tint.opacity(0.14))
                        .clipShape(Circle())

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(DemoColors.secondaryText)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(route.title)
                        .font(style == .featured ? .headline : .subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text(route.subtitle)
                        .font(.caption)
                        .foregroundColor(DemoColors.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .frame(minHeight: style == .featured ? 132 : 118, alignment: .topLeading)
            .padding(14)
            .background(DemoColors.panel)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DemoColors.border, lineWidth: 1)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

private struct DemoSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(DemoColors.secondaryText)
        }
    }
}

private struct MetricsStrip: View {
    var body: some View {
        HStack(spacing: 10) {
            ShowcaseMetricCard(title: "Series", value: "8", trend: "types", color: DemoColors.cyan)
            ShowcaseMetricCard(title: "Input", value: "Touch", trend: "zoom", color: DemoColors.green)
            ShowcaseMetricCard(title: "Release", value: "2.1", trend: "pre", color: DemoColors.orange)
        }
    }
}
