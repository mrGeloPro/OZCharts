//
//  AnnotationRenderer.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 16.04.2026.
//

import SwiftUI

public struct AnnotationRenderer {
    public static func drawHorizontal<YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [HorizontalAnnotation],
        activeYScale: YScale
    ) where YScale.InputType == Double, YScale.OutputType == CGFloat {
        
        for annotation in annotations {
            let yValue = annotation.yValue as! YScale.InputType
            let yPos = size.height - activeYScale.scale(yValue)
            var path = Path()
            path.move(to: CGPoint(x: 0, y: yPos))
            path.addLine(to: CGPoint(x: size.width, y: yPos))
            context.stroke(path, with: .color(annotation.color), style: StrokeStyle(lineWidth: annotation.lineWidth, dash: annotation.dash))
        }
    }
    
    public static func drawPoints<XScale: Scale, YScale: Scale>(
        into context: inout GraphicsContext,
        size: CGSize,
        annotations: [PointAnnotation<Double, Double>],
        activeXScale: XScale,
        activeYScale: YScale
    ) where XScale.InputType == Double, XScale.OutputType == CGFloat,
            YScale.InputType == Double, YScale.OutputType == CGFloat {
        
        for annotation in annotations {
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
    }
}
