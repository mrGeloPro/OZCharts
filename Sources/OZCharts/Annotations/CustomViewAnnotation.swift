//
//  CustomViewAnnotation.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 15.04.2026.
//
import Foundation
import SwiftUI

/// An annotation that allows placing any custom SwiftUI view at specific coordinates on the chart.
public struct CustomViewAnnotation<X: Comparable, Y: Comparable>: Identifiable {
    public let id = UUID()
    public let x: X
    public let y: Y
    public let content: AnyView
    
    /// Creates a custom view annotation using a ViewBuilder.
    /// - Parameters:
    ///   - x: The X coordinate.
    ///   - y: The Y coordinate.
    ///   - content: A closure returning the SwiftUI view to display.
    public init<V: View>(x: X, y: Y, @ViewBuilder content: () -> V) {
        self.x = x
        self.y = y
        self.content = AnyView(content())
    }
}
