//
//  AuthStore.swift
//  Butterfly AI Stories
//

import Foundation
import UIKit

private let deviceIdKey = "device_id"
private let apiKeyKey = "api_key"

@MainActor
final class AuthStore: ObservableObject {
    static let shared = AuthStore()

    @Published private(set) var deviceId: String?
    @Published private(set) var apiKey: String?
    @Published private(set) var isRegistering = false
    @Published private(set) var registrationError: String?

    var isRegistered: Bool { apiKey != nil && deviceId != nil }

    private init() {
        deviceId = KeychainService.load(forKey: deviceIdKey)
        apiKey = KeychainService.load(forKey: apiKeyKey)
        if deviceId == nil {
            deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            KeychainService.save(deviceId!, forKey: deviceIdKey)
        }
    }

    /// Call on launch to ensure we have an API key (register if needed).
    func ensureRegistered() async {
        if apiKey != nil { return }
        isRegistering = true
        registrationError = nil
        defer { isRegistering = false }

        guard let did = deviceId else { return }
        do {
            let key = try await APIService.shared.registerDevice(deviceId: did)
            apiKey = key
            KeychainService.save(key, forKey: apiKeyKey)
        } catch {
            registrationError = error.localizedDescription
        }
    }

    func clearRegistration() {
        apiKey = nil
        KeychainService.delete(forKey: apiKeyKey)
        // Optionally clear deviceId to get a new one on next launch
    }
}
