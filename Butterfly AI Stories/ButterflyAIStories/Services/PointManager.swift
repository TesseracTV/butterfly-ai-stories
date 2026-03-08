//
//  PointManager.swift
//  Butterfly AI Stories
//

import Foundation
import SwiftUI

class PointManager: ObservableObject {
    static let shared = PointManager()

    @AppStorage("userPoints") private var storedPoints = 2000
    @Published private(set) var points: Int = 2000 {
        didSet { storedPoints = points }
    }

    private let pointsPerAd = 1500
    let storyBaseCost = 200
    /// Max points deducted per story (vision requests can report high token counts).
    private let maxCostPerStory = 500
    private let tokenToPointRatio = 4

    private init() {
        points = storedPoints
    }

    func deductPoints(tokens: Int) {
        let rawCost = max(storyBaseCost, tokens / tokenToPointRatio)
        let pointCost = min(rawCost, maxCostPerStory)
        DispatchQueue.main.async {
            self.points = max(0, self.points - pointCost)
        }
    }

    func addPointsFromAd() {
        DispatchQueue.main.async {
            self.points += self.pointsPerAd
        }
    }

    func addPoints(amount: Int) {
        DispatchQueue.main.async {
            self.points += amount
        }
    }

    var canGenerateStory: Bool {
        points >= storyBaseCost
    }

    func estimatedCost(forTokens tokens: Int) -> Int {
        min(max(storyBaseCost, tokens / tokenToPointRatio), maxCostPerStory)
    }
}
