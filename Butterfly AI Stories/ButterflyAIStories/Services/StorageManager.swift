//
//  StorageManager.swift
//  Butterfly AI Stories
//

import Foundation

class StorageManager: ObservableObject {
    static let shared = StorageManager()
    @Published var savedStories: [Story] = []

    private let fileManager = FileManager.default

    private var storiesDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SavedStories", isDirectory: true)
    }

    private init() {
        createStoriesDirectoryIfNeeded()
        loadStories()
    }

    private func createStoriesDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: storiesDirectory.path) {
            try? fileManager.createDirectory(at: storiesDirectory, withIntermediateDirectories: true)
        }
    }

    func saveStory(_ story: Story) {
        savedStories.append(story)
        saveToStorage(story)
    }

    func deleteStory(_ story: Story) {
        savedStories.removeAll { $0.id == story.id }
        let storyURL = storiesDirectory.appendingPathComponent("\(story.id.uuidString).story")
        try? fileManager.removeItem(at: storyURL)
    }

    private func saveToStorage(_ story: Story) {
        let storyURL = storiesDirectory.appendingPathComponent("\(story.id.uuidString).story")
        if let encoded = try? JSONEncoder().encode(story) {
            try? encoded.write(to: storyURL)
        }
    }

    private func loadStories() {
        guard let files = try? fileManager.contentsOfDirectory(at: storiesDirectory, includingPropertiesForKeys: nil)
            .filter({ $0.pathExtension == "story" }) else { return }
        savedStories = files.compactMap { url in
            guard let data = try? Data(contentsOf: url),
                  let story = try? JSONDecoder().decode(Story.self, from: data) else { return nil }
            return story
        }
    }
}
