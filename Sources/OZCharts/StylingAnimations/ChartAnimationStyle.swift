//
//  ChartAnimationStyle.swift
//  OZCharts
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import SwiftUI

public enum ChartAnimationStyle {
    case none
    case morph(Animation = .spring(response: 0.5, dampingFraction: 0.8))
    case draw(Animation  = .easeInOut(duration: 0.8))
    case fade(Animation  = .easeInOut(duration: 0.5))

    public enum Kind {
        case none, morph, draw, fade
    }

    public var kind: Kind {
        switch self {
        case .none:  return .none
        case .morph: return .morph
        case .draw:  return .draw
        case .fade:  return .fade
        }
    }

    public var swiftUIAnimation: Animation? {
        switch self {
        case .none:           return nil
        case .morph(let a):   return a
        case .draw(let a):    return a
        case .fade(let a):    return a
        }
    }
}
