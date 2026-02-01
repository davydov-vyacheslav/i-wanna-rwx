//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI
import Kingfisher

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
                    viewModel.addItem(BookItem(
                        description: detailedItem.itemDescription,
                        isFavorite: detailedItem.isFavorite,
                        rating: detailedItem.rating,
                        sourceUrl: detailedItem.sourceUrl,
                        coverImageUrl: detailedItem.coverUrl,
                        status: MediaStatus.planned,
                        title: detailedItem.title,
                        year: detailedItem.year,
                        isbn: detailedItem.isbn,
                        author: detailedItem.author,
                        sourceName: detailedItem.sourceName
                    ))
                    dismiss()
                }
            }
        } label: {
            HStack {
                KFImage(item.coverUrl)
                    .placeholder {
                        Image(systemName: "book.fill")
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
                        Text(verbatim: yearText)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(verbatim: "⭐️ \(item.ratingText)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let author = item.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(".label.common_media.no_author")
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
        status: MediaStatus.planned,
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
        status: MediaStatus.done,
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: nil,
    ), isInLibrary: true, selectedService: XDummyBookSearchService())

}
