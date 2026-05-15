//
//  DemoShowcaseData.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import OZCharts

enum DemoShowcaseData {
    static let heroSignal: [Point2D] = (0...14).map { index in
        let x = Double(index)
        return Point2D(x: x, y: 42 + sin(x / 1.7) * 16 + Double(index % 4) * 7)
    }

    static let heroVolume: [Point2D] = (0...14).map { index in
        Point2D(x: Double(index), y: 18 + Double((index * 13) % 48))
    }

    static let signal: [Point2D] = (0...24).map { index in
        let x = Double(index)
        return Point2D(x: x, y: 58 + sin(x / 2.0) * 22 + Double((index * 5) % 17))
    }

    static let baseline: [Point2D] = (0...24).map { index in
        let x = Double(index)
        return Point2D(x: x, y: 46 + cos(x / 2.6) * 10 + Double(index % 6) * 3)
    }

    static let volume: [Point2D] = (0...24).map { index in
        Point2D(x: Double(index), y: 15 + Double((index * 19) % 70))
    }
}
