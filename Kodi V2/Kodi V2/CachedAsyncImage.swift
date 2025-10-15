//
//  CachedAsyncImage.swift
//  Kodi V2
//
//  Drop-in replacement for AsyncImage with caching support
//

import SwiftUI

/// AsyncImage replacement with automatic caching
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var loader = ImageLoader()
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .onAppear {
            if let url = url {
                loader.load(url: url)
            }
        }
        .onChange(of: url) { newURL in
            if let newURL = newURL {
                loader.load(url: newURL)
            }
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

// Convenience initializer matching AsyncImage API
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { Color.gray }
        )
    }
}

// Preview
#Preview {
    CachedAsyncImage(
        url: URL(string: "https://via.placeholder.com/300")
    ) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    } placeholder: {
        Color.gray
            .overlay(
                ProgressView()
                    .tint(.white)
            )
    }
    .frame(width: 300, height: 300)
}

