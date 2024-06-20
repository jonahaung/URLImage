//
//  ImageQuality.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 20/6/24.
//

import Foundation

public enum ImageQuality: Hashable, Equatable, Sendable {
    case original
    case resized(CGFloat)
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .original:
            break
        case .resized(let cGFloat):
            cGFloat.hash(into: &hasher)
        }
    }
}
