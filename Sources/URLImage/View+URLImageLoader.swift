//
//  PostUpdateAction.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//


import SwiftUI

extension View {
    public func networkImageLoader<T: URLImageLoader>(_ networkImageLoader: T) -> some View {
        environment(\.networkImageLoader, networkImageLoader)
    }
}

extension EnvironmentValues {
    var networkImageLoader: URLImageLoader {
        get { self[NetworkImageLoaderKey.self] }
        set { self[NetworkImageLoaderKey.self] = newValue }
    }
}

private struct NetworkImageLoaderKey: EnvironmentKey {
    static let defaultValue: URLImageLoader = .default
}
