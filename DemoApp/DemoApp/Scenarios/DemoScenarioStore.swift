//
//  DemoScenarioStore.swift
//  DemoApp
//
//  Created by Oleh Hulovatyi.
//  Copyright (c) 2026 Oleh Hulovatyi. All rights reserved.
//

import Foundation

enum DemoScenarioStore {
    static let scenarios: [DemoScenario] = loadScenarios()

    private static func loadScenarios() -> [DemoScenario] {
        guard let url = Bundle.main.url(forResource: "DemoScenarios", withExtension: "json") else {
            assertionFailure("DemoScenarios.json is missing from the app bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(DemoScenarioCatalog.self, from: data).scenarios
        } catch {
            assertionFailure("Failed to decode DemoScenarios.json: \(error)")
            return []
        }
    }
}

enum DemoScenarioDateParser {
    static func date(from value: String) -> Date {
        if let date = formatter.date(from: value) {
            return date
        }
        assertionFailure("Invalid scenario date: \(value)")
        return Date(timeIntervalSince1970: 0)
    }

    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
