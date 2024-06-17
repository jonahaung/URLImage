//
//  PostUpdateAction.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//

import SwiftUI

/// The state of a network image loading operation.
public enum URLImageState: Equatable {
    /// No image is loaded.
    case empty
    
    /// An image successfully loaded.
    case success(image: Image, idealSize: CGSize)
    
    /// An image failed to load.
    case failure
    
    /// The loaded image, if any.
    public var image: Image? {
        guard case .success(let image, _) = self else {
            return nil
        }
        return image
    }
}
