//
//  UIImage.swift
//  AITesting
//
//  Created by Russell Porter on 2024-10-18
//

import Foundation
import UIKit

extension UIImage {
    func resized(scale: Double) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        let scaledImage = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return scaledImage
    }
}
