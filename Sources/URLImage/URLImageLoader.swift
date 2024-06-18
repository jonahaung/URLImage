//
//  PostUpdateAction.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//

import CoreGraphics
import Foundation
import ImageIO

public protocol URLImageLoader: AnyObject, Sendable {
    func image(from url: URL) async throws -> CGImage
}

public actor DefaultNetworkImageLoader {
    private enum Constants {
        static let memoryCapacity = 10 * 1024 * 1024
        static let diskCapacity = 100 * 1024 * 1024
        static let timeoutInterval: TimeInterval = 15
    }
    
    private let data: (URL) async throws -> (Data, URLResponse)
    private let cache: URLImageCache
    
    private var ongoingTasks: [URL: Task<CGImage, Error>] = [:]
    public init(cache: URLImageCache, session: URLSession) {
        self.init(cache: cache, data: session.data(from:))
    }
    public static let shared = DefaultNetworkImageLoader(
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

extension DefaultNetworkImageLoader: URLImageLoader {
    public func image(from url: URL) async throws -> CGImage {
        if let image = self.cache.image(for: url) {
            return image
        }
        
        if let task = self.ongoingTasks[url] {
            return try await task.value
        }
        
        let task = Task<CGImage, Error> {
            let (data, response) = try await self.data(url)
            
            // remove ongoing task
            self.ongoingTasks.removeValue(forKey: url)
            
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
                )
            else {
                throw URLError(.cannotDecodeContentData)
            }
            
            // add image to cache
            self.cache.setImage(image, for: url)
            
            return image
        }
        
        // add ongoing task
        self.ongoingTasks[url] = task
        
        return try await task.value
    }
}

extension URLImageLoader where Self == DefaultNetworkImageLoader {
    /// The shared default network image loader.
    public static var `default`: Self {
        .shared
    }
}
