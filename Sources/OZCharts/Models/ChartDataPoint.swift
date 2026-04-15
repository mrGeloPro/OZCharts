import Foundation
import SwiftUI

public protocol ChartDataPoint: Identifiable, Equatable {
    associatedtype XValue: Comparable
    associatedtype YValue: Comparable
    var id: UUID { get }
    var x: XValue { get }
    var y: YValue { get }
}

public struct Point2D: ChartDataPoint {
    public let id = UUID()
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public protocol GroupedChartDataPoint: ChartDataPoint {
    associatedtype GroupID: Hashable
    var group: GroupID { get }
}

public struct GroupedPoint2D<GroupID: Hashable>: GroupedChartDataPoint {
    public let id = UUID()
    public var x: Double
    public var y: Double
    public var group: GroupID
    
    public init(x: Double, y: Double, group: GroupID) {
        self.x = x
        self.y = y
        self.group = group
    }
}
