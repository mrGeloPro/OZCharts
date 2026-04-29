//
//  ChartLegend.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public enum ChartLegendSymbol: Equatable {
    case line
    case circle
    case square
}

public struct ChartLegendItem: Identifiable {
    public let id: UUID
    public var title: String
    public var color: Color
    public var symbol: ChartLegendSymbol

    public init(
        id: UUID = UUID(),
        title: String,
        color: Color,
        symbol: ChartLegendSymbol = .line
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.symbol = symbol
    }
}

public enum ChartLegendPosition: Equatable {
    case hidden
    case top
    case bottom
    case leading
    case trailing
}

public struct ChartLegendView: View {
    let items: [ChartLegendItem]
    let spacing: CGFloat
    let rowSpacing: CGFloat

    public init(
        items: [ChartLegendItem],
        spacing: CGFloat = 12,
        rowSpacing: CGFloat = 8
    ) {
        self.items = items
        self.spacing = spacing
        self.rowSpacing = rowSpacing
    }

    public var body: some View {
        WrappingHStack(spacing: spacing, rowSpacing: rowSpacing) {
            ForEach(items) { item in
                HStack(spacing: 6) {
                    legendSymbol(for: item)
                    Text(item.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    @ViewBuilder
    private func legendSymbol(for item: ChartLegendItem) -> some View {
        switch item.symbol {
        case .line:
            Rectangle()
                .fill(item.color)
                .frame(width: 18, height: 3)
                .cornerRadius(1.5)

        case .circle:
            Circle()
                .fill(item.color)
                .frame(width: 8, height: 8)

        case .square:
            Rectangle()
                .fill(item.color)
                .frame(width: 8, height: 8)
        }
    }
}

private struct WrappingHStack<Content: View>: View {
    let spacing: CGFloat
    let rowSpacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(minHeight: 20)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0

        return ZStack(alignment: .topLeading) {
            content
                .padding(.trailing, spacing)
                .padding(.bottom, rowSpacing)
                .alignmentGuide(.leading) { dimensions in
                    if abs(width - dimensions.width) > geometry.size.width {
                        width = 0
                        height -= dimensions.height + rowSpacing
                    }

                    let result = width
                    if dimensions.width > 0 {
                        width -= dimensions.width + spacing
                    }
                    return result
                }
                .alignmentGuide(.top) { _ in
                    height
                }
        }
    }
}
