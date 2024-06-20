//
//  URLImage.swift
//  HomeForYou
//
//  Created by Aung Ko Min on 11/6/24.
//


import SwiftUI
public struct URLImage<Content>: View where Content: View {
    @Environment(\.networkImageLoader) private var imageLoader
    @StateObject private var model = URLImageModel()
    
    private let source: ImageSource?
    private let transaction: Transaction
    private let content: (URLImageState) -> Content
    
    private var environment: URLImageModel.Environment {
        .init(transaction: self.transaction, imageLoader: self.imageLoader)
    }

    public init(url: URL?, quality: ImageQuality, scale: CGFloat = 1) where Content == _OptionalContent<Image> {
        self.init(
            url: url,
            quality: quality, 
            scale: scale
        ) { state in
            _OptionalContent(state.image)
        }
    }
    public init<I>(
        url: URL?,
        quality: ImageQuality,
        scale: CGFloat = 1,
        transaction: Transaction = .init(),
        @ViewBuilder content: @escaping (Image) -> I
    ) where Content == _OptionalContent<I>, I: View {
        self.init(
            url: url,
            quality: quality,
            scale: scale,
            transaction: transaction
        ) { state in
            _OptionalContent(state.image, content: content)
        }
    }
    public init<I, P>(
        url: URL?,
        quality: ImageQuality,
        scale: CGFloat = 1,
        transaction: Transaction = .init(),
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(
            url: url,
            quality: quality,
            scale: scale,
            transaction: transaction,
            content: { state in
                if let image = state.image {
                    content(image)
                } else {
                    placeholder()
                }
            }
        )
    }
    public init(
        url: URL?,
        quality: ImageQuality,
        scale: CGFloat = 1,
        transaction: Transaction = .init(),
        @ViewBuilder content: @escaping (URLImageState) -> Content
    ) {
        self.source = url.map { ImageSource(url: $0, quality: quality, scale: scale) }
        self.transaction = transaction
        self.content = content
    }
    
    public var body: some View {
        self.content(self.model.state.image)
            .modifier(
                TaskModifier(id: self.source) {
                    await self.model.onAppear(source: self.source, environment: self.environment)
                }
            )
//        if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
//            self.content(self.model.state.image)
//                .task(id: self.source) {
//                    await self.model.onAppear(source: self.source, environment: self.environment)
//                }
//        } else {
//            self.content(self.model.state.image)
//                .modifier(
//                    TaskModifier(id: self.source) {
//                        await self.model.onAppear(source: self.source, environment: self.environment)
//                    }
//                )
//        }
    }
}

public struct _OptionalContent<Content>: View where Content: View {
    private let image: Image?
    private let content: (Image) -> Content
    
    init(_ image: Image?, content: @escaping (Image) -> Content) {
        self.image = image
        self.content = content
    }
    
    public var body: some View {
        if let image {
            self.content(image)
        } else {
            Image.empty
                .resizable()
                .redacted(reason: .placeholder)
        }
    }
}

extension _OptionalContent where Content == Image {
    init(_ image: Image?) {
        self.init(image, content: { $0 })
    }
}

extension Image {
    fileprivate static var empty: Image {
#if canImport(UIKit)
        Image(uiImage: .init())
#elseif os(macOS)
        Image(nsImage: .init())
#endif
    }
}
