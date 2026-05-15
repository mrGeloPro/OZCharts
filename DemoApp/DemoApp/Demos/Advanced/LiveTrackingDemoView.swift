//
//  LiveTrackingDemoView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI
import OZCharts

// MARK: - Live Telemetry

struct LiveTrackingDemoView: View {
    @State private var data: [Point2D] = []
    @State private var timer: Timer?
    @State private var counter: Double = 0
    @State private var viewport = ChartViewportState.automatic
    @State private var pausedBehavior = ChartLiveTrackingPausedBehavior.freezeVisibleWindow

    private let visibleWindow: Double = 20
    private let historyWindow: Double = 120

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                DemoChartPanel {
                    CartesianChartView(
                        series: [
                            LineSeries(data: data, id: DemoSeriesID.liveTrackingLine, color: DemoColors.green, lineWidth: 3)
                        ],
                        xScale: LinearScale(domain: fullDomain),
                        yScale: LinearScale(domain: 0...100),
                        isLiveTrackingEnabled: true,
                        liveTrackingMode: .followLatest(
                            pauseOnUserInteraction: true,
                            pausedBehavior: pausedBehavior
                        ),
                        initialViewport: .xWindow(length: visibleWindow, anchor: .trailing),
                        viewport: $viewport,
                        emptyState: {
                            AnyView(
                                VStack(spacing: 10) {
                                    ProgressView()
                                    Text("Waiting for signal...")
                                        .font(.subheadline)
                                }
                                .foregroundColor(DemoColors.secondaryText)
                            )
                        },
                        tooltipContent: { points in
                            if let p = points.last {
                                Text("\(Int(p.originalPoint.y))%")
                                    .bold()
                                    .padding(4)
                                    .background(Color.black.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(4)
                            }
                        }
                    )
                    .frame(height: 330)
                }

                Picker("Paused Behavior", selection: $pausedBehavior) {
                    Text("Freeze").tag(ChartLiveTrackingPausedBehavior.freezeVisibleWindow)
                    Text("Delayed").tag(ChartLiveTrackingPausedBehavior.preserveTrailingOffset)
                }
                .pickerStyle(.segmented)

                HStack(spacing: 12) {
                    DemoHint(text: statusText)

                    if viewport.liveTrackingStatus == .pausedByUser {
                        DemoActionButton(
                            title: "Jump to Latest",
                            color: DemoColors.green,
                            action: { viewport.requestJumpToLatest() }
                        )
                        .frame(maxWidth: 180)
                    }
                }

                DemoActionButton(
                    title: timer == nil ? "Start Telemetry" : "Stop",
                    color: timer == nil ? DemoColors.green : DemoColors.pink,
                    action: toggleTimer
                )
                .frame(maxWidth: 260)
            }
            .padding(18)
        }
        .demoScreenBackground()
        .navigationTitle("Live Telemetry")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopTimer()
        }
    }

    var statusText: String {
        switch viewport.liveTrackingStatus {
        case .inactive:
            return "Live tracking inactive"
        case .followingLatest:
            return "Live"
        case .pausedByUser:
            return pausedBehavior == .freezeVisibleWindow ? "Viewing frozen history" : "Viewing delayed live"
        }
    }

    var fullDomain: ClosedRange<Double> {
        let upperBound = max(counter, visibleWindow)
        let lowerBound = max(0, upperBound - historyWindow)
        return lowerBound...upperBound
    }

    func toggleTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                let newPoint = Point2D(x: counter, y: Double.random(in: 40...80))
                data.append(newPoint)
                counter += 0.5
                data.removeAll { $0.x < fullDomain.lowerBound }
            }
        } else {
            stopTimer()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
