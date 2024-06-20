//
//  ImageResizer.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 20/6/24.
//

import Foundation
import CoreImage

protocol ImageResizer {
    func resize(from image: CGImage, quality: ImageQuality) -> CGImage?
}

struct DefaultImageResizer: ImageResizer {
    func resize(from image: CGImage, quality: ImageQuality) -> CGImage? {
        switch quality {
        case .original:
            return image
        case .resized(let cGFloat):
            return image.resize(preferredWidth: cGFloat)
        }
    }
}
private extension CGImage {
    func resize(preferredWidth: CGFloat) -> CGImage? {
        let oldWidth = CGFloat(self.width)
        let scaleFactor = preferredWidth / oldWidth
        
        let newHeight = Int(CGFloat(self.height) * scaleFactor)
        let newWidth = Int(oldWidth * scaleFactor)
        
        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = newWidth * bytesPerPixel
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: self.alphaInfo.rawValue
        ) else { return nil }
        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        return context.makeImage()
    }
}
