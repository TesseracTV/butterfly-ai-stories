//
//  ContentView.swift
//  Butterfly AI Stories
//

import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @EnvironmentObject var auth: AuthStore
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @StateObject private var pointManager = PointManager.shared
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isGenerating = false
    @State private var generatedStory = ""
    @State private var showError = false
    @State private var selectedStoryType: StoryType = .childrensStory
    @State private var showingImageSource = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingStoryDetail = false
    @State private var errorMessage = ""
    @State private var showInsufficientPointsAlert = false
    @State private var showPointsOptions = false
    @State private var showingStoreView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pointsSection
                    .padding(.top, 8)
                ScrollView {
                    VStack(spacing: 24) {
                        imageSection
                        storyTypePicker
                        buttonSection
                    }
                    .padding(.vertical, 20)
                    .padding(.bottom, 32)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Butterfly AI Stories")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                    .edgesIgnoringSafeArea(.all)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .confirmationDialog("Choose Image Source", isPresented: $showingImageSource) {
                Button("Camera") {
                    sourceType = .camera
                    isImagePickerPresented = true
                }
                Button("Photo Library") {
                    sourceType = .photoLibrary
                    isImagePickerPresented = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $showingStoryDetail) {
                if let image = selectedImage {
                    StoryDetailView(image: image, story: generatedStory, storyType: selectedStoryType)
                }
            }
            .alert("Insufficient Points", isPresented: $showInsufficientPointsAlert) {
                Button("Get Points") { showingStoreView = true }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You need more points to generate a story. Would you like to get more points?")
            }
        }
        .sheet(isPresented: .constant(!hasCompletedOnboarding)) {
            OnboardingView()
        }
        .sheet(isPresented: $showingStoreView) {
            StoreView()
        }
        .confirmationDialog("Get More Points", isPresented: $showPointsOptions) {
            Button("Purchase Points") { showingStoreView = true }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose how to get more points")
        }
    }

    private var pointsSection: some View {
        HStack(spacing: horizontalSizeClass == .regular ? 20 : 12) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.body)
                    .foregroundStyle(.yellow)
                Text("\(pointManager.points) points")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? nil : .infinity, alignment: .leading)

            Spacer()

            Label("Get Points", systemImage: "play.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
                .background(Color("Puerto Rico 3"))
                .clipShape(Capsule())
                .contentShape(Rectangle())
                .onTapGesture(count: 1) {
                    showingStoreView = true
                }
        }
        .padding(16)
        .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var imageSection: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                    .frame(height: 280)
                    .clipped()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 280)
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text("Tap to add a photo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .onAppear {
                        if selectedImage == nil {
                            selectedImage = UIImage(named: "preview-image")
                        }
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    private var storyTypePicker: some View {
        Menu {
            Picker("Story Type", selection: $selectedStoryType) {
                ForEach(StoryType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                Text(selectedStoryType.rawValue)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.down.circle.fill")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isGenerating ? Color("Puerto Rico 3").opacity(0.5) : Color("Puerto Rico 3"))
            )
        }
        .disabled(isGenerating)
        .opacity(isGenerating ? 0.7 : 1)
        .padding(.horizontal, 20)
    }

    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                showingImageSource = true
            } label: {
                Label(selectedImage == nil ? "Select Photo" : "Change Photo", systemImage: "photo.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .foregroundStyle(Color("Puerto Rico 3"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(isGenerating)
            .opacity(isGenerating ? 0.6 : 1)

            if selectedImage != nil {
                Button {
                    Task { await generateStory() }
                } label: {
                    HStack(spacing: 8) {
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text("Generate Story")
                    }
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isGenerating ? Color("Puerto Rico 3").opacity(0.7) : Color("Puerto Rico 3"))
                    )
                    .foregroundStyle(.white)
                }
                .disabled(isGenerating)
            }
        }
        .padding(.horizontal, 20)
    }

    private func generateStory() async {
        guard pointManager.canGenerateStory else {
            showInsufficientPointsAlert = true
            return
        }
        guard let image = selectedImage,
              let apiKey = auth.apiKey,
              let deviceId = auth.deviceId else {
            errorMessage = "Please select a photo and try again."
            showError = true
            return
        }

        isGenerating = true
        defer { isGenerating = false }

        do {
            let resized = await ImageResizer.resize(image: image, to: CGSize(width: 224, height: 224))
            guard let jpeg = resized.jpegData(compressionQuality: 0.8) else {
                errorMessage = APIError.invalidResponse.localizedDescription
                showError = true
                return
            }
            let dataURL = "data:image/jpeg;base64," + jpeg.base64EncodedString()

            let (storyText, tokensUsed) = try await APIService.shared.generateStory(
                imageDataURL: dataURL,
                prompt: selectedStoryType.prompt,
                deviceId: deviceId,
                apiKey: apiKey
            )

            pointManager.deductPoints(tokens: tokensUsed)
            generatedStory = storyText ?? ""
            if !generatedStory.isEmpty {
                showingStoryDetail = true
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            showError = true
        }
    }
}
