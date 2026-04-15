//
//  Scale.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi on 11.04.2026.
//

import Foundation
import CoreGraphics

public struct ScaleTick<Input, Output>: Identifiable {
    public let id = UUID()
    public let value: Input
    public let position: Output
    public let label: String
}

public protocol Scale {
    associatedtype InputType: Comparable
    associatedtype OutputType: Comparable
    
    var domain: ClosedRange<InputType> { get set }
    var range: ClosedRange<OutputType> { get set }
    
    var isReversed: Bool { get set }
    
    func scale(_ value: InputType) -> OutputType
    func invert(_ value: OutputType) -> InputType
    func ticks(count: Int, formatter: @escaping (InputType) -> String) -> [ScaleTick<InputType, OutputType>]
}
