//
//  ParallelApp.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import SwiftData

@main
struct ParallelApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Message.self,
            DiaryEntry.self,
            CalendarEvent.self,
            LocationShare.self,
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

