//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct BookSearchItemCard: View {
    @EnvironmentObject var viewModel: BooksViewModel
    @Environment(\.dismiss) var dismiss
    let item: ExternalBookItem
    let isInLibrary: Bool
    let selectedService: (any SearchService<ExternalBookItem>)?

    var body: some View {
        Button {
            Task {
                if !isInLibrary {
                    let detailedItem = try await selectedService?.getDetails(item: item) ?? item
                    await viewModel.addItem(BookItem(
                        description: detailedItem.itemDescription,
                        isFavourite: detailedItem.isFavourite,
                        rating: detailedItem.rating,
                        sourceUrl: detailedItem.sourceUrl,
                        status: MediaStatus.PLANNED.rawValue,
                        title: detailedItem.title,
                        year: detailedItem.year,
                        isbn: detailedItem.isbn,
                        author: detailedItem.author,
                        sourceName: detailedItem.sourceName
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
                    placeholder: "book.fill"
                )
                
                let yearText = item.year != nil ? String(item.year!) : "—"
                let ratingText = String(format: "%.1f", item.rating)
                
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)

                    HStack {
                        Text(verbatim: yearText)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if ratingText != "0.0" {
                            Text(verbatim: "⭐️ \(ratingText)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let author = item.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(item.isDraft() ? ".label.common_media.draft.no_author" : ".label.common_media.no_author")
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





#Preview {
    BookSearchItemCard(item: ExternalBookItem(
        title: "title",
        sourceUrl: URL(string: "https://google.com")!,
        sourceName: "Test service",
        description: "Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere",
        rating: 5.0,
        status: MediaStatus.PLANNED,
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: 1999,
    ), isInLibrary: false, selectedService: XDummyBookSearchService())
    BookSearchItemCard(item: ExternalBookItem(
        title: "title",
        sourceUrl: URL(string: "https://google.com")!,
        sourceName: "Test service",
        description: nil,
        rating: nil,
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: nil,
    ), isInLibrary: false, selectedService: XDummyBookSearchService())
    BookSearchItemCard(item: ExternalBookItem(
        title: "title",
        sourceUrl: URL(string: "https://google.com")!,
        sourceName: "Test service",
        description: nil,
        rating: nil,
        status: MediaStatus.DONE,
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: nil,
    ), isInLibrary: true, selectedService: XDummyBookSearchService())

}
