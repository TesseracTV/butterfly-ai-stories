//
//  ButterflyAIStoriesApp.swift
//  Butterfly AI Stories
//

import SwiftUI

@main
struct ButterflyAIStoriesApp: App {
    @StateObject private var auth = AuthStore.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environmentObject(auth)
                    .tabItem {
                        Label("Create", systemImage: "wand.and.stars")
                    }
                SavedStoriesView()
                    .tabItem {
                        Label("Saved", systemImage: "heart.fill")
                    }
            }
            .task { await auth.ensureRegistered() }
        }
    }
}
