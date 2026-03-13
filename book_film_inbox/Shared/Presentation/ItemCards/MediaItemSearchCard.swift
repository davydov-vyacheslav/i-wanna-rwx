//
//  xxxMediaItemSearchCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 04.02.2026.
//

import SwiftUI
import Kingfisher


struct MediaSearchItemCard<Item: ExternalMediaItem, PersistenceService: MediaPersistenceService>: View
where PersistenceService.Item == Item.MediaItem {
    
    @Environment(\.modelContext) private var modelContext
    let persistenceService: PersistenceService

    @Environment(\.dismiss) var dismiss
    let item: Item
    let isInLibrary: Bool
    let selectedService: (any SearchService<Item>)?
    let placeholderIcon: String // book.fill | film.fill
    let itemDetailedTypeIcon: String // tv | film | book
    let authorInfo: String?
    
    @State private var isAdding = false
    
    var body: some View {
        Button {
            guard !isAdding else { return }
            isAdding = true
            Task {
                if !isInLibrary {
                    let detailedItem = try await selectedService?.getDetails(item: item) ?? item
                    persistenceService.add(detailedItem.toCommonMediaItem())
                    dismiss()
                }
                isAdding = false
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
                    .retry(maxCount: 3, interval: .seconds(0.5))
                    .cacheOriginalImage()
                    .diskCacheExpiration(.days(7))
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 70)
                    .cornerRadius(8)
                    .clipped()
                    .accessibilityHidden(true)

                let yearText = item.year != nil ? String(item.year!) : "—"

                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.subheadline)

                    HStack {
                        Image(systemName: itemDetailedTypeIcon)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)

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
                        .accessibilityHidden(true)
                }
            }
        }
        .disabled(isInLibrary || isAdding)
        .accessibilityLabel(searchCardAccessibilityLabel)
        .accessibilityHint(isInLibrary
            ? Text(".accessibility.search_card.already_in_library")
            : Text(".accessibility.search_card.add_hint")
        )
    }

    private var searchCardAccessibilityLabel: Text {
        var parts: [String] = [item.title]
        if let year = item.year { parts.append(String(year)) }
        if let author = authorInfo { parts.append(author) }
        if isInLibrary {
            parts.append(String(localized: ".accessibility.search_card.already_in_library"))
        }
        return Text(parts.joined(separator: ", "))
    }
}
