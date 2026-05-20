//
//  ChartViewportControls.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct ChartViewportControls: View {
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onZoomOut) {
                Image(systemName: "minus.magnifyingglass")
            }
            Button(action: onZoomIn) {
                Image(systemName: "plus.magnifyingglass")
            }
            Button(action: onReset) {
                Image(systemName: "arrow.counterclockwise")
            }
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}
