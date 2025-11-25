//
//  CachedAsyncImage.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 25.11.2025.
//

import SwiftUI

struct CachedAsyncImage: View {
    let imageData: Data?
    let url: URL?
    let width: CGFloat
    let height: CGFloat
    let placeholder: String
    
    var body: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .background(Color.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

