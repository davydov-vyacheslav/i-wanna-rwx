//
//  MovieSearchItemCard.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI

struct MovieSearchItemCard: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @Environment(\.dismiss) var dismiss
    let item: ExternalMovieItem
    let isInLibrary: Bool

    var body: some View {
        Button {
            Task {
                
                if !isInLibrary {
                    await viewModel.addItem(MovieItem(
                        description: item.itemDescription,
                        isFavourite: item.isFavourite,
                        rating: item.rating ?? "N/A",
                        sourceUrl: item.sourceUrl,
                        status: .PLANNED,
                        title: item.title,
                        year: item.year,
                        author: item.author,
                        sourceName: item.sourceName,
                        type: item.type,
                        sourceId: item.sourceId,
                        originalTitle: item.originalTitle
                    ), item.coverUrl)
                    dismiss()
                }
            }
        } label: {
            HStack {
                CachedAsyncImage(
                    imageData: item.coverImageData,
                    url: item.coverUrl,
                    width: 80,
                    height: 112,
                    placeholder: "film.fill"
                )
                
                let yearText = item.year != nil ? String(item.year!) : "—"
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)

                    HStack {
                        if item.type == .TV_SERIES {
                            Image(systemName: "tv")
                                .foregroundColor(.secondary)
                        } else {
                            Image(systemName: "film")
                                .foregroundColor(.secondary)
                        }
                        
                        Text(verbatim: yearText)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(verbatim: "⭐️ \(item.rating ?? "N/A")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let author = item.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(item.isDraft() ? ".label_no_author_draft" : ".label_no_author")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                }
                
                Spacer()
                
                if isInLibrary {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .disabled(isInLibrary)
    }
}
