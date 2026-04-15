//
//  CartesianChartView.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import SwiftUI

/// A high-performance, highly customizable charting view built on SwiftUI `Canvas`.
///
/// `CartesianChartView` supports independent zooming and panning across axes,
/// live data tracking, off-screen culling, and complex chart types such as Violin and Stacked Bars.
public struct CartesianChartView<Point: ChartDataPoint, XScale: Scale, YScale: Scale, TooltipContent: View>: View
where XScale.InputType == Point.XValue, XScale.OutputType == CGFloat,
      YScale.InputType == Point.YValue, YScale.OutputType == CGFloat,
      Point.XValue == Double, Point.YValue == Double {
    
    let data: [Point]
    let type: ChartType<Point>
    
    let xAxes: [XAxisConfig]
    let yAxes: [YAxisConfig]
    let horizontalAnnotations: [HorizontalAnnotation]
    let pointAnnotations: [PointAnnotation<Point.XValue, Point.YValue>]
    let customViewAnnotations: [CustomViewAnnotation<Point.XValue, Point.YValue>]
    let animationStyle: ChartAnimationStyle
    
    public var isHorizontalScrollEnabled: Bool
    public var isVerticalScrollEnabled: Bool
    public var isHorizontalZoomEnabled: Bool
    public var isVerticalZoomEnabled: Bool
    public var isLiveTrackingEnabled: Bool
    public var emptyState: (() -> AnyView)?
    
    public var hitboxRadius: CGFloat = 20
    public var tooltipOffset: CGPoint = CGPoint(x: 0, y: -20)
    public var minZoomScale: Double = 0.01
    
    let tooltipContent: ([ChartPointContext<Point>]) -> TooltipContent
    
    let baseXScale: XScale
    let baseYScale: YScale
    @State private var activeXScale: XScale
    @State private var activeYScale: YScale
    
    @State private var oldPointContexts: [ChartPointContext<Point>] = []
    @State private var pointContexts: [ChartPointContext<Point>] = []
    @State private var animationProgress: CGFloat = 1.0
    
    @State private var highlightedPoints: [ChartPointContext<Point>] = []
    @State private var violinBackgrounds: [AnyHashable: Path] = [:]
    
    // Gesture states and performance optimization
    @State private var visibleXDomain: ClosedRange<Double>?
    @State private var dragStartDomain: ClosedRange<Double>?
    @State private var zoomStartDomain: ClosedRange<Double>?
    
    @State private var visibleYDomain: ClosedRange<Double>?
    @State private var dragStartYDomain: ClosedRange<Double>?
    @State private var zoomStartYDomain: ClosedRange<Double>?
    
    @State private var isDraggingChart = false
    
    @State private var canvasSize: CGSize = .zero
    @State private var updateCounter: Int = 0
    
    public init(
        data: [Point], type: ChartType<Point>, xScale: XScale, yScale: YScale,
        xAxes: [XAxisConfig] = [.init(position: .bottom)], yAxes: [YAxisConfig] = [.init(position: .leading)],
        horizontalAnnotations: [HorizontalAnnotation] = [],
        pointAnnotations: [PointAnnotation<Point.XValue, Point.YValue>] = [],
        customViewAnnotations: [CustomViewAnnotation<Point.XValue, Point.YValue>] = [],
        animationStyle: ChartAnimationStyle = .none,
        isHorizontalScrollEnabled: Bool = true,
        isHorizontalZoomEnabled: Bool = true,
        isVerticalScrollEnabled: Bool = true,
        isVerticalZoomEnabled: Bool = true,
        isLiveTrackingEnabled: Bool = false,
        emptyState: (() -> AnyView)? = nil,
        @ViewBuilder tooltipContent: @escaping ([ChartPointContext<Point>]) -> TooltipContent
    ) {
        self.data = data; self.type = type
        self.baseXScale = xScale; self.baseYScale = yScale
        self._activeXScale = State(initialValue: xScale); self._activeYScale = State(initialValue: yScale)
        self.xAxes = xAxes; self.yAxes = yAxes
        self.horizontalAnnotations = horizontalAnnotations;
        self.animationStyle = animationStyle
        self.pointAnnotations = pointAnnotations
        self.customViewAnnotations = customViewAnnotations
        self.isHorizontalScrollEnabled = isHorizontalScrollEnabled
        self.isHorizontalZoomEnabled = isHorizontalZoomEnabled
        self.isVerticalScrollEnabled = isVerticalScrollEnabled
        self.isVerticalZoomEnabled = isVerticalZoomEnabled
        self.isLiveTrackingEnabled = isLiveTrackingEnabled
        self.emptyState = emptyState
        self.tooltipContent = tooltipContent
    }
    
    private var visiblePointAnnotations: [PointAnnotation<Point.XValue, Point.YValue>] {
        let currentXDomain = activeXScale.domain 
        let bufferX = (currentXDomain.upperBound - currentXDomain.lowerBound) * 0.1
        return pointAnnotations.filter {
            let xDouble = $0.x 
            return xDouble >= (currentXDomain.lowerBound - bufferX) && xDouble <= (currentXDomain.upperBound + bufferX)
        }
    }
    
    private var visibleCustomViewAnnotations: [CustomViewAnnotation<Point.XValue, Point.YValue>] {
        let currentXDomain = activeXScale.domain 
        let bufferX = (currentXDomain.upperBound - currentXDomain.lowerBound) * 0.1
        return customViewAnnotations.filter {
            let xDouble = $0.x 
            return xDouble >= (currentXDomain.lowerBound - bufferX) && xDouble <= (currentXDomain.upperBound + bufferX)
        }
    }
    
    public var body: some View {
        if data.isEmpty, let emptyView = emptyState?() {
                    emptyView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let topHeight = xAxes.filter { $0.position == .top }.reduce(0) { $0 + $1.height }
            let bottomHeight = xAxes.filter { $0.position == .bottom }.reduce(0) { $0 + $1.height }
            
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<yAxes.count, id: \.self) { i in
                        if yAxes[i].position == .leading {
                            YAxisView(scale: activeYScale, config: yAxes[i]).frame(width: yAxes[i].width)
                        }
                    }
                }
                .padding(.top, topHeight).padding(.bottom, bottomHeight)
                
                VStack(spacing: 0) {
                    ForEach(0..<xAxes.count, id: \.self) { i in
                        if xAxes[i].position == .top {
                            XAxisView(scale: activeXScale, config: xAxes[i]).frame(height: xAxes[i].height)
                        }
                    }
                    
                    GeometryReader { geometry in
                        chartCanvas(size: geometry.size)
                            .contentShape(Rectangle())
                            .gesture(chartGestures())
                            .onAppear {
                                canvasSize = geometry.size
                                queueUpdate(in: geometry.size, animate: false)
                            }
                            .onChange(of: geometry.size) { newSize in
                                canvasSize = newSize
                                queueUpdate(in: newSize, animate: false)
                            }
                    }
                    
                    ForEach(0..<xAxes.count, id: \.self) { i in
                        if xAxes[i].position == .bottom {
                            XAxisView(scale: activeXScale, config: xAxes[i]).frame(height: xAxes[i].height)
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<yAxes.count, id: \.self) { i in
                        if yAxes[i].position == .trailing {
                            YAxisView(scale: activeYScale, config: yAxes[i]).frame(width: yAxes[i].width)
                        }
                    }
                }
                .padding(.top, topHeight).padding(.bottom, bottomHeight)
            }
            .onChange(of: data.map(\.id)) { _ in
                if isLiveTrackingEnabled {
                    // LIVE TRACKING MODE
                    // 1. If zoomed in and not currently panning, auto-scroll to the newest data point
                    if !isDraggingChart, let currentDomain = visibleXDomain {
                        let currentWindowWidth = currentDomain.upperBound - currentDomain.lowerBound
                        let newGlobalMax = (baseXScale.domain).upperBound
                        let newDomain = (newGlobalMax - currentWindowWidth)...newGlobalMax
                        visibleXDomain = newDomain
                        
                        if var newScaleX = LinearScale(domain: newDomain) as? XScale {
                            newScaleX.range = activeXScale.range
                            newScaleX.isReversed = activeXScale.isReversed
                            activeXScale = newScaleX
                        }
                    }
                    // 2. If at 100% zoom, simply adopt the new base scale
                    else if visibleXDomain == nil {
                        activeXScale = baseXScale
                    }
                    // 3. Ignore auto-scroll if the user is actively panning (isDraggingChart == true)
                } else {
                    visibleXDomain = nil
                    activeXScale = baseXScale
                }
                queueUpdate(in: canvasSize, animate: animationStyle.swiftUIAnimation != nil)
            }
        }
    }
    
    @ViewBuilder
    private func chartCanvas(size: CGSize) -> some View {
        ZStack {
            Canvas { context, size in
                for axis in xAxes where axis.showGrid {
                    let ticks = axis.explicitValues?.map { activeXScale.scale($0) } ?? activeXScale.ticks(count: axis.tickCount, formatter: { _ in "" }).map { $0.position }
                    for xPos in ticks {
                        var path = Path()
                        path.move(to: CGPoint(x: xPos, y: 0))
                        path.addLine(to: CGPoint(x: xPos, y: size.height))
                        context.stroke(path, with: .color(axis.gridColor), style: StrokeStyle(lineWidth: axis.gridLineWidth, dash: axis.gridLineDash))
                    }
                }
                for axis in yAxes where axis.showGrid {
                    let ticks = axis.explicitValues?.map { activeYScale.scale($0) } ?? activeYScale.ticks(count: axis.tickCount, formatter: { _ in "" }).map { $0.position }
                    for yTick in ticks {
                        let yPos = size.height - yTick
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: yPos))
                        path.addLine(to: CGPoint(x: size.width, y: yPos))
                        context.stroke(path, with: .color(axis.gridColor), style: StrokeStyle(lineWidth: axis.gridLineWidth, dash: axis.gridLineDash))
                    }
                }
                
                if case .violin(_, _, _, _, _, _, _, let colorMapper) = type {
                    for (groupId, path) in violinBackgrounds {
                        context.fill(path, with: .color(colorMapper(groupId).opacity(0.4)))
                        context.stroke(path, with: .color(colorMapper(groupId)), lineWidth: 1)
                    }
                }
                
                for annotation in horizontalAnnotations {
                        let yValue = annotation.yValue
                        let yPos = size.height - activeYScale.scale(yValue)
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: yPos))
                        path.addLine(to: CGPoint(x: size.width, y: yPos))
                        context.stroke(path, with: .color(annotation.color), style: StrokeStyle(lineWidth: annotation.lineWidth, dash: annotation.dash))
                }
                
                for annotation in visiblePointAnnotations {
                    let xPos = activeXScale.scale(annotation.x)
                    let yPos = size.height - activeYScale.scale(annotation.y)
                    
                    if xPos >= -annotation.size && xPos <= size.width + annotation.size {
                        let rect = CGRect(
                            x: xPos - annotation.size / 2,
                            y: yPos - annotation.size / 2,
                            width: annotation.size,
                            height: annotation.size
                        )
                        let path = annotation.shape.path(in: rect)
                        
                        context.fill(path, with: .color(annotation.color))
                        context.stroke(path, with: .color(annotation.strokeColor), lineWidth: annotation.strokeWidth)
                    }
                }
                
                switch type {
                case .donut(let thickness, let colors):
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2 - thickness / 2
                    let total = data.reduce(0) { $0 + $1.y }
                    var startAngle = Angle.zero
                    for (index, point) in data.enumerated() {
                        let endAngle = startAngle + Angle(degrees: (point.y / total) * 360)
                        var path = Path()
                        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                        context.stroke(path, with: .color(colors[index % colors.count]), lineWidth: thickness)
                        startAngle = endAngle
                    }
                case .groupedArea(let lineWidth, let fillOpacity, let interpolation, let groupMapper, let colorMapper, let zOrder):
                    var groupedPoints: [AnyHashable: [ChartPointContext<Point>]] = [:]
                    for ctx in pointContexts { groupedPoints[groupMapper(ctx.originalPoint), default: []].append(ctx) }
                    for groupId in zOrder {
                        guard var points = groupedPoints[groupId], !points.isEmpty else { continue }
                        points.sort { $0.position.x < $1.position.x }
                        var linePath = Path()
                        linePath.move(to: points[0].position)
                        for i in 1..<points.count {
                            if interpolation == .step { linePath.addLine(to: CGPoint(x: points[i].position.x, y: points[i-1].position.y)) }
                            linePath.addLine(to: points[i].position)
                        }
                        var areaPath = linePath
                        areaPath.addLine(to: CGPoint(x: points.last!.position.x, y: size.height))
                        areaPath.addLine(to: CGPoint(x: points.first!.position.x, y: size.height))
                        areaPath.closeSubpath()
                        context.fill(areaPath, with: .color(colorMapper(groupId).opacity(fillOpacity)))
                        context.stroke(linePath, with: .color(colorMapper(groupId)), style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
                    }
                case .stackedHorizontalBar(let barHeight, let cornerRadius, let strokeColor, let strokeWidth, let stackMapper, let colorMapper, let stackOrder):
                    var rows: [Double: [ChartPointContext<Point>]] = [:]
                    for ctx in pointContexts { rows[ctx.originalPoint.y, default: []].append(ctx) }
                    for (yValue, pointsInRow) in rows {
                        let sortedPoints = pointsInRow.sorted { p1, p2 in
                            let i1 = stackOrder.firstIndex(of: stackMapper(p1.originalPoint)) ?? 0
                            let i2 = stackOrder.firstIndex(of: stackMapper(p2.originalPoint)) ?? 0
                            return i1 < i2
                        }
                        var currentX: CGFloat = activeXScale.scale(0)
                        let yPos = size.height - activeYScale.scale(yValue)
                        for ctx in sortedPoints {
                            let physicalWidth = activeXScale.scale(ctx.originalPoint.x) - activeXScale.scale(0)
                            let rect = CGRect(x: currentX, y: yPos - barHeight / 2, width: physicalWidth, height: barHeight)
                            let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
                            context.fill(path, with: .color(colorMapper(stackMapper(ctx.originalPoint))))
                            context.stroke(path, with: .color(strokeColor), lineWidth: strokeWidth)
                            currentX += physicalWidth
                        }
                    }
                case .violin(let pointSize, _, _, _, _, let groupMapper, _, let colorMapper):
                    for point in pointContexts {
                        let rect = CGRect(x: point.position.x - pointSize/2, y: point.position.y - pointSize/2, width: pointSize, height: pointSize)
                        context.fill(Path(ellipseIn: rect), with: .color(colorMapper(groupMapper(point.originalPoint))))
                    }
                default: break
                }
            }
            
            if case .line(let lineWidth, let color) = type {
                AnimatableChartLayer(oldPoints: oldPointContexts.map(\.position), newPoints: pointContexts.map(\.position), progress: animationProgress, animationStyle: animationStyle, lineColor: color, lineWidth: lineWidth, drawLine: true, drawDots: false)
            } else if case .scatter(let pointSize, let color) = type {
                AnimatableChartLayer(oldPoints: oldPointContexts.map(\.position), newPoints: pointContexts.map(\.position), progress: animationProgress, animationStyle: animationStyle, lineColor: color, lineWidth: pointSize, drawLine: false, drawDots: true)
            }
            
            ForEach(visibleCustomViewAnnotations) { annotation in
                let xPos = activeXScale.scale(annotation.x)
                let yPos = size.height - activeYScale.scale(annotation.y)
                
                if xPos >= -50 && xPos <= size.width + 50 {
                    annotation.content
                        .position(x: xPos, y: yPos)
                }
            }
            
            if !highlightedPoints.isEmpty {
                let avgX = highlightedPoints.map(\.position.x).reduce(0, +) / CGFloat(highlightedPoints.count)
                let avgY = highlightedPoints.map(\.position.y).reduce(0, +) / CGFloat(highlightedPoints.count)
                tooltipContent(highlightedPoints)
                    .position(x: avgX + tooltipOffset.x, y: avgY + tooltipOffset.y)
            }
        }.clipped()
    }
    
    private func chartGestures() -> some Gesture {
        let globalXDomain = baseXScale.domain 
        let globalYDomain = baseYScale.domain 
        
        
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                let isMoving = abs(value.translation.width) > 5 || abs(value.translation.height) > 5

                if (isHorizontalScrollEnabled || isVerticalScrollEnabled) && isMoving {
                    isDraggingChart = true
                    highlightedPoints = []
                    
                    if isHorizontalScrollEnabled {
                        let currentXDomain = visibleXDomain ?? activeXScale.domain 
                        if dragStartDomain == nil { dragStartDomain = currentXDomain }
                        if let startXDomain = dragStartDomain {
                            let rangeX = startXDomain.upperBound - startXDomain.lowerBound
                            let shiftX = -(value.translation.width / canvasSize.width) * rangeX
                            
                            var newMinX = startXDomain.lowerBound + shiftX
                            var newMaxX = startXDomain.upperBound + shiftX
                            
                            if newMinX < globalXDomain.lowerBound {
                                let corr = globalXDomain.lowerBound - newMinX
                                newMinX += corr; newMaxX += corr
                            }
                            if newMaxX > globalXDomain.upperBound {
                                let corr = newMaxX - globalXDomain.upperBound
                                newMinX -= corr; newMaxX -= corr
                            }
                            visibleXDomain = max(globalXDomain.lowerBound, newMinX)...min(globalXDomain.upperBound, newMaxX)
                        }
                    }
                    
                    if isVerticalScrollEnabled {
                        let currentYDomain = visibleYDomain ?? activeYScale.domain 
                        if dragStartYDomain == nil { dragStartYDomain = currentYDomain }
                        if let startYDomain = dragStartYDomain {
                            let rangeY = startYDomain.upperBound - startYDomain.lowerBound
                            let shiftY = (value.translation.height / canvasSize.height) * rangeY
                            
                            var newMinY = startYDomain.lowerBound + shiftY
                            var newMaxY = startYDomain.upperBound + shiftY
                            
                            if newMinY < globalYDomain.lowerBound {
                                let corr = globalYDomain.lowerBound - newMinY
                                newMinY += corr; newMaxY += corr
                            }
                            if newMaxY > globalYDomain.upperBound {
                                let corr = newMaxY - globalYDomain.upperBound
                                newMinY -= corr; newMaxY -= corr
                            }
                            visibleYDomain = max(globalYDomain.lowerBound, newMinY)...min(globalYDomain.upperBound, newMaxY)
                        }
                    }
                    updateDomainAndRedraw()
                } else if !isDraggingChart {
                    if case .donut = type { return }
                    let radiusSq = hitboxRadius * hitboxRadius
                    highlightedPoints = pointContexts.filter {
                        let dx = $0.position.x - value.location.x; let dy = $0.position.y - value.location.y
                        return (dx * dx + dy * dy) <= radiusSq
                    }
                }
            }
            .onEnded { _ in
                dragStartDomain = nil
                dragStartYDomain = nil
                isDraggingChart = false
                highlightedPoints = []
            }
        
        let zoomGesture = MagnificationGesture()
            .onChanged { value in
                guard isHorizontalZoomEnabled || isVerticalZoomEnabled else { return }
                highlightedPoints = []
                
                if isHorizontalZoomEnabled {
                    let currentXDomain = visibleXDomain ?? activeXScale.domain 
                    if zoomStartDomain == nil { zoomStartDomain = currentXDomain }
                    if let startXDomain = zoomStartDomain {
                        let startRangeX = startXDomain.upperBound - startXDomain.lowerBound
                        let globalRangeX = globalXDomain.upperBound - globalXDomain.lowerBound
                        var newRangeX = startRangeX / value
                        
                        newRangeX = min(newRangeX, globalRangeX)
                        newRangeX = max(newRangeX, globalRangeX * minZoomScale)
                        
                        let centerX = startXDomain.lowerBound + (startRangeX / 2)
                        var newMinX = centerX - (newRangeX / 2)
                        var newMaxX = centerX + (newRangeX / 2)
                        
                        if newMinX < globalXDomain.lowerBound { let c = globalXDomain.lowerBound - newMinX; newMinX += c; newMaxX += c }
                        if newMaxX > globalXDomain.upperBound { let c = newMaxX - globalXDomain.upperBound; newMinX -= c; newMaxX -= c }
                        visibleXDomain = newMinX...newMaxX
                    }
                }
                
                if isVerticalZoomEnabled {
                    let currentYDomain = visibleYDomain ?? activeYScale.domain 
                    if zoomStartYDomain == nil { zoomStartYDomain = currentYDomain }
                    if let startYDomain = zoomStartYDomain {
                        let startRangeY = startYDomain.upperBound - startYDomain.lowerBound
                        let globalRangeY = globalYDomain.upperBound - globalYDomain.lowerBound
                        var newRangeY = startRangeY / value
                        
                        newRangeY = min(newRangeY, globalRangeY)
                        newRangeY = max(newRangeY, globalRangeY * minZoomScale)
                        
                        let centerY = startYDomain.lowerBound + (startRangeY / 2)
                        var newMinY = centerY - (newRangeY / 2)
                        var newMaxY = centerY + (newRangeY / 2)
                        
                        if newMinY < globalYDomain.lowerBound { let c = globalYDomain.lowerBound - newMinY; newMinY += c; newMaxY += c }
                        if newMaxY > globalYDomain.upperBound { let c = newMaxY - globalYDomain.upperBound; newMinY -= c; newMaxY -= c }
                        visibleYDomain = newMinY...newMaxY
                    }
                }
                updateDomainAndRedraw()
            }
            .onEnded { _ in
                zoomStartDomain = nil
                zoomStartYDomain = nil
            }
        
        return dragGesture.simultaneously(with: zoomGesture)
    }
    
    @MainActor
    private func updateDomainAndRedraw() {
        var needsUpdate = false
        
        if let newXDomain = visibleXDomain, var newScaleX = LinearScale(domain: newXDomain) as? XScale {
            newScaleX.range = activeXScale.range
            newScaleX.isReversed = activeXScale.isReversed
            self.activeXScale = newScaleX
            needsUpdate = true
        }

        if let newYDomain = visibleYDomain, var newScaleY = LinearScale(domain: newYDomain) as? YScale {
            newScaleY.range = activeYScale.range
            newScaleY.isReversed = activeYScale.isReversed
            self.activeYScale = newScaleY
            needsUpdate = true
        }
        
        if needsUpdate {
            queueUpdate(in: canvasSize, animate: false)
        }
    }

    @MainActor
    private func queueUpdate(in size: CGSize, animate: Bool) {
        updateCounter += 1
        let currentID = updateCounter
        
        Task {
            if animate {
                oldPointContexts = pointContexts
                animationProgress = 0.0
                try? await Task.sleep(nanoseconds: 5_000_000)
            }
            
            guard currentID == self.updateCounter else { return }
            
            if case .violin(let pointSize, let centerX, let maxWidth, let bandwidth, let resolution, let groupMapper, let sideMapper, _) = type {
                let coordinator = ViolinCoordinator<Point, XScale, YScale>(xScale: activeXScale, yScale: activeYScale)
                
                let layout = await coordinator.calculateLayout(
                    for: data,
                    in: size,
                    centerX: centerX,
                    maxWidth: maxWidth,
                    pointSize: pointSize,
                    bandwidth: bandwidth,
                    resolution: resolution,
                    groupMapper: groupMapper,
                    sideMapper: sideMapper
                )
                
                guard currentID == self.updateCounter else { return }
                self.pointContexts = layout.points
                self.violinBackgrounds = layout.backgroundPaths
                self.activeXScale = coordinator.xScale
                self.activeYScale = coordinator.yScale
            } else {
                let coordinator = CartesianCoordinator<Point, XScale, YScale>(xScale: activeXScale, yScale: activeYScale)
                let newContexts = await coordinator.calculateLayout(for: data, in: size)
                
                guard currentID == self.updateCounter else { return }
                pointContexts = newContexts
                self.activeXScale = coordinator.xScale
                self.activeYScale = coordinator.yScale
            }
            
            if animate, let customAnimation = animationStyle.swiftUIAnimation {
                withAnimation(customAnimation) { animationProgress = 1.0 }
            } else {
                if animate { oldPointContexts = pointContexts }
                animationProgress = 1.0
            }
        }
    }
}
