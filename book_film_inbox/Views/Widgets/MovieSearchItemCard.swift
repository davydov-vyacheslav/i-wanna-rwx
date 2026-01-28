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
    let selectedService: (any SearchService<ExternalMovieItem>)?

    var body: some View {
        Button {
            Task {
                
                if !isInLibrary {
                    let detailedItem = try await selectedService?.getDetails(item: item) ?? item
                    
                    await viewModel.addItem(MovieItem(
                        description: detailedItem.itemDescription,
                        isFavourite: detailedItem.isFavourite,
                        rating: detailedItem.rating ?? "N/A",
                        sourceUrl: detailedItem.sourceUrl,
                        status: .PLANNED,
                        title: detailedItem.title,
                        year: detailedItem.year,
                        author: detailedItem.author,
                        sourceName: detailedItem.sourceName,
                        type: detailedItem.type,
                        sourceId: detailedItem.sourceId,
                        originalTitle: detailedItem.originalTitle
                    ), detailedItem.coverUrl)
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
