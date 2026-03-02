//
//  StoreView.swift
//  Butterfly AI Stories
//

import SwiftUI

struct StoreView: View {
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Puerto Rico 3")
                    .opacity(colorScheme == .dark ? 0.05 : 0.1)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Current Balance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            Text("\(PointManager.shared.points)")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("points")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)

                    if storeManager.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading Store...")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Text("Select Package")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if let package = storeManager.packages.first {
                                PurchaseButton(
                                    title: "5,000 Points",
                                    price: package.localizedPriceString,
                                    description: "Perfect for getting started",
                                    isPopular: true,
                                    isLoading: isPurchasing
                                ) {
                                    Task {
                                        isPurchasing = true
                                        let success = await storeManager.purchase(package: package)
                                        if success {
                                            showSuccess = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
                                        } else {
                                            showError = true
                                            errorMessage = "Purchase failed. Please try again."
                                        }
                                        isPurchasing = false
                                    }
                                }
                            } else {
                                Text("No packages available")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer()

                    VStack(spacing: 8) {
                        Text("Payment will be charged to your Apple ID account at the confirmation of purchase.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Restore Purchases") { }
                            .font(.caption)
                            .foregroundColor(Color("Puerto Rico 3"))
                    }
                    .padding(.bottom)
                }
                .padding(.vertical)

                if showSuccess {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Purchase Successful!")
                            .font(.title3.bold())
                        Text("+5,000 points")
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
                }
            }
            .navigationTitle("Get Points")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task { await storeManager.fetchPackages() }
            .animation(.spring(response: 0.3), value: showSuccess)
            .disabled(isPurchasing)
        }
    }
}

struct PurchaseButton: View {
    let title: String
    let price: String
    let description: String
    let isPopular: Bool
    let isLoading: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                if isPopular {
                    Text("MOST POPULAR")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Puerto Rico 3"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color("Puerto Rico 3").opacity(0.2)))
                }
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .padding(.top, 4)
                    } else {
                        Text(price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Puerto Rico 3"))
                            .padding(.top, 4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : .white)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}
