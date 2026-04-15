import SwiftUI

public enum ChartAnimationStyle: Hashable {
    case none
    case morph(Animation = .spring(response: 0.5, dampingFraction: 0.8))
    case draw(Animation = .easeInOut(duration: 0.8))
    case fade(Animation = .easeInOut(duration: 0.5))
    
    var swiftUIAnimation: Animation? {
        switch self {
        case .none: return nil
        case .morph(let anim): return anim
        case .draw(let anim): return anim
        case .fade(let anim): return anim
        }
    }
}

public struct AnimatableChartLayer: View, Animatable {
    public var oldPoints: [CGPoint]
    public var newPoints: [CGPoint]
    public var progress: CGFloat
    
    public var animationStyle: ChartAnimationStyle
    public var lineColor: Color
    public var lineWidth: CGFloat
    public var drawLine: Bool
    public var drawDots: Bool
    
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    private var interpolatedPoints: [CGPoint] {
        let maxCount = max(oldPoints.count, newPoints.count)
        guard maxCount > 0 else { return [] }
        var result: [CGPoint] = []
        for i in 0..<maxCount {
            let old = oldPoints.isEmpty ? (i < newPoints.count ? newPoints[i] : .zero) : (i < oldPoints.count ? oldPoints[i] : oldPoints.last!)
            let new = newPoints.isEmpty ? old : (i < newPoints.count ? newPoints[i] : newPoints.last!)
            
            let currentX = old.x + (new.x - old.x) * progress
            let currentY = old.y + (new.y - old.y) * progress
            result.append(CGPoint(x: currentX, y: currentY))
        }
        return result
    }
    
    public var body: some View {
        Canvas { context, size in
            guard !newPoints.isEmpty else { return }
            let strokeStyle = StrokeStyle(lineWidth: lineWidth, lineJoin: .round)
            
            if drawLine {
                switch animationStyle {
                case .none:
                    var path = Path()
                    path.move(to: newPoints[0])
                    for i in 1..<newPoints.count { path.addLine(to: newPoints[i]) }
                    context.stroke(path, with: .color(lineColor), style: strokeStyle)
                    
                case .morph:
                    let pts = interpolatedPoints
                    var path = Path()
                    path.move(to: pts[0])
                    for i in 1..<pts.count { path.addLine(to: pts[i]) }
                    context.stroke(path, with: .color(lineColor), style: strokeStyle)
                    
                case .draw:
                    guard let first = newPoints.first, let last = newPoints.last else { return }
                    
                    var path = Path()
                    path.move(to: first)
                    for i in 1..<newPoints.count { path.addLine(to: newPoints[i]) }
                    
                    let clampedProgress = min(max(progress, 0.0), 1.0)
                    
                    let minX = first.x
                    let maxX = last.x
                    let currentX = minX + (maxX - minX) * clampedProgress
                    
                    let clipRect = CGRect(x: 0, y: 0, width: currentX, height: size.height)
                    
                    
                    context.clip(to: Path(clipRect))
                    context.stroke(path, with: .color(lineColor), style: strokeStyle)
                case .fade:
                    if !oldPoints.isEmpty {
                        var oldPath = Path()
                        oldPath.move(to: oldPoints[0])
                        for i in 1..<oldPoints.count { oldPath.addLine(to: oldPoints[i]) }
                        context.opacity = 1.0 - progress
                        context.stroke(oldPath, with: .color(lineColor), style: strokeStyle)
                    }
                    var newPath = Path()
                    newPath.move(to: newPoints[0])
                    for i in 1..<newPoints.count { newPath.addLine(to: newPoints[i]) }
                    context.opacity = progress
                    context.stroke(newPath, with: .color(lineColor), style: strokeStyle)
                }
            }
            
            if drawDots {
                let pts = animationStyle == .morph() ? interpolatedPoints : newPoints
                context.opacity = (animationStyle == .fade()) ? progress : 1.0
                
                for point in pts {
                    let rect = CGRect(x: point.x - lineWidth/2, y: point.y - lineWidth/2, width: lineWidth, height: lineWidth)
                    context.fill(Path(ellipseIn: rect), with: .color(lineColor))
                }
            }
        }
    }
}
