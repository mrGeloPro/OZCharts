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

public struct ChartLegendOptions: Equatable {
    public var position: ChartLegendPosition
    public var itemSpacing: CGFloat
    public var rowSpacing: CGFloat
    public var symbolSpacing: CGFloat
    public var symbolSize: CGSize
    public var lineSymbolSize: CGSize
    public var textLineLimit: Int?
    public var itemLimit: Int?
    public var overflowTitlePrefix: String
    public var overflowTitleSuffix: String

    public init(
        position: ChartLegendPosition = .bottom,
        itemSpacing: CGFloat = 12,
        rowSpacing: CGFloat = 8,
        symbolSpacing: CGFloat = 6,
        symbolSize: CGSize = CGSize(width: 8, height: 8),
        lineSymbolSize: CGSize = CGSize(width: 18, height: 3),
        textLineLimit: Int? = 1,
        itemLimit: Int? = nil,
        overflowTitlePrefix: String = "+",
        overflowTitleSuffix: String = " more"
    ) {
        self.position = position
        self.itemSpacing = itemSpacing
        self.rowSpacing = rowSpacing
        self.symbolSpacing = symbolSpacing
        self.symbolSize = symbolSize
        self.lineSymbolSize = lineSymbolSize
        self.textLineLimit = textLineLimit
        self.itemLimit = itemLimit
        self.overflowTitlePrefix = overflowTitlePrefix
        self.overflowTitleSuffix = overflowTitleSuffix
    }

    public static let hidden = ChartLegendOptions(position: .hidden, itemSpacing: 0, rowSpacing: 0)

    public static func compact(
        position: ChartLegendPosition = .bottom,
        itemLimit: Int? = nil
    ) -> ChartLegendOptions {
        ChartLegendOptions(
            position: position,
            itemSpacing: 8,
            rowSpacing: 6,
            symbolSpacing: 5,
            symbolSize: CGSize(width: 7, height: 7),
            lineSymbolSize: CGSize(width: 16, height: 3),
            itemLimit: itemLimit
        )
    }

    public static func dashboard(
        position: ChartLegendPosition = .bottom,
        itemLimit: Int? = nil
    ) -> ChartLegendOptions {
        ChartLegendOptions(
            position: position,
            itemSpacing: 12,
            rowSpacing: 8,
            symbolSpacing: 6,
            symbolSize: CGSize(width: 9, height: 9),
            lineSymbolSize: CGSize(width: 20, height: 3),
            itemLimit: itemLimit
        )
    }

    public func displayedItems(from items: [ChartLegendItem]) -> [ChartLegendItem] {
        guard let itemLimit, items.count > itemLimit else {
            return items
        }

        let visibleCount = max(0, itemLimit)
        let hiddenCount = items.count - visibleCount
        guard hiddenCount > 0 else {
            return Array(items.prefix(visibleCount))
        }

        return Array(items.prefix(visibleCount)) + [
            ChartLegendItem(
                id: Self.overflowID,
                title: overflowTitle(forHiddenCount: hiddenCount),
                color: .secondary,
                symbol: .circle
            )
        ]
    }

    public func overflowTitle(forHiddenCount count: Int) -> String {
        "\(overflowTitlePrefix)\(count)\(overflowTitleSuffix)"
    }

    private static let overflowID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
}

public struct ChartLegendView: View {
    let items: [ChartLegendItem]
    let options: ChartLegendOptions

    public init(
        items: [ChartLegendItem],
        spacing: CGFloat = 12,
        rowSpacing: CGFloat = 8
    ) {
        self.init(
            items: items,
            options: ChartLegendOptions(itemSpacing: spacing, rowSpacing: rowSpacing)
        )
    }

    public init(
        items: [ChartLegendItem],
        options: ChartLegendOptions
    ) {
        self.items = items
        self.options = options
    }

    public var body: some View {
        WrappingHStack(spacing: options.itemSpacing, rowSpacing: options.rowSpacing) {
            ForEach(options.displayedItems(from: items)) { item in
                HStack(spacing: options.symbolSpacing) {
                    legendSymbol(for: item)
                    Text(item.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(options.textLineLimit)
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
                .frame(width: options.lineSymbolSize.width, height: options.lineSymbolSize.height)
                .cornerRadius(1.5)

        case .circle:
            Circle()
                .fill(item.color)
                .frame(width: options.symbolSize.width, height: options.symbolSize.height)

        case .square:
            Rectangle()
                .fill(item.color)
                .frame(width: options.symbolSize.width, height: options.symbolSize.height)
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
