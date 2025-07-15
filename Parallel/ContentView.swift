//
//  ContentView.swift
//  Parallel
//
//  Created by 黃浚銘 on 2025/7/15.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var appState = AppStateManager.shared
    
    var body: some View {
        Group {
            if appState.isFirstLaunch {
                WelcomeView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.isFirstLaunch)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
