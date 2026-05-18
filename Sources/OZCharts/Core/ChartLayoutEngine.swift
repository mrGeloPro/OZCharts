//
//  ChartLayoutEngine.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public struct ChartInsets {
    public let top: CGFloat
    public let leading: CGFloat
    public let bottom: CGFloat
    public let trailing: CGFloat

    public init(
        top: CGFloat = 0,
        leading: CGFloat = 0,
        bottom: CGFloat = 0,
        trailing: CGFloat = 0
    ) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
}

public struct ChartPlotLayout: Equatable {
    public let containerSize: CGSize
    public let insets: ChartInsets
    public let plotArea: CGRect

    public init(containerSize: CGSize, insets: ChartInsets) {
        self.containerSize = containerSize
        self.insets = insets
        self.plotArea = ChartLayoutEngine.plotArea(in: containerSize, insets: insets)
    }
}

public enum ChartLayoutEngine {
    public static func insets(xAxes: [XAxisConfig], yAxes: [YAxisConfig]) -> ChartInsets {
        ChartInsets(
            top: xAxes.filter { $0.position == .top }.reduce(0) { $0 + $1.height },
            leading: yAxes.filter { $0.position == .leading }.reduce(0) { $0 + $1.width },
            bottom: xAxes.filter { $0.position == .bottom }.reduce(0) { $0 + $1.height },
            trailing: yAxes.filter { $0.position == .trailing }.reduce(0) { $0 + $1.width }
        )
    }

    public static func measuredInsets(
        xAxes: [XAxisConfig],
        yAxes: [YAxisConfig],
        labelSampleLimit: Int = 12
    ) -> ChartInsets {
        ChartInsets(
            top: xAxes
                .filter { $0.position == .top }
                .reduce(0) { $0 + measuredHeight(for: $1, labelSampleLimit: labelSampleLimit) },
            leading: yAxes
                .filter { $0.position == .leading }
                .reduce(0) { $0 + measuredWidth(for: $1, labelSampleLimit: labelSampleLimit) },
            bottom: xAxes
                .filter { $0.position == .bottom }
                .reduce(0) { $0 + measuredHeight(for: $1, labelSampleLimit: labelSampleLimit) },
            trailing: yAxes
                .filter { $0.position == .trailing }
                .reduce(0) { $0 + measuredWidth(for: $1, labelSampleLimit: labelSampleLimit) }
        )
    }

    public static func plotArea(in size: CGSize, insets: ChartInsets) -> CGRect {
        let origin = CGPoint(
            x: max(0, insets.leading),
            y: max(0, insets.top)
        )
        let width = max(0, size.width - insets.leading - insets.trailing)
        let height = max(0, size.height - insets.top - insets.bottom)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    public static func layout(
        in size: CGSize,
        xAxes: [XAxisConfig],
        yAxes: [YAxisConfig],
        usesMeasuredInsets: Bool = false
    ) -> ChartPlotLayout {
        let resolvedInsets = usesMeasuredInsets
            ? measuredInsets(xAxes: xAxes, yAxes: yAxes)
            : insets(xAxes: xAxes, yAxes: yAxes)
        return ChartPlotLayout(containerSize: size, insets: resolvedInsets)
    }

    private static func measuredHeight(
        for axis: XAxisConfig,
        labelSampleLimit: Int
    ) -> CGFloat {
        guard axis.height > 0 else { return 0 }
        let labelHeight = sampleLabelSizes(
            explicitValues: axis.explicitValues,
            tickCount: axis.tickCount,
            axisTransform: axis.axisTransform,
            formatter: axis.labelFormatter,
            labelSampleLimit: labelSampleLimit
        )
        .map(\.height)
        .max() ?? 0
        let titleHeight = axis.title.map { ChartTextMetrics.estimatedSize(for: $0).height } ?? 0
        let measured = axis.visibleTickLength + axis.labelSpacing + labelHeight + titleHeight
        return max(axis.height, measured.rounded(.up))
    }

    private static func measuredWidth(
        for axis: YAxisConfig,
        labelSampleLimit: Int
    ) -> CGFloat {
        guard axis.width > 0 else { return 0 }
        let labelWidth = sampleLabelSizes(
            explicitValues: axis.explicitValues,
            tickCount: axis.tickCount,
            axisTransform: axis.axisTransform,
            formatter: axis.labelFormatter,
            labelSampleLimit: labelSampleLimit
        )
        .map(\.width)
        .max() ?? 0
        let titleHeight = axis.title.map { ChartTextMetrics.estimatedSize(for: $0).height } ?? 0
        let measured = axis.visibleTickLength + axis.labelSpacing + labelWidth + titleHeight
        return max(axis.width, measured.rounded(.up))
    }

    private static func sampleLabelSizes(
        explicitValues: [Double]?,
        tickCount: Int,
        axisTransform: AxisTransform,
        formatter: (Double) -> String,
        labelSampleLimit: Int
    ) -> [CGSize] {
        let values = explicitValues ?? regularSampleValues(count: tickCount)
        return values
            .prefix(max(1, labelSampleLimit))
            .map { formatter(axisTransform($0)) }
            .map { ChartTextMetrics.estimatedSize(for: $0) }
    }

    private static func regularSampleValues(count: Int) -> [Double] {
        let resolvedCount = max(2, count)
        return (0 ..< resolvedCount).map { index in
            Double(index) / Double(max(1, resolvedCount - 1)) * 1000
        }
    }
}

private extension XAxisConfig {
    var visibleTickLength: CGFloat {
        showTicks ? tickLength : 0
    }
}

private extension YAxisConfig {
    var visibleTickLength: CGFloat {
        showTicks ? tickLength : 0
    }
}

extension ChartInsets: Equatable {}
