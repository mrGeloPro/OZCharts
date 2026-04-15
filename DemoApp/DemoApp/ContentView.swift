//
//  ContentView.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi on 15.04.2026.
//
import SwiftUI
import OZCharts

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Polar Graphs")) {
                    NavigationLink("TOTAL SCORE (Donut)", destination: DonutScoreDemoView())
                }
                
                Section(header: Text("Cartesian Graphs")) {
                    NavigationLink("HEIGHT (Line & Empty State)", destination: HeightDemoView())
                    NavigationLink("ACCURACY OVERVIEW (Violin)", destination: AccuracyDemoView())
                    NavigationLink("STAR ACHIEVEMENT (Stacked Bar)", destination: StarAchievementDemoView())
                }
                
                Section(header: Text("Complex Accumulation Graphs")) {
                    NavigationLink("POINTS DISTRIBUTION (Stacked Area)", destination: PointsDistributionDemoView())
                }
                
                Section(header: Text("Animation")) {
                    NavigationLink("ANIMATION SHOWCASE (Line)", destination: AnimationShowcaseView())
                }
                
                Section(header: Text("Advanced Layering")) {
                    NavigationLink("HYBRID VIEW (Line + Shapes + Icons)", destination: HybridChartDemoView())
                }
            }
            .navigationTitle("OZCharts Demo")
        }
    }
}

// MARK: - Donut Demo
struct DonutScoreDemoView: View {
    let mockData: [Point2D] = [
        Point2D(x: 1, y: 85.2),
        Point2D(x: 2, y: 11.3),
        Point2D(x: 3, y: 3.5)
    ]
    
    let legend: [(String, Color)] = [("Basic", .purple), ("Bonus", .pink), ("Streak", .yellow)]
    
