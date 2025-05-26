//
//  AppIntent.swift
//  cobacloudkit
//
//  Created by Sessario Ammar Wibowo on 19/05/25.
//

import Foundation
import AppIntents

struct SearchItemsIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Items"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Search Query")
    var query: String

    static var parameterSummary: some ParameterSummary {
        Summary("Search for \(\.$query)")
    }

    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(query, forKey: "launchSearchQuery")
        return .result()
    }
}

struct SearchItemsShortcut: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchItemsIntent(),
            phrases: [
                "Show me \(\.$query) that are on Lost and found",
                "Search Lost and found for \(\.$query)"
            ],
            shortTitle: "Search LoFo",
            systemImageName: "magnifyingglass"
        )
    }
}
