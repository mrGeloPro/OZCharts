//
//  DemoAppStructureTests.swift
//  OZChartsTests
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation
import XCTest

final class DemoAppStructureTests: XCTestCase {
    private let fileManager = FileManager.default

    func testDemoAppExamplesAreSplitIntoHandoffFolders() throws {
        let root = try repositoryRoot()
        let requiredPaths = [
            "DemoApp/DemoApp/ContentView.swift",
            "DemoApp/DemoApp/Home/OZDemoHomeView.swift",
            "DemoApp/DemoApp/Showcase/AllFeaturesShowcaseView.swift",
            "DemoApp/DemoApp/Showcase/ShowcaseHeroChart.swift",
            "DemoApp/DemoApp/Shared/DemoComponents.swift",
            "DemoApp/DemoApp/Shared/DemoStableIDs.swift",
            "DemoApp/DemoApp/Demos/Core/ViewportControlsDemoView.swift",
            "DemoApp/DemoApp/Demos/Core/LinkedChartsDemoView.swift",
            "DemoApp/DemoApp/Demos/Core/SelectableAnnotationsDemoView.swift",
            "DemoApp/DemoApp/Demos/Product/AccuracyDemoView.swift",
            "DemoApp/DemoApp/Demos/Product/DonutScoreDemoView.swift",
            "DemoApp/DemoApp/Demos/Product/StarAchievementDemoView.swift",
            "DemoApp/DemoApp/Demos/Advanced/LiveTrackingDemoView.swift",
            "DemoApp/DemoApp/Scenarios/DemoScenarioModels.swift",
            "DemoApp/DemoApp/Scenarios/DemoScenarioRendering.swift",
            "DemoApp/DemoApp/Scenarios/DemoScenarioStore.swift"
        ]

        for path in requiredPaths {
            XCTAssertTrue(
                fileManager.fileExists(atPath: root.appendingPathComponent(path).path),
                "Missing demo handoff file: \(path)"
            )
        }

        XCTAssertFalse(
            fileManager.fileExists(atPath: root.appendingPathComponent("DemoApp/DemoApp/DemoShowcaseViews.swift").path),
            "Demo showcase should stay split instead of returning to a monolithic file."
        )
    }

    func testDemoHomeKeepsProductAndCatalogRoutesVisible() throws {
        let root = try repositoryRoot()
        let home = try String(
            contentsOf: root.appendingPathComponent("DemoApp/DemoApp/Home/OZDemoHomeView.swift"),
            encoding: .utf8
        )

        [
            "LiveTrackingDemoView",
            "RealWorldScenariosView",
            "AccuracyDemoView",
            "StarAchievementDemoView",
            "DonutScoreDemoView",
            "AllFeaturesShowcaseView",
            "ViewportControlsDemoView",
            "SelectableAnnotationsDemoView"
        ].forEach {
            XCTAssertTrue(home.contains($0), "Home route is missing \($0).")
        }
    }

    func testDemoExamplesStaySmallEnoughToRead() throws {
        let root = try repositoryRoot()
        let demoRoot = root.appendingPathComponent("DemoApp/DemoApp")
        let swiftFiles = try fileManager
            .subpathsOfDirectory(atPath: demoRoot.path)
            .filter { $0.hasSuffix(".swift") }

        for relativePath in swiftFiles {
            let fileURL = demoRoot.appendingPathComponent(relativePath)
            let lineCount = try String(contentsOf: fileURL, encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
                .count
            XCTAssertLessThanOrEqual(
                lineCount,
                420,
                "\(relativePath) is getting hard to scan; split it before handoff."
            )
        }
    }

    private func repositoryRoot() throws -> URL {
        var url = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        while url.path != "/" {
            if fileManager.fileExists(atPath: url.appendingPathComponent("Package.swift").path),
               fileManager.fileExists(atPath: url.appendingPathComponent("DemoApp").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        throw XCTSkip("Repository root was not found.")
    }
}
