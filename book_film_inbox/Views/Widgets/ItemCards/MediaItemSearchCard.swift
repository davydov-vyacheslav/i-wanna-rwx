//
//  xxxMediaItemSearchCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 04.02.2026.
//

import SwiftUI
import Kingfisher

struct MediaSearchItemCard<Item: ExternalMediaItem, ViewModel: MediaViewModelProtocol>: View
where ViewModel.Item == Item.MediaItem {
    
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    let item: Item
    let isInLibrary: Bool
    let selectedService: (any SearchService<Item>)?
    let placeholderIcon: String // book.fill | film.fill
    let itemDetailedTypeIcon: String // tv | film | book
    let authorInfo: String?
    
    var body: some View {
        Button {
            Task {
                if !isInLibrary {
                    let detailedItem = try await selectedService?.getDetails(item: item) ?? item
                    viewModel.addItem(detailedItem.toCommonMediaItem())
                    dismiss()
                }
            }
        } label: {
            HStack {
                KFImage(item.coverUrl)
                    .placeholder {
                        Image(systemName: placeholderIcon)
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
                        Image(systemName: itemDetailedTypeIcon)
                            .foregroundColor(.secondary)
                        
                        Text(verbatim: yearText)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(verbatim: "⭐️ \(item.ratingText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let author = authorInfo {
                        Text(author)
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