    var body: some View {
        VStack {
            CartesianChartView(
                data: mockData,
                type: .donut(thickness: 40, colors: [.purple, .pink, .yellow]),
                xScale: LinearScale(domain: 0...1),
                yScale: LinearScale(domain: 0...100)
            ) { _ in EmptyView() }
                .frame(height: 300)
                .padding()
            
            HStack(spacing: 20) {
                ForEach(legend, id: \.0) { item in
                    HStack {
                        Circle().fill(item.1).frame(width: 10, height: 10)
                        Text(item.0).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationTitle("TOTAL SCORE")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Line & Empty State Demo
struct HeightDemoView: View {
    @State private var mockData: [Point2D] = [
        Point2D(x: 1, y: 2.0), Point2D(x: 3, y: 4.0), Point2D(x: 5, y: 2.9),
        Point2D(x: 7, y: 4.0), Point2D(x: 9, y: 4.9), Point2D(x: 12, y: 9.0),
        Point2D(x: 14, y: 6.2), Point2D(x: 16, y: 4.0), Point2D(x: 18, y: 5.0),
        Point2D(x: 19, y: 4.0)
    ]
    
    var body: some View {
        VStack {
            CartesianChartView(
                data: mockData,
                type: .line(lineWidth: 3, color: .purple),
                xScale: LinearScale(domain: 1...20),
                yScale: LinearScale(domain: 0...10),
                xAxes: [
                    XAxisConfig(position: .bottom, tickCount: 7, labelFormatter: { "\(Int($0))s" })
                ],
                yAxes: [
                    YAxisConfig(position: .leading, tickCount: 6, labelFormatter: { "\(Int($0))" })
                ],
                emptyState: {
                    AnyView(
                        VStack(spacing: 12) {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Data Available")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                    )
                }
            ) { points in
                VStack(alignment: .leading, spacing: 4) {
                    if points.count > 1 {
                        Text("\(points.count) overlapping points").font(.caption).bold().foregroundColor(.secondary)
                    }
                    
                    ForEach(points, id: \.originalPoint.id) { pointContext in
                        Text("Value: \(String(format: "%.1f", pointContext.originalPoint.y))")
                            .foregroundColor(.cyan)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            }
            .frame(height: 300)
            .padding()
            
            Button(action: {
                withAnimation {
                    if mockData.isEmpty {
                        mockData = [
                            Point2D(x: 1, y: 2.0), Point2D(x: 3, y: 4.0), Point2D(x: 5, y: 2.9),
                            Point2D(x: 7, y: 4.0), Point2D(x: 9, y: 4.9), Point2D(x: 12, y: 9.0),
                            Point2D(x: 14, y: 6.2), Point2D(x: 16, y: 4.0), Point2D(x: 18, y: 5.0),
                            Point2D(x: 19, y: 4.0)
                        ]
                    } else {
                        mockData = []
                    }
                }
            }) {
                Text(mockData.isEmpty ? "Load Data" : "Clear Data (Test Empty State)")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mockData.isEmpty ? Color.green : Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("HEIGHT")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Violin Demo
enum DemoGroup: Hashable { case left, right }

struct AccuracyDemoView: View {
    let mockData: [GroupedPoint2D<DemoGroup>] = (0...150).map { i in
        let group: DemoGroup = i % 2 == 0 ? .left : .right
        let x = group == .left ? Double.random(in: 10...48) : Double.random(in: 52...90)
        let y = Double.random(in: 0...1) > 0.3 ? Double.random(in: 100...140) : Double.random(in: 80...200)
        return GroupedPoint2D(x: x, y: y, group: group)
    }
    
    var body: some View {
        VStack {
            CartesianChartView(
                data: mockData,
                type: .violin(
                    centerX: 50,
                    maxWidth: 40,
                    groupMapper: { AnyHashable(($0 ).group) },
                    sideMapper: { id in (id.base as! DemoGroup) == .left ? .left : .right },
                    colorMapper: { id in (id.base as! DemoGroup) == .left ? .cyan : .purple }
                ),
                xScale: LinearScale(domain: 0...100),
                yScale: LinearScale(domain: 60...240),
                xAxes: [
                    XAxisConfig(position: .bottom, tickCount: 0, labelFormatter: { _ in "" })
                ],
                yAxes: [
                    YAxisConfig(position: .leading, tickCount: 7, labelFormatter: { "\(Int($0))" }),
                    YAxisConfig(position: .trailing, tickCount: 7, labelFormatter: { bpm in
                        if bpm == 0 { return "0" }
                        let ms = 60000.0 / bpm
                        return "\(Int(ms))"
                    })
                ],
                horizontalAnnotations: [
                    HorizontalAnnotation(yValue: 120, label: "Target 120 BPM", color: .yellow)
                ],
                isHorizontalScrollEnabled: false,
                isHorizontalZoomEnabled: false
            ) { points in
                VStack(alignment: .leading, spacing: 4) {
                    if points.count > 1 {
                        Text("\(points.count) points").font(.caption).bold().foregroundColor(.secondary)
                    }
                    
                    ForEach(points, id: \.originalPoint.id) { pointContext in
                        Text("BPM: \(Int(pointContext.originalPoint.y))")
                            .foregroundColor(pointContext.originalPoint.group == .left ? .cyan : .purple)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            }
            .frame(height: 400)
            .padding()
            
            Spacer()
        }
        .navigationTitle("ACCURACY OVERVIEW")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stacked Area Demo
enum ScoreLayer: String, Hashable {
    case streak = "Streak"
    case bonus = "Bonus"
    case basic = "Basic"
}

struct PointsDistributionDemoView: View {
    let mockData: [GroupedPoint2D<ScoreLayer>] = {
        var points: [GroupedPoint2D<ScoreLayer>] = []
        let xValues: [Double] = [1, 2, 6, 7, 8, 10, 11, 14, 15, 17, 19, 21, 23, 25, 27, 28, 30, 32]
        
        for (i, x) in xValues.enumerated() {
            let basicY = Double(i * 25 + 50)
            points.append(GroupedPoint2D(x: x, y: basicY, group: .basic))
            
            let bonusY = basicY + Double(i * 5 + 20)
            points.append(GroupedPoint2D(x: x, y: bonusY, group: .bonus))
            
            let streakY = bonusY + Double(i * 8 + 30)
            points.append(GroupedPoint2D(x: x, y: streakY, group: .streak))
        }
        return points
    }()
    
    let legend: [(String, Color)] = [("Basic", .cyan), ("Bonus", .purple), ("Streak", .yellow)]
    
    var body: some View {
        VStack {
            CartesianChartView(
                data: mockData,
                type: .groupedArea(
                    lineWidth: 3,
                    fillOpacity: 0.3,
                    interpolation: .step,
                    groupMapper: { AnyHashable($0.group) },
                    colorMapper: { groupId in
                        let category = groupId.base as! ScoreLayer
                        switch category {
                        case .streak: return .yellow
                        case .bonus: return .purple
                        case .basic: return .cyan
                        }
                    },
                    zOrder: [
                        AnyHashable(ScoreLayer.streak),
                        AnyHashable(ScoreLayer.bonus),
                        AnyHashable(ScoreLayer.basic)
                    ]
                ),
                xScale: LinearScale(domain: 0...35),
                yScale: LinearScale(domain: 0...700),
                xAxes: [
                    XAxisConfig(position: .bottom, tickCount: 7, labelFormatter: { "\(Int($0))s" })
                ],
                yAxes: [
                    YAxisConfig(position: .leading, tickCount: 7, labelFormatter: { "\(Int($0))" })
                ]
            ) { _ in EmptyView() }
                .frame(height: 300)
                .padding()
                .background(Color.black.opacity(0.8).cornerRadius(16))
                .padding()
            
            HStack(spacing: 20) {
                ForEach(legend, id: \.0) { item in
                    HStack {
                        Circle().fill(item.1).frame(width: 10, height: 10)
                        Text(item.0).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationTitle("POINTS DISTRIBUTION")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Stacked Bar Demo
enum StarType: String, Hashable {
    case star1 = "Star 1"
    case star2 = "Star 2"
    case star3 = "Star 3"
}

struct StarAchievementDemoView: View {
    let mockData: [GroupedPoint2D<StarType>] = [
        GroupedPoint2D(x: 1.20, y: 3, group: .star1),
        GroupedPoint2D(x: 5.90, y: 3, group: .star2),
        GroupedPoint2D(x: 3.30, y: 3, group: .star3),
        
        GroupedPoint2D(x: 30, y: 2, group: .star1),
        GroupedPoint2D(x: 30, y: 2, group: .star2),
        GroupedPoint2D(x: 30, y: 2, group: .star3),
        
        GroupedPoint2D(x: 10.60, y: 1, group: .star1),
        GroupedPoint2D(x: 5.90, y: 1, group: .star2),
        GroupedPoint2D(x: 2.80, y: 1, group: .star3),
        
        GroupedPoint2D(x: 9.20, y: 0, group: .star1),
        GroupedPoint2D(x: 7.30, y: 0, group: .star2),
        GroupedPoint2D(x: 3.00, y: 0, group: .star3)
    ]
    
    let yLabels: [Double: String] = [0: "Current", 1: "Last", 2: "Average", 3: "High score"]
    let legend: [(String, Color)] = [("Star 1", .yellow), ("Star 2", .orange), ("Star 3", Color(red: 0.2, green: 0.15, blue: 0.25))]
    
    var body: some View {
        VStack {
            CartesianChartView(
                data: mockData,
                type: .stackedHorizontalBar(
                    barHeight: 35,
                    cornerRadius: 0,
                    stackMapper: { AnyHashable($0.group) },
                    colorMapper: { groupId in
                        let star = groupId.base as! StarType
                        switch star {
                        case .star1: return .yellow
                        case .star2: return .orange
                        case .star3: return Color(red: 0.2, green: 0.15, blue: 0.25)
                        }
                    },
                    stackOrder: [AnyHashable(StarType.star1), AnyHashable(StarType.star2), AnyHashable(StarType.star3)]
                ),
                xScale: LinearScale(domain: 0...90),
                yScale: LinearScale(domain: -0.5...3.5),
                xAxes: [
                    XAxisConfig(position: .bottom, tickCount: 10, labelFormatter: { "\(Int($0))" })
                ],
                yAxes: [
                    YAxisConfig(position: .leading, tickCount: 4, labelFormatter: { yValue in
                        return yLabels[yValue.rounded(.up)] ?? ""
                    })
                ]
            ) { points in
                VStack(alignment: .leading, spacing: 4) {
                    if points.count > 1 {
                        Text("\(points.count) overlapping elements").font(.caption).bold().foregroundColor(.secondary)
                    }
                    
                    ForEach(points, id: \.originalPoint.id) { pointContext in
                        Text("Value: \(String(format: "%.1f", pointContext.originalPoint.x))")
                            .foregroundColor(.purple)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            }
            .frame(height: 350)
            .padding()
            .background(Color(red: 0.05, green: 0.05, blue: 0.1).cornerRadius(16))
            .padding()
            
            HStack(spacing: 30) {
                ForEach(legend, id: \.0) { item in
                    HStack {
                        Circle().fill(item.1).frame(width: 12, height: 12)
                        Text(item.0).font(.subheadline).foregroundColor(.white)
                    }
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .navigationTitle("STAR ACHIEVEMENT")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Animation Showcase
struct AnimationShowcaseView: View {
    @State private var useAltData = false
    @State private var selectedStyle: ChartAnimationStyle = .draw(.linear(duration: 3.0))
    
    let data1: [Point2D] = [
        Point2D(x: 0, y: 50), Point2D(x: 1, y: 120), Point2D(x: 2, y: 80),
        Point2D(x: 3, y: 150), Point2D(x: 4, y: 90), Point2D(x: 5, y: 180)
    ]
    
    let data2: [Point2D] = [
        Point2D(x: 0, y: 180), Point2D(x: 1.5, y: 60), Point2D(x: 2, y: 140),
        Point2D(x: 2.5, y: 70), Point2D(x: 4, y: 160), Point2D(x: 5, y: 40)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Animation Showcase")
                .font(.title2).bold()
            
            Picker("Animation Style", selection: $selectedStyle) {
                Text("Draw").tag(ChartAnimationStyle.draw(.linear(duration: 3.0)))
                Text("Morph").tag(ChartAnimationStyle.morph())
                Text("Fade").tag(ChartAnimationStyle.fade())
                Text("None").tag(ChartAnimationStyle.none)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            CartesianChartView(
                data: useAltData ? data2 : data1,
                type: .line(lineWidth: 4, color: .cyan),
                xScale: LinearScale(domain: 0...5),
                yScale: LinearScale(domain: 0...200),
                xAxes: [XAxisConfig(showGrid: false)],
                yAxes: [YAxisConfig(gridColor: .white.opacity(0.1), gridLineWidth: 1)],
                animationStyle: selectedStyle
            ) { points in
                if let firstPoint = points.first {
                    Text("\(Int(firstPoint.originalPoint.y)) Value")
                        .font(.caption).bold()
                        .padding(8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                } else {
                    EmptyView()
                }
            }
            .frame(height: 350)
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(16)
            .padding(.horizontal)
            
            Button(action: {
                useAltData.toggle()
            }) {
                Text("Toggle Data")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("Animations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HybridChartDemoView: View {
    let mockData: [Point2D] = [
        Point2D(x: 0, y: 40), Point2D(x: 2, y: 150), Point2D(x: 4, y: 80),
        Point2D(x: 6, y: 190), Point2D(x: 8, y: 110), Point2D(x: 10, y: 160)
    ]
    
    let markers: [PointAnnotation<Double, Double>] = [
        PointAnnotation(x: 2, y: 150, shape: .circle, color: .green, size: 12),
        PointAnnotation(x: 6, y: 190, shape: .star, color: .yellow, size: 20, strokeColor: .white, strokeWidth: 2)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Layered Composition")
                .font(.headline)
                .padding(.top)

            CartesianChartView(
                data: mockData,
                type: .line(lineWidth: 4, color: .blue),
                xScale: LinearScale(domain: 0...10),
                yScale: LinearScale(domain: 0...250),
                xAxes: [XAxisConfig(showGrid: false)],
                yAxes: [YAxisConfig(gridColor: .gray.opacity(0.2))],
                pointAnnotations: markers,
                customViewAnnotations: [
                    CustomViewAnnotation(x: 6, y: 215) {
                        VStack(spacing: 2) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("NEW RECORD")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                    },
                    CustomViewAnnotation(x: 4, y: 60) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                    }
                ]
            ) { points in
                if let p = points.first {
                    Text("Value: \(Int(p.originalPoint.y))")
                        .font(.caption).bold()
                        .padding(6)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            .frame(height: 350)
            .padding()
            .background(Color(white: 0.1).cornerRadius(16))
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 10) {
                Label("Blue Line: Core Data", systemImage: "line.diagonal")
                Label("Yellow Star: Milestone reached", systemImage: "star.fill")
                Label("Custom Icons: Event markers", systemImage: "flame.fill")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 30)

            Spacer()
        }
        .navigationTitle("HYBRID VIEW")
        .navigationBarTitleDisplayMode(.inline)
    }
}
