# OZCharts 📈

A high-performance, fully customizable, and mathematically precise charting framework for SwiftUI. Built for developers who need more flexibility than standard solutions provide.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

* **📊 Versatile Chart Types:** Supports Line, Scatter, Stacked Horizontal Bar, Grouped Area, Donut, and mathematically accurate **Violin** charts.
* **⚡ High Performance:** Canvas-based rendering with off-screen culling ensures smooth 60fps performance even with large datasets and active zooming.
* **👆 Advanced Gestures:** Fully independent horizontal and vertical scrolling/zooming with a smart gesture resolution system.
* **🥪 Hybrid Layering:** Combine Canvas-drawn lines/shapes with interactive SwiftUI views (`AnyView`) as annotations on a single chart without performance drops.
* **🎨 Absolute Customization:** Replace standard text labels on axes with custom SwiftUI views. Control grid lines, ticks, and label spacing easily.
* **🎯 Deterministic Rendering:** Zero flickering during scale operations thanks to deterministic pseudo-random jitter algorithms (crucial for Violin charts).

## Installation (Swift Package Manager)

Add `OZCharts` to your project via Xcode:
1. `File` > `Add Package Dependencies...`
2. Enter the repository URL: `https://github.com/mrGeloPro/OZCharts.git`
3. Choose the version rule (e.g., "Up to Next Major").

## Quick Start

```swift
import SwiftUI
import OZCharts

struct ContentView: View {
    let myData = [Point2D(x: 10, y: 120), Point2D(x: 20, y: 150)]
    
    var body: some View {
        CartesianChartView(
            data: myData,
            type: .line(lineWidth: 3, color: .blue),
            xScale: LinearScale(domain: 0...100),
            yScale: LinearScale(domain: 50...200),
            emptyState: {
                AnyView(Text("No Data Available").foregroundColor(.gray))
            }
        ) { points in
            // Custom Tooltip
            if let point = points.first {
                Text("Value: \(Int(point.originalPoint.y))")
                    .padding().background(Color.black).foregroundColor(.white).cornerRadius(8)
            } else {
                EmptyView()
            }
        }
        .frame(height: 300)
    }
}
```

## Running the Demo App

This repository includes a comprehensive `DemoApp` demonstrating advanced use cases like Hybrid Layering, Custom Axes, and Live Animations.

1. Clone the repository.
2. Open `DemoApp/DemoApp.xcodeproj` in Xcode.
3. Build and run on your simulator or device.

## Community & Resources

Want to see the architecture behind this framework and learn advanced iOS development? Check out the **[OZ pro iOS](https://www.youtube.com/@OZ_pro_iOS)** YouTube channel for deep dives into Swift, SwiftUI, and mobile architecture.

## License

OZCharts is released under the MIT license. See [LICENSE](LICENSE) for details.