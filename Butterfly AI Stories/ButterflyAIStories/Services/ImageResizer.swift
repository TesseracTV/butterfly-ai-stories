//
//  ImageResizer.swift
//  Butterfly AI Stories
//

import UIKit

class ImageResizer {
    static func resize(image: UIImage, to targetSize: CGSize) async -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            let scale = max(
                targetSize.width / image.size.width,
                targetSize.height / image.size.height
            )
            let scaledWidth = image.size.width * scale
            let scaledHeight = image.size.height * scale
            let drawRect = CGRect(
                x: (targetSize.width - scaledWidth) * 0.5,
                y: (targetSize.height - scaledHeight) * 0.5,
                width: scaledWidth,
                height: scaledHeight
            )
            image.draw(in: drawRect)
        }
    }
}
