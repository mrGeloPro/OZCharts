//
//  DemoComponents.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

struct ShowcaseMetricCard: View {
    let title: String
    let value: String
    let trend: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundColor(DemoColors.secondaryText)
                .lineLimit(1)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
            Text(trend)
                .font(.caption2.weight(.bold))
                .foregroundColor(color)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(14)
    }
}

enum DemoColors {
    static let background = Color(red: 0.045, green: 0.052, blue: 0.070)
    static let panel = Color(red: 0.075, green: 0.088, blue: 0.115)
    static let surface = Color(red: 0.105, green: 0.122, blue: 0.155)
    static let border = Color.white.opacity(0.08)
    static let secondaryText = Color.white.opacity(0.62)

    static let cyan = Color(red: 0.17, green: 0.82, blue: 0.94)
    static let green = Color(red: 0.32, green: 0.86, blue: 0.54)
    static let orange = Color(red: 1.00, green: 0.62, blue: 0.24)
    static let pink = Color(red: 1.00, green: 0.36, blue: 0.58)
    static let purple = Color(red: 0.62, green: 0.49, blue: 1.00)
}

struct DemoChartPanel<Content: View>: View {
    let minHeight: CGFloat?
    @ViewBuilder let content: Content

    init(minHeight: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .padding(16)
        .background(DemoColors.panel)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DemoColors.border, lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct DemoLegend: View {
    let items: [(String, Color)]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 10)], spacing: 10) {
            ForEach(items, id: \.0) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.1)
                        .frame(width: 10, height: 10)
                    Text(item.0)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DemoHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(DemoColors.secondaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
    }
}

struct DemoActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func demoScreenBackground() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoColors.background.ignoresSafeArea())
    }
}
