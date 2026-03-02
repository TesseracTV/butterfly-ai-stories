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

    var gradientColors: [Color] {
        switch colorScheme {
        case .dark: return [.white.opacity(0.3), .clear, .black]
        case .light: return [.black.opacity(0.3), .clear, .white]
        @unknown default: return [.clear, .black.opacity(0.3)]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
                LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
            }
            .frame(height: 300)

            ScrollView {
                VStack(spacing: 0) {
                    Text(story)
                        .font(.body)
                        .lineSpacing(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
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
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSaveAlert = true
                } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
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
