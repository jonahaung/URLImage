//
//  PostUpdateAction.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//


import Foundation

extension URLSession {

    public static func imageLoading(
        memoryCapacity: Int,
        diskCapacity: Int,
        timeoutInterval: TimeInterval
    ) -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity)
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.httpAdditionalHeaders = ["Accept": "image/*"]
        
        return .init(configuration: configuration)
    }
}
