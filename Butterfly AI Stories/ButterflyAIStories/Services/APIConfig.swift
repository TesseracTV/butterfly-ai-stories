//
//  APIConfig.swift
//  Butterfly AI Stories
//

import Foundation

enum APIConfig {
    private static let config = Configuration.shared

    enum Endpoint {
        case registerDevice
        case generateStory

        var url: URL? {
            switch self {
            case .registerDevice: return URL(string: config.apiBaseURLDevice)
            case .generateStory: return URL(string: config.apiBaseURLStory)
            }
        }
    }
}
