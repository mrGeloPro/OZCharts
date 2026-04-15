//
//  XAxisView.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import SwiftUI

public struct XAxisView<S: Scale>: View where S.InputType == Double, S.OutputType == CGFloat {
    let scale: S
    let config: XAxisConfig
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if config.showAxisLine {
                    let isTop = config.position == .top
                    Rectangle()
                        .fill(config.axisLineColor)
                        .frame(height: config.axisLineWidth)
                        .frame(maxHeight: .infinity, alignment: isTop ? .bottom : .top)
                }
                
                ForEach(ticks) { tick in
                    VStack(spacing: config.labelSpacing) {
                        if config.position == .top {
                            Spacer()
                            
                            if let customView = config.customLabelBuilder?(tick.value) {
                                customView
                            } else {
                                Text(tick.label)
                                    .font(config.font)
                                    .foregroundColor(config.textColor)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
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
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            Spacer()
                        }
                    }
                    .position(x: tick.position, y: geometry.size.height / 2)
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
