//
//  Configuration.swift
//  Butterfly AI Stories
//

import Foundation

enum AppEnvironment {
    case development
    case production

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

struct Configuration {
    static let shared = Configuration()
    private let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else { return [:] }
        return dict
    }()

    var apiBaseURLDevice: String {
        switch AppEnvironment.current {
        case .development:
            return infoDictionary["API_BASE_URL_DEVICE_DEV"] as? String ?? ""
        case .production:
            return infoDictionary["API_BASE_URL_DEVICE_PROD"] as? String ?? ""
        }
    }

    var apiBaseURLStory: String {
        switch AppEnvironment.current {
        case .development:
            return infoDictionary["API_BASE_URL_STORY_DEV"] as? String ?? ""
        case .production:
            return infoDictionary["API_BASE_URL_STORY_PROD"] as? String ?? ""
        }
    }
}
