//
//  UIImage.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation
import UIKit

extension UIImage {
    func scaled(scale: Double) -> UIImage {
        let scaledSize = CGSize(width: size.width / scale, height: size.height / scale)
        // Scale image
        let scaledImage = UIGraphicsImageRenderer(size: scaledSize).image { _ in
            draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        return scaledImage
    }
}
