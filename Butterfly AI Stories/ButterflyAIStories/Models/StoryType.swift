//
//  StoryType.swift
//  Butterfly AI Stories
//

import Foundation

enum StoryType: String, Codable, CaseIterable, Identifiable {
    case childrensStory = "Children's Story"
    case adventureTale = "Adventure Tale"
    case fantasyStory = "Fantasy Story"
    case poetry = "Poetry"
    case descriptiveStory = "Descriptive Story"

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .childrensStory:
            return "Write a whimsical children's story inspired by this image. The story should be no more than 175 words and suitable for young readers aged 4-8. It should mimic a childrens book. Include imaginative characters, a magical setting, and a positive lesson or moral."
        case .adventureTale:
            return "Create a short adventure story about this image in 175 words. Create thrilling narratives full of discovery and wonder and suitable for young readers."
        case .fantasyStory:
            return "Create a short fantasy story about this image in 175 words. Include magical elements and suitable for young readers."
        case .poetry:
            return "Create a short poem about this image in 175 words. Find the deeper meaning in the image. Make it suitable for young readers."
        case .descriptiveStory:
            return "Create a rich, detailed narrative that brings out every nuance of this image in 175 words. Make it suitable for young readers."
        }
    }

    var iconName: String { "book" }
}
