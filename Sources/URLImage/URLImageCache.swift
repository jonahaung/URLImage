//
//  URLImageCache.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//

import CoreGraphics
import Foundation

public protocol URLImageCache: AnyObject, Sendable {
    func image(for key: String) -> CGImage?
    func setImage(_ image: CGImage, for key: String)
}

public class DefaultURLImageCache {
    private enum Constants {
        static let defaultCountLimit = 100
    }
    private let cache = NSCache<NSString, CGImage>()
    public init(countLimit: Int = 0) {
        self.cache.countLimit = countLimit
    }
    public static let shared = DefaultURLImageCache(countLimit: Constants.defaultCountLimit)
}

extension DefaultURLImageCache: URLImageCache, @unchecked Sendable {
    public func image(for key: String) -> CGImage? {
        self.cache.object(forKey: key as NSString)
    }
    
    public func setImage(_ image: CGImage, for key: String) {
        self.cache.setObject(image, forKey: key as NSString)
    }
}

extension URLImageCache where Self == DefaultURLImageCache {
    static var `default`: Self {
        .shared
    }
}
