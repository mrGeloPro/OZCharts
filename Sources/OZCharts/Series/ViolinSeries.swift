//
//  ViolinSeries.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public enum ViolinSide {
    case left
    case right
    case both
}

public struct ViolinSeries<P: GroupedChartDataPoint>: ChartSeriesProtocol
where P.XValue == Double, P.YValue == Double {

    public let id: UUID
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle

    public var centerX: Double
    public var maxHalfWidth: CGFloat
    public var sideMapper: (P.GroupID) -> ViolinSide
    public var colorMapper: (P.GroupID) -> Color
    public var fillStyleMapper: ((P.GroupID) -> ChartFillStyle)?
    public var groupLabel: ((P.GroupID) -> String?)?

    public var fillOpacity: Double
    public var strokeWidth: CGFloat
    public var showScatter: Bool
    public var scatterSize: CGFloat
    public var scatterOpacity: Double
    public var shadow: ChartShadowStyle?
    public var bandwidth: Double?
    public var sampleCount: Int

    public init(
        data: [P],
        id: UUID = UUID(),
        centerX: Double,
        maxHalfWidth: CGFloat                           = 120,
        sideMapper: @escaping (P.GroupID) -> ViolinSide,
        colorMapper: @escaping (P.GroupID) -> Color,
        fillStyleMapper: ((P.GroupID) -> ChartFillStyle)? = nil,
        groupLabel: ((P.GroupID) -> String?)?            = nil,
        fillOpacity: Double                             = 0.35,
        strokeWidth: CGFloat                            = 1,
        showScatter: Bool                               = true,
        scatterSize: CGFloat                            = 5,
        scatterOpacity: Double                          = 0.9,
        shadow: ChartShadowStyle?                       = nil,
        bandwidth: Double?                              = nil,
        sampleCount: Int                                = 80,
        animation: ChartAnimationStyle                  = .none,
        zIndex: Int                                     = 0
    ) {
        self.id             = id
        self.data           = data
        self.centerX        = centerX
        self.maxHalfWidth   = maxHalfWidth
        self.sideMapper     = sideMapper
        self.colorMapper    = colorMapper
        self.fillStyleMapper = fillStyleMapper
        self.groupLabel     = groupLabel
        self.fillOpacity    = fillOpacity
        self.strokeWidth    = strokeWidth
        self.showScatter    = showScatter
        self.scatterSize    = scatterSize
        self.scatterOpacity = scatterOpacity
        self.shadow         = shadow
        self.bandwidth      = bandwidth
        self.sampleCount    = sampleCount
        self.animation      = animation
        self.zIndex         = zIndex
    }

    public var legendItems: [ChartLegendItem] {
        guard let groupLabel else { return [] }
        return orderedGroups.compactMap { group in
            guard let title = groupLabel(group) else { return nil }
            return ChartLegendItem(title: title, color: colorMapper(group), symbol: .square)
        }
    }

    public func render(
        into context: inout GraphicsContext,
        contexts: [ChartPointContext<P>],
        size: CGSize
    ) {
        guard !contexts.isEmpty else { return }
        guard let scaleYRef = contexts.first?.scaleY else { return }
        guard let scaleXRef = contexts.first?.scaleX else { return }

        let centerScreenX = scaleXRef(centerX)

       
        var grouped: [P.GroupID: [ChartPointContext<P>]] = [:]
        for ctx in contexts {
            grouped[ctx.originalPoint.group, default: []].append(ctx)
        }

        let allY = contexts.map { $0.originalPoint.y }
        guard let yMin = allY.min(), let yMax = allY.max(), yMax > yMin else { return }

        let pad = (yMax - yMin) * 0.08
        let yLo = yMin - pad
        let yHi = yMax + pad

        for (groupID, groupCtxs) in grouped {
            let ys = groupCtxs.map { $0.originalPoint.y }
            guard ys.count >= 2 else { continue }

            let h = bandwidth ?? silvermanBandwidth(ys)
            guard h > 0 else { continue }

            var samples: [(y: Double, density: Double)] = []
            samples.reserveCapacity(sampleCount)
            let step = (yHi - yLo) / Double(max(1, sampleCount - 1))
            for i in 0..<sampleCount {
                let y = yLo + Double(i) * step
                samples.append((y, kdeDensity(y, data: ys, h: h)))
            }
            let maxDensity = samples.map(\.density).max() ?? 0
            guard maxDensity > 0 else { continue }

            let side = sideMapper(groupID)
            let color = colorMapper(groupID)
            var path = Path()

            func edgeX(density: Double, onLeft: Bool) -> CGFloat {
                let halfW = CGFloat(density / maxDensity) * maxHalfWidth
                return onLeft ? (centerScreenX - halfW) : (centerScreenX + halfW)
            }

            switch side {
            case .right:
                path.move(to: CGPoint(x: edgeX(density: samples[0].density, onLeft: false),
                                      y: scaleYRef(samples[0].y)))
                for s in samples.dropFirst() {
                    path.addLine(to: CGPoint(x: edgeX(density: s.density, onLeft: false),
                                             y: scaleYRef(s.y)))
                }
                path.addLine(to: CGPoint(x: centerScreenX, y: scaleYRef(samples.last!.y)))
                path.addLine(to: CGPoint(x: centerScreenX, y: scaleYRef(samples.first!.y)))

            case .left:
                path.move(to: CGPoint(x: edgeX(density: samples[0].density, onLeft: true),
                                      y: scaleYRef(samples[0].y)))
                for s in samples.dropFirst() {
                    path.addLine(to: CGPoint(x: edgeX(density: s.density, onLeft: true),
                                             y: scaleYRef(s.y)))
                }
                path.addLine(to: CGPoint(x: centerScreenX, y: scaleYRef(samples.last!.y)))
                path.addLine(to: CGPoint(x: centerScreenX, y: scaleYRef(samples.first!.y)))

            case .both:
                path.move(to: CGPoint(x: edgeX(density: samples[0].density, onLeft: false),
                                      y: scaleYRef(samples[0].y)))
                for s in samples.dropFirst() {
                    path.addLine(to: CGPoint(x: edgeX(density: s.density, onLeft: false),
                                             y: scaleYRef(s.y)))
                }
                for s in samples.reversed() {
                    path.addLine(to: CGPoint(x: edgeX(density: s.density, onLeft: true),
                                             y: scaleYRef(s.y)))
                }
            }
            path.closeSubpath()

            let fillStyle = fillStyleMapper?(groupID) ?? .color(color.opacity(fillOpacity))
            let rect = CGRect(origin: .zero, size: size)
            if let shadow {
                context.drawLayer { layer in
                    layer.addFilter(.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y))
                    layer.fill(path, with: fillStyle, in: rect)
                }
            } else {
                context.fill(path, with: fillStyle, in: rect)
            }
            if strokeWidth > 0 {
                context.stroke(path, with: .color(color.opacity(0.7)), lineWidth: strokeWidth)
            }

            if showScatter {
                for ctx in groupCtxs {
                    let y = ctx.originalPoint.y
                    let density = interpolatedDensity(at: y, samples: samples) / maxDensity
                    let halfW = CGFloat(density) * maxHalfWidth
                    let screenY = scaleYRef(y)
                    let jitter = deterministicJitter(for: ctx.originalPoint.id)
                    let offset: CGFloat
                    switch side {
                    case .left:  offset = -halfW * CGFloat(jitter)
                    case .right: offset =  halfW * CGFloat(jitter)
                    case .both:  offset = halfW * CGFloat(jitter * 2 - 1)
                    }
                    let dotX = centerScreenX + offset
                    let rect = CGRect(
                        x: dotX - scatterSize / 2,
                        y: screenY - scatterSize / 2,
                        width: scatterSize,
                        height: scatterSize
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(color.opacity(scatterOpacity))
                    )
                }
            }
        }
    }

    // MARK: - KDE math

    func kdeDensity(_ y: Double, data: [Double], h: Double) -> Double {
        let n = Double(data.count)
        guard n > 0, h > 0 else { return 0 }
        let coef = 1.0 / (n * h * sqrt(2.0 * .pi))
        var sum = 0.0
        for yi in data {
            let u = (y - yi) / h
            sum += exp(-0.5 * u * u)
        }
        return coef * sum
    }

    func silvermanBandwidth(_ data: [Double]) -> Double {
        let n = Double(data.count)
        guard n > 1 else { return 1 }
        let mean = data.reduce(0, +) / n
        let variance = data.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / n
        let sigma = sqrt(variance)
        guard sigma > 0 else { return 1 }
        return 1.06 * sigma * pow(n, -1.0 / 5.0)
    }

    func deterministicJitter(for id: UUID) -> Double {
        let bytes = withUnsafeBytes(of: id.uuid) { Array($0) }
        let hash = bytes.reduce(UInt64(14_695_981_039_346_656_037)) { partial, byte in
            (partial ^ UInt64(byte)) &* 1_099_511_628_211
        }
        return Double(hash % 1_000) / 1_000.0
    }

    func interpolatedDensity(at y: Double, samples: [(y: Double, density: Double)]) -> Double {
        guard let first = samples.first else { return 0 }
        guard y > first.y else { return first.density }
        guard let last = samples.last, y < last.y else { return samples.last?.density ?? 0 }

        var lowerIndex = 0
        var upperIndex = samples.count - 1
        while lowerIndex + 1 < upperIndex {
            let midIndex = (lowerIndex + upperIndex) / 2
            if samples[midIndex].y <= y {
                lowerIndex = midIndex
            } else {
                upperIndex = midIndex
            }
        }

        let lower = samples[lowerIndex]
        let upper = samples[upperIndex]
        let span = upper.y - lower.y
        guard span > 0 else { return lower.density }

        let progress = (y - lower.y) / span
        return lower.density + (upper.density - lower.density) * progress
    }

    private var orderedGroups: [P.GroupID] {
        var seen = Set<P.GroupID>()
        var groups: [P.GroupID] = []
        for point in data where !seen.contains(point.group) {
            seen.insert(point.group)
            groups.append(point.group)
        }
        return groups
    }
}
