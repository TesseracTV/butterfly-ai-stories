//
//  SavedStoriesView.swift
//  Butterfly AI Stories
//

import SwiftUI
import UIKit

struct SavedStoriesView: View {
    @StateObject private var storageManager = StorageManager.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(storageManager.savedStories) { story in
                    NavigationLink {
                        if let img = story.image {
                            StoryDetailView(image: img, story: story.storyText, storyType: story.storyType)
                        }
                    } label: {
                        HStack {
                            if let image = story.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            VStack(alignment: .leading) {
                                Text(story.storyType.rawValue)
                                    .font(.headline)
                                Text(story.createdDate, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteStories)
            }
            .navigationTitle("Saved Stories")
            .overlay {
                if storageManager.savedStories.isEmpty {
                    EmptyStateView(title: "No saved stories", message: "Stories you save will appear here", systemImage: "heart.slash")
                }
            }
        }
    }

    private func deleteStories(at offsets: IndexSet) {
        for index in offsets {
            let story = storageManager.savedStories[index]
            storageManager.deleteStory(story)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
