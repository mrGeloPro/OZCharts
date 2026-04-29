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

    public let id = UUID()
    public var data: [P]
    public var zIndex: Int
    public var animation: ChartAnimationStyle

    public var centerX: Double
    public var maxHalfWidth: CGFloat
    public var sideMapper: (P.GroupID) -> ViolinSide
    public var colorMapper: (P.GroupID) -> Color
    public var groupLabel: ((P.GroupID) -> String?)?

    public var fillOpacity: Double
    public var strokeWidth: CGFloat
    public var showScatter: Bool
    public var scatterSize: CGFloat
    public var scatterOpacity: Double
    public var bandwidth: Double?
    public var sampleCount: Int

    public init(
        data: [P],
        centerX: Double,
        maxHalfWidth: CGFloat                           = 120,
        sideMapper: @escaping (P.GroupID) -> ViolinSide,
        colorMapper: @escaping (P.GroupID) -> Color,
        groupLabel: ((P.GroupID) -> String?)?            = nil,
        fillOpacity: Double                             = 0.35,
        strokeWidth: CGFloat                            = 1,
        showScatter: Bool                               = true,
        scatterSize: CGFloat                            = 5,
        scatterOpacity: Double                          = 0.9,
        bandwidth: Double?                              = nil,
        sampleCount: Int                                = 80,
        animation: ChartAnimationStyle                  = .none,
        zIndex: Int                                     = 0
    ) {
        self.data           = data
        self.centerX        = centerX
        self.maxHalfWidth   = maxHalfWidth
        self.sideMapper     = sideMapper
        self.colorMapper    = colorMapper
        self.groupLabel     = groupLabel
        self.fillOpacity    = fillOpacity
        self.strokeWidth    = strokeWidth
        self.showScatter    = showScatter
        self.scatterSize    = scatterSize
        self.scatterOpacity = scatterOpacity
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

            context.fill(path, with: .color(color.opacity(fillOpacity)))
            if strokeWidth > 0 {
                context.stroke(path, with: .color(color.opacity(0.7)), lineWidth: strokeWidth)
            }

            if showScatter {
                for ctx in groupCtxs {
                    let y = ctx.originalPoint.y
                    let density = kdeDensity(y, data: ys, h: h) / maxDensity
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
        var hasher = Hasher()
        hasher.combine(id)
        let h = hasher.finalize()
        return Double(UInt(bitPattern: h) % 1000) / 1000.0
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
