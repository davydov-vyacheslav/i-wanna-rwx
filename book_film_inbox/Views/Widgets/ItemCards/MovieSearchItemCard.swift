//
//  MovieSearchItemCard.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI
import Kingfisher

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
                    
                    viewModel.addItem(MovieItem(
                        description: detailedItem.itemDescription,
                        isFavorite: detailedItem.isFavorite,
                        rating: detailedItem.rating ?? 0.0,
                        sourceUrl: detailedItem.sourceUrl,
                        coverImageUrl: detailedItem.coverUrl,
                        status: .planned,
                        title: detailedItem.title,
                        year: detailedItem.year,
                        author: detailedItem.author,
                        sourceName: detailedItem.sourceName,
                        type: detailedItem.type,
                        sourceId: detailedItem.sourceId,
                        originalTitle: detailedItem.originalTitle
                    ))
                    dismiss()

                }
            }
        } label: {
            HStack {
                KFImage(item.coverUrl)
                    .placeholder {
                        Image(systemName: "film.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.secondary)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 116)
                    .clipped()
                
                let yearText = item.year != nil ? String(item.year!) : "—"
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)

                    HStack {
                        if item.type == .tvSeries {
                            Image(systemName: "tv")
                                .foregroundColor(.secondary)
                        } else {
                            Image(systemName: "film")
                                .foregroundColor(.secondary)
                        }
                        
                        Text(verbatim: yearText)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(verbatim: "⭐️ \(item.ratingText)")
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
