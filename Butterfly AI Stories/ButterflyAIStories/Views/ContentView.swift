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
            ScrollView {
                VStack(spacing: 25) {
                    pointsSection
                    imageSection
                    storyTypePicker
                    buttonSection
                }
            }
            .navigationTitle("Butterfly AI Stories")
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
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(pointManager.points) points")
                    .font(.headline)
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? nil : .infinity, alignment: .leading)

            Spacer()

            Button {
                showPointsOptions = true
            } label: {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Get Points")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("Puerto Rico 3"))
                .foregroundColor(.primary)
                .cornerRadius(20)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
        .padding(.horizontal)
    }

    private var imageSection: some View {
        Group {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Image("preview-image")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onAppear {
                        if selectedImage == nil {
                            selectedImage = UIImage(named: "preview-image")
                        }
                    }
            }
        }
        .padding(.horizontal)
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
                    .frame(width: 20)
                    .foregroundStyle(Color("Sweet Gray"))
                Text(selectedStoryType.rawValue)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("Sweet Gray"))
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color("Sweet Gray"))
            }
            .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
            .padding()
            .background(isGenerating ? Color("Puerto Rico 3").opacity(0.4) : Color("Puerto Rico 3").opacity(0.8))
            .cornerRadius(10)
        }
        .disabled(isGenerating)
        .opacity(isGenerating ? 0.6 : 1)
        .padding(.horizontal)
    }

    private var buttonSection: some View {
        VStack(spacing: 15) {
            Button {
                showingImageSource = true
            } label: {
                HStack {
                    Image(systemName: "photo.fill")
                    Text(selectedImage == nil ? "Select Photo" : "Change Photo")
                }
                .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                .padding()
                .background(isGenerating ? Color("Sweet Gray").opacity(0.6) : Color("Sweet Gray"))
                .foregroundColor(Color("Puerto Rico 3"))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
            .disabled(isGenerating)
            .opacity(isGenerating ? 0.6 : 1)

            if selectedImage != nil {
                Button {
                    Task { await generateStory() }
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Generate Story")
                        if isGenerating {
                            Spacer()
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                    .padding()
                    .background(isGenerating ? Color("Sweet Gray").opacity(0.6) : Color("Sweet Gray"))
                    .foregroundColor(Color("Puerto Rico 3"))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                }
                .disabled(isGenerating)
            }
        }
        .padding(.horizontal)
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
