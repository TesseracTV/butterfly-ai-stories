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
        print("[Butterfly] Store: fetchPackages started")
        #if canImport(RevenueCat)
        func doFetch() async {
            do {
                let offerings = try await Purchases.shared.offerings()
                let offering = offerings.offering(identifier: "points_packages")
                    ?? offerings.current
                    ?? offerings.offering(identifier: "default")
                    ?? offerings.all.values.first
                if let offering = offering, !offering.availablePackages.isEmpty {
                    revenueCatPackages = offering.availablePackages
                    packages = revenueCatPackages.map {
                        StorePackage(id: $0.identifier, identifier: $0.identifier, localizedPriceString: $0.localizedPriceString)
                    }
                    print("[Butterfly] RevenueCat: Loaded \(packages.count) packages from offering '\(offering.identifier)'")
                } else {
                    print("[Butterfly] RevenueCat: No packages. Offerings:")
                    for (id, off) in offerings.all {
                        print("[Butterfly]   - '\(id)': \(off.availablePackages.count) packages")
                    }
                    if offerings.all.isEmpty {
                        print("[Butterfly] RevenueCat: offerings.all is empty. Add an offering and products in RevenueCat Dashboard.")
                    } else if let off = offerings.offering(identifier: "points_packages"), off.availablePackages.isEmpty {
                        print("[Butterfly] RevenueCat: 'points_packages' has 0 packages. Attach products in Dashboard.")
                    }
                }
            } catch {
                print("[Butterfly] RevenueCat error:", error.localizedDescription)
            }
        }
        await doFetch()
        if packages.isEmpty {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await doFetch()
        }
        #else
        print("[Butterfly] RevenueCat SDK not linked. Add the RevenueCat package to the target.")
        #endif
        print("[Butterfly] Store: fetchPackages done, packages.count = \(packages.count)")
        isLoading = false
    }
}
