//
//  URLImageLoader.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//

import CoreGraphics
import Foundation
import ImageIO

public protocol URLImageLoader: AnyObject, Sendable {
    func image(from url: URL, quality: ImageQuality) async throws -> CGImage
}

public actor DefaultURLImageLoader {
    private enum Constants {
        static let memoryCapacity = 10 * 1024 * 1024
        static let diskCapacity = 100 * 1024 * 1024
        static let timeoutInterval: TimeInterval = 15
    }
    
    private let data: (URL) async throws -> (Data, URLResponse)
    private let cache: URLImageCache
    private let imageResizer = DefaultImageResizer()
    
    private var ongoingTasks: [String: Task<CGImage, Error>] = [:]
    public init(cache: URLImageCache, session: URLSession) {
        self.init(cache: cache, data: session.data(from:))
    }
    public static let shared = DefaultURLImageLoader(
        cache: .default,
        session: .imageLoading(
            memoryCapacity: Constants.memoryCapacity,
            diskCapacity: Constants.diskCapacity,
            timeoutInterval: Constants.timeoutInterval
        )
    )
    
    init(
        cache: URLImageCache,
        data: @escaping (URL) async throws -> (Data, URLResponse)
    ) {
        self.data = data
        self.cache = cache
    }
}

extension DefaultURLImageLoader: URLImageLoader {
    public func image(from url: URL, quality: ImageQuality) async throws -> CGImage {
        let cachingKey = cachingKey(for: url, quality: quality)
        if let image = self.cache.image(for: cachingKey) {
            return image
        }
        if let task = self.ongoingTasks[cachingKey] {
            return try await task.value
        }
        let task = Task<CGImage, Error> {
            let (data, response) = try await self.data(url)
            self.ongoingTasks.removeValue(forKey: cachingKey)
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  200..<300 ~= statusCode
            else {
                throw URLError(.badServerResponse)
            }
            guard
                let source = CGImageSourceCreateWithData(data as CFData, nil),
                let image = CGImageSourceCreateImageAtIndex(
                    source, 0,
                    [kCGImageSourceShouldCache: true] as CFDictionary
                ),
                let resizedImage = imageResizer.resize(from: image, quality: quality)
            else {
                throw URLError(.cannotDecodeContentData)
            }
            self.cache.setImage(resizedImage, for: cachingKey)
            return resizedImage
        }
        self.ongoingTasks[cachingKey] = task
        return try await task.value
    }
    
    private func cachingKey(for url: URL, quality: ImageQuality) -> String {
        switch quality {
        case .original:
            return url.absoluteString
        case .resized(let cGFloat):
            return url.absoluteString.appending("%2resized=\(cGFloat)")
        }
    }
}

extension URLImageLoader where Self == DefaultURLImageLoader {
    public static var `default`: Self {
        .shared
    }
}
