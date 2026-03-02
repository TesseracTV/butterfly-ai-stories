//
//  APIError.swift
//  Butterfly AI Stories
//

import Foundation

enum APIError: LocalizedError {
    case deviceRegistrationFailed
    case invalidAPIKey
    case storyGenerationFailed
    case networkError
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .deviceRegistrationFailed:
            return "Failed to register device. Please try again."
        case .invalidAPIKey:
            return "Invalid API key received. Please try again."
        case .storyGenerationFailed:
            return "Failed to generate story. Please try again."
        case .networkError:
            return "Network error occurred. Please check your connection."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        }
    }
}
