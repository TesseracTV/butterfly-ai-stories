//
//  OnboardingView.swift
//  Butterfly AI Stories
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.dismiss) private var dismiss

    private let onboardingSteps = [
        OnboardingStep(image: "photo.fill", title: "Select or Take a Photo", description: "Choose a photo from your library or take a new one with your camera"),
        OnboardingStep(image: "wand.and.stars", title: "Generate Stories", description: "Our AI will create unique stories based on your photos"),
        OnboardingStep(image: "star.fill", title: "Earn Points", description: "Purchase points and generate more stories"),
        OnboardingStep(image: "heart.fill", title: "Save Favorites", description: "Save your favorite stories by tapping the heart icon in the top-right corner, revisit them anytime you like!")
    ]

    var body: some View {
        TabView {
            ForEach(onboardingSteps) { step in
                VStack(spacing: 28) {
                    Image(systemName: step.image)
                        .font(.system(size: 72))
                        .foregroundStyle(Color("Puerto Rico 3"))
                        .padding(.top, 20)
                    Text(step.title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text(step.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: 400)
                .tag(step.id)
            }
            VStack(spacing: 28) {
                Image(systemName: "butterfly.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Color("Puerto Rico 3"))
                    .padding(.top, 20)
                Text("Ready to Begin!")
                    .font(.title2.weight(.bold))
                Text("Start creating magical stories from your photos")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 32)
                Button {
                    hasCompletedOnboarding = true
                    dismiss()
                } label: {
                    Text("Get Started")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("Puerto Rico 3"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .frame(maxWidth: 400)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingStep: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}
