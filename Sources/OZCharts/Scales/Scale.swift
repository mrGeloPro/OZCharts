//
//  Scale.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import CoreGraphics

public struct ScaleTick<Input, Output>: Identifiable {
    public let id = UUID()
    public let value: Input
    public let position: Output
    public let label: String
    
    public init(value: Input, position: Output, label: String) {
        self.value = value
        self.position = position
        self.label = label
    }
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
