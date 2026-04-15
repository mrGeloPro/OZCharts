import Foundation
import SwiftUI

public enum XAxisPosition { case top, bottom }
public enum YAxisPosition { case leading, trailing }

public struct XAxisConfig {
    public var position: XAxisPosition
    public var showGrid: Bool
    public var showTicks: Bool
    public var explicitValues: [Double]?
    public var gridColor: Color
    public var gridLineWidth: CGFloat
    public var gridLineDash: [CGFloat]
    public var tickCount: Int
    public var labelFormatter: (Double) -> String
    public var font: Font
    public var textColor: Color
    public var height: CGFloat
    public var showAxisLine: Bool
    public var axisLineColor: Color
    public var axisLineWidth: CGFloat
    public var customLabelBuilder: ((Double) -> AnyView)?
    public var tickLength: CGFloat = 5
    public var tickColor: Color = .gray.opacity(0.5)
    public var tickWidth: CGFloat = 1
    public var labelSpacing: CGFloat = 4

    public init(
        position: XAxisPosition = .bottom,
        showGrid: Bool = true,
        showTicks: Bool = true,
        explicitValues: [Double]? = nil,
        gridColor: Color = .gray.opacity(0.3),
        gridLineWidth: CGFloat = 1,
        gridLineDash: [CGFloat] = [],
        tickCount: Int = 5,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) },
        font: Font = .caption2,
        textColor: Color = .gray,
        height: CGFloat = 30,
        showAxisLine: Bool = false,
        axisLineColor: Color = .gray.opacity(0.5),
        axisLineWidth: CGFloat = 1,
        tickLength: CGFloat = 5,
        tickColor: Color = .gray.opacity(0.5),
        tickWidth: CGFloat = 1,
        labelSpacing: CGFloat = 4,
        customLabelBuilder: ((Double) -> AnyView)? = nil
    ) {
        self.position = position
        self.showGrid = showGrid
        self.showTicks = showTicks
        self.explicitValues = explicitValues
        self.gridColor = gridColor
        self.gridLineWidth = gridLineWidth
        self.gridLineDash = gridLineDash
        self.tickCount = tickCount
        self.labelFormatter = labelFormatter
        self.font = font
        self.textColor = textColor
        self.height = height
        self.showAxisLine = showAxisLine
        self.axisLineColor = axisLineColor
        self.axisLineWidth = axisLineWidth
        self.tickLength = tickLength
        self.tickColor = tickColor
        self.tickWidth = tickWidth
        self.labelSpacing = labelSpacing
        self.customLabelBuilder = customLabelBuilder
    }
}

public struct YAxisConfig {
    public var position: YAxisPosition
    public var showGrid: Bool
    public var showTicks: Bool
    public var explicitValues: [Double]?
    public var gridColor: Color
    public var gridLineWidth: CGFloat
    public var gridLineDash: [CGFloat]
    public var tickCount: Int
    public var labelFormatter: (Double) -> String
    public var font: Font
    public var textColor: Color
    public var width: CGFloat
    public var showAxisLine: Bool
    public var axisLineColor: Color
    public var axisLineWidth: CGFloat
    public var customLabelBuilder: ((Double) -> AnyView)?
    public var tickLength: CGFloat = 5
    public var tickColor: Color = .gray.opacity(0.5)
    public var tickWidth: CGFloat = 1
    public var labelSpacing: CGFloat = 4

    public init(
        position: YAxisPosition = .leading,
        showGrid: Bool = true,
        showTicks: Bool = true,
        explicitValues: [Double]? = nil,
        gridColor: Color = .gray.opacity(0.3),
        gridLineWidth: CGFloat = 1,
        gridLineDash: [CGFloat] = [],
        tickCount: Int = 5,
        labelFormatter: @escaping (Double) -> String = { String(format: "%.0f", $0) },
        font: Font = .caption2,
        textColor: Color = .gray,
        width: CGFloat = 40,
        showAxisLine: Bool = false,
        axisLineColor: Color = .gray.opacity(0.5),
        axisLineWidth: CGFloat = 1,
        tickLength: CGFloat = 5,
        tickColor: Color = .gray.opacity(0.5),
        tickWidth: CGFloat = 1,
        labelSpacing: CGFloat = 4,
        customLabelBuilder: ((Double) -> AnyView)? = nil,
    ) {
        self.position = position
        self.showGrid = showGrid
        self.showTicks = showTicks
        self.explicitValues = explicitValues
        self.gridColor = gridColor
        self.gridLineWidth = gridLineWidth
        self.gridLineDash = gridLineDash
        self.tickCount = tickCount
        self.labelFormatter = labelFormatter
        self.font = font
        self.textColor = textColor
        self.width = width
        self.showAxisLine = showAxisLine
        self.axisLineColor = axisLineColor
        self.axisLineWidth = axisLineWidth
        self.customLabelBuilder = customLabelBuilder
        self.tickLength = tickLength
        self.tickColor = tickColor
        self.tickWidth = tickWidth
        self.labelSpacing = labelSpacing
        
    }
}
