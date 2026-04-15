import Foundation
import CoreGraphics

public struct LinearScale: Scale {
    public typealias InputType = Double
    public typealias OutputType = CGFloat
    
    public var domain: ClosedRange<Double>
    public var range: ClosedRange<CGFloat>
    public var isReversed: Bool = false
    
    public init(domain: ClosedRange<Double>, range: ClosedRange<CGFloat> = 0.0...1.0, isReversed: Bool = false) {
        let safeDomain = domain.lowerBound == domain.upperBound
        ? domain.lowerBound...(domain.upperBound + 1.0)
        : domain
        self.domain = safeDomain
        self.range = range
        self.isReversed = isReversed
    }
    
    public func scale(_ value: Double) -> CGFloat {
        let domainExtent = domain.upperBound - domain.lowerBound
        let rangeExtent = range.upperBound - range.lowerBound
        
        let normalized = (value - domain.lowerBound) / domainExtent
        let projected = isReversed ? (1.0 - normalized) : normalized
        
        return range.lowerBound + CGFloat(projected) * rangeExtent
    }
    
    public func invert(_ value: CGFloat) -> Double {
        let domainExtent = domain.upperBound - domain.lowerBound
        let rangeExtent = range.upperBound - range.lowerBound
        
        if rangeExtent == 0 { return domain.lowerBound }
        
        let normalized = (value - range.lowerBound) / rangeExtent
        let projected = isReversed ? (1.0 - normalized) : normalized
        
        return domain.lowerBound + Double(projected) * domainExtent
    }
    
    public func ticks(count: Int, formatter: @escaping (Double) -> String = { String(format: "%.1f", $0) }) -> [ScaleTick<Double, CGFloat>] {
        guard count > 1 else { return [] }
        var ticks: [ScaleTick<Double, CGFloat>] = []
        let step = (domain.upperBound - domain.lowerBound) / Double(count - 1)
        
        for i in 0..<count {
            let currentValue = domain.lowerBound + (step * Double(i))
            let position = self.scale(currentValue)
            ticks.append(ScaleTick(value: currentValue, position: position, label: formatter(currentValue)))
        }
        return ticks
    }
}
