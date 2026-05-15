//
//  ChartDownsampling.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import CoreGraphics

public enum ChartDownsampling: Equatable {
    case none
    case lttb(threshold: Int)
    case automatic(maxPointsPerPixel: CGFloat = 1)

    func threshold(for size: CGSize, pointCount: Int) -> Int? {
        switch self {
        case .none:
            return nil

        case let .lttb(threshold):
            return max(3, min(threshold, pointCount))

        case let .automatic(maxPointsPerPixel):
            guard size.width > 0, maxPointsPerPixel > 0 else { return nil }
            let threshold = Int(size.width * maxPointsPerPixel)
            guard threshold >= 3, pointCount > threshold else { return nil }
            return threshold
        }
    }
}

enum LTTBDownsampler {
    static func downsample<Point: ChartDataPoint>(
        _ contexts: [ChartPointContext<Point>],
        threshold: Int
    ) -> [ChartPointContext<Point>] where Point.XValue == Double, Point.YValue == Double {
        guard threshold >= 3, contexts.count > threshold else { return contexts }

        let sorted = sortedByPositionXIfNeeded(contexts)
        let bucketSize = Double(sorted.count - 2) / Double(threshold - 2)
        var sampled = [sorted[0]]
        var anchorIndex = 0

        for bucketIndex in 0 ..< (threshold - 2) {
            let rangeStart = Int(floor(Double(bucketIndex) * bucketSize)) + 1
            let rangeEnd = Int(floor(Double(bucketIndex + 1) * bucketSize)) + 1
            let currentRange = rangeStart ..< min(rangeEnd, sorted.count - 1)

            let nextRangeStart = Int(floor(Double(bucketIndex + 1) * bucketSize)) + 1
            let nextRangeEnd = Int(floor(Double(bucketIndex + 2) * bucketSize)) + 1
            let nextRange = nextRangeStart ..< min(nextRangeEnd, sorted.count)

            let average = averagePoint(in: nextRange, contexts: sorted)
            let anchor = sorted[anchorIndex].position

            var maxArea: CGFloat = -1
            var selectedIndex = currentRange.lowerBound

            for index in currentRange {
                let point = sorted[index].position
                let lhs = (anchor.x - average.x) * (point.y - anchor.y)
                let rhs = (anchor.x - point.x) * (average.y - anchor.y)
                let area = abs(lhs - rhs) * 0.5

                if area > maxArea {
                    maxArea = area
                    selectedIndex = index
                }
            }

            sampled.append(sorted[selectedIndex])
            anchorIndex = selectedIndex
        }

        sampled.append(sorted[sorted.count - 1])
        return sampled
    }

    private static func averagePoint<Point: ChartDataPoint>(
        in range: Range<Int>,
        contexts: [ChartPointContext<Point>]
    ) -> CGPoint where Point.XValue == Double, Point.YValue == Double {
        guard !range.isEmpty else {
            return contexts.last?.position ?? .zero
        }

        var sumX: CGFloat = 0
        var sumY: CGFloat = 0
        var count: CGFloat = 0

        let lowerBound = max(range.lowerBound, contexts.startIndex)
        let upperBound = min(range.upperBound, contexts.endIndex)
        guard lowerBound < upperBound else {
            return contexts.last?.position ?? .zero
        }

        for index in lowerBound ..< upperBound {
            sumX += contexts[index].position.x
            sumY += contexts[index].position.y
            count += 1
        }

        guard count > 0 else {
            return contexts.last?.position ?? .zero
        }

        return CGPoint(x: sumX / count, y: sumY / count)
    }

    private static func sortedByPositionXIfNeeded<Point: ChartDataPoint>(
        _ contexts: [ChartPointContext<Point>]
    ) -> [ChartPointContext<Point>] where Point.XValue == Double, Point.YValue == Double {
        guard contexts.count > 1 else { return contexts }

        for index in 1 ..< contexts.count where contexts[index].position.x < contexts[index - 1].position.x {
            return contexts.sorted { $0.position.x < $1.position.x }
        }

        return contexts
    }
}
