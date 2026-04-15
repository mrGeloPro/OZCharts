import SwiftUI

public struct YAxisView<S: Scale>: View where S.InputType == Double, S.OutputType == CGFloat {
    let scale: S
    let config: YAxisConfig
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if config.showAxisLine {
                    let isLeading = config.position == .leading
                    Rectangle()
                        .fill(config.axisLineColor)
                        .frame(width: config.axisLineWidth)
                        .frame(maxWidth: .infinity, alignment: isLeading ? .trailing : .leading)
                }
                
                ForEach(ticks) { tick in
                    HStack(spacing: config.labelSpacing) {
                        if config.position == .leading {
                            Spacer()
                            
                            if let customView = config.customLabelBuilder?(tick.value) {
                                customView
                            } else {
                                Text(tick.label)
                                    .font(config.font)
                                    .foregroundColor(config.textColor)
                                    .lineLimit(1).fixedSize()
                            }
                            
                            if config.showTicks {
                                Rectangle().frame(width: config.tickWidth, height: config.tickLength).foregroundColor(config.tickColor)
                            }
                           
                        } else {
                            if config.showTicks {
                                Rectangle().frame(width: config.tickWidth, height: config.tickLength).foregroundColor(config.tickColor)
                            }
                            
                            if let customView = config.customLabelBuilder?(tick.value) {
                                customView
                            } else {
                                Text(tick.label)
                                    .font(config.font)
                                    .foregroundColor(config.textColor)
                                    .lineLimit(1).fixedSize()
                            }
                            Spacer()
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height - tick.position)
                }
            }
        }
    }
    
    private var ticks: [ScaleTick<Double, CGFloat>] {
            if let explicit = config.explicitValues {
                return explicit.map { val in
                    ScaleTick(
                        value: val,
                        position: scale.scale(val),
                        label: config.labelFormatter(val)
                    )
                }
            } else {
                return scale.ticks(
                    count: config.tickCount,
                    formatter: config.labelFormatter
                )
            }
        }
}
