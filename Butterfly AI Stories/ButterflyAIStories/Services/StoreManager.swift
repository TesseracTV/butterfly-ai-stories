//
//  StoreManager.swift
//  Butterfly AI Stories
//

import SwiftUI
#if canImport(RevenueCat)
import RevenueCat
#endif

struct StorePackage: Identifiable {
    let id: String
    let identifier: String
    let localizedPriceString: String
}

class StoreManager: ObservableObject {
    static let shared = StoreManager()
    @Published var packages: [StorePackage] = []
    @Published var isLoading = false

    #if canImport(RevenueCat)
    private var revenueCatPackages: [RevenueCat.Package] = []
    #endif

    private init() {
        setupRevenueCat()
    }

    private func setupRevenueCat() {
        #if canImport(RevenueCat)
        if let key = Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String, !key.isEmpty {
            Purchases.configure(withAPIKey: key)
            #if DEBUG
            Purchases.logLevel = .debug
            #endif
        }
        #endif
    }

    func purchase(package: StorePackage) async -> Bool {
        #if canImport(RevenueCat)
        guard let rcPackage = revenueCatPackages.first(where: { $0.identifier == package.identifier }) else { return false }
        do {
            let result = try await Purchases.shared.purchase(package: rcPackage)
            if result.transaction != nil {
                await MainActor.run { PointManager.shared.addPoints(amount: 5000) }
                return true
            }
            return false
        } catch {
            return false
        }
        #else
        return false
        #endif
    }

    @MainActor
    func fetchPackages() async {
        isLoading = true
        #if canImport(RevenueCat)
        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current ?? offerings.offering(identifier: "points_packages") {
                revenueCatPackages = current.availablePackages
                packages = revenueCatPackages.map {
                    StorePackage(id: $0.identifier, identifier: $0.identifier, localizedPriceString: $0.localizedPriceString)
                }
            }
        } catch { }
        #endif
        isLoading = false
    }
}
