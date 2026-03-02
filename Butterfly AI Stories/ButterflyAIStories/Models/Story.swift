//
//  Story.swift
//  Butterfly AI Stories
//

import Foundation
import UIKit

struct Story: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    let storyText: String
    let createdDate: Date
    let storyType: StoryType

    init(id: UUID = UUID(), image: UIImage, storyText: String, storyType: StoryType) {
        self.id = id
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.storyText = storyText
        self.createdDate = Date()
        self.storyType = storyType
    }

    var image: UIImage? {
        UIImage(data: imageData)
    }
}
