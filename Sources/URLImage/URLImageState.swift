//
//  PostUpdateAction.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//

import SwiftUI

/// The state of a network image loading operation.
public enum URLImageState: Equatable {
    case empty
    case success(image: Image, idealSize: CGSize)
    case failure
    public var image: Image? {
        guard case .success(let image, _) = self else {
            return nil
        }
        return image
    }
}
