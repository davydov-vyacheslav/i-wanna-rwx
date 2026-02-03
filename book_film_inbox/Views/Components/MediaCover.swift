//
//  MediaCover.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 03.02.2026.
//

import SwiftUI
import Kingfisher

struct MediaCover: View {
    let imageUrl: URL?
    let placeholderIcon: String
    let sourceUrl: URL
    let width: CGFloat
    let height: CGFloat
    
    init(
        imageUrl: URL?,
        placeholderIcon: String,
        sourceUrl: URL,
        width: CGFloat = 80,
        height: CGFloat = 116
    ) {
        self.imageUrl = imageUrl
        self.placeholderIcon = placeholderIcon
        self.sourceUrl = sourceUrl
        self.width = width
        self.height = height
    }
    
    var body: some View {
        KFImage(imageUrl)
            .placeholder {
                Image(systemName: placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipped()
            .onTapGesture {
                UIApplication.shared.open(sourceUrl)
            }
    }
}
