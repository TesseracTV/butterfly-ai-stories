//
//  APIService.swift
//  Butterfly AI Stories
//

import Foundation

struct DeviceRegistrationResponse: Decodable {
    let api_key: String
}

struct GenerateStoryResponse: Decodable {
    let story: String?
    let tokens_used: Int?
}

struct GenerateStoryRequest: Encodable {
    let image: String
    let prompt: String
    let device_id: String
}

final class APIService {
    static let shared = APIService()

    func registerDevice(deviceId: String) async throws -> String {
        guard let url = APIConfig.Endpoint.registerDevice.url else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["device_id": deviceId])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError }

        if http.statusCode != 200 {
            if http.statusCode == 403 || http.statusCode == 401 { throw APIError.invalidAPIKey }
            throw APIError.deviceRegistrationFailed
        }
        let decoded = try JSONDecoder().decode(DeviceRegistrationResponse.self, from: data)
        let key = decoded.api_key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, key.count >= 20 else { throw APIError.invalidAPIKey }
        return key
    }

    func generateStory(imageDataURL: String, prompt: String, deviceId: String, apiKey: String) async throws -> (story: String?, tokensUsed: Int) {
        guard let url = APIConfig.Endpoint.generateStory.url else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONEncoder().encode(GenerateStoryRequest(image: imageDataURL, prompt: prompt, device_id: deviceId))
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.networkError }

        if http.statusCode == 403 || http.statusCode == 401 { throw APIError.invalidAPIKey }
        if http.statusCode != 200 { throw APIError.storyGenerationFailed }

        let decoded = try JSONDecoder().decode(GenerateStoryResponse.self, from: data)
        return (decoded.story, decoded.tokens_used ?? 0)
    }
}
