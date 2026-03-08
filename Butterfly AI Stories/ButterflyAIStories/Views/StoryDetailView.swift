//
//  StoryDetailView.swift
//  Butterfly AI Stories
//

import SwiftUI
import UIKit

struct StoryDetailView: View {
    let image: UIImage
    let story: String
    let storyType: StoryType

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var storageManager = StorageManager.shared
    @State private var showingSaveAlert = false
    @State private var isSaved = false

    private var parsedTitle: String? {
        let lines = story.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let first = lines.first?.trimmingCharacters(in: .whitespaces), !first.isEmpty else { return nil }
        if first.hasPrefix("**") && first.hasSuffix("**") {
            return String(first.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
        }
        return first.count < 80 ? first : nil
    }

    private var storyBody: String {
        guard let title = parsedTitle else { return story }
        let lines = story.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        if lines.count <= 1 { return story }
        return lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var gradientColors: [Color] {
        switch colorScheme {
        case .dark: return [.black.opacity(0.5), .clear, .black.opacity(0.8)]
        case .light: return [.black.opacity(0.4), .clear, .white.opacity(0.95)]
        @unknown default: return [.clear, .black.opacity(0.3)]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 280)
                    .clipped()
                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
            }
            .frame(height: 280)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let title = parsedTitle {
                        Text(title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    Text(parsedTitle != nil ? storyBody : story)
                        .font(.body)
                        .lineSpacing(10)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            isSaved = storageManager.savedStories.contains { $0.storyText == story }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.body.weight(.medium))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSaveAlert = true
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isSaved ? .red : .primary)
                }
            }
        }
        .alert("Save Story", isPresented: $showingSaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button(isSaved ? "Remove from Favorites" : "Add to Favorites") {
                if isSaved {
                    if let toRemove = storageManager.savedStories.first(where: { $0.storyText == story }) {
                        storageManager.deleteStory(toRemove)
                    }
                } else {
                    let newStory = Story(image: image, storyText: story, storyType: storyType)
                    storageManager.saveStory(newStory)
                }
                isSaved.toggle()
            }
        } message: {
            Text(isSaved ? "Would you like to remove this story from your favorites?" : "Would you like to add this story to your favorites?")
        }
    }
}
