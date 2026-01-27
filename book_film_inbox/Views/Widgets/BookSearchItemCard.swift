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

    var body: some View {
        Button {
            Task {
                if !isInLibrary {
                    await viewModel.addItem(BookItem(
                        description: item.itemDescription,
                        isFavourite: item.isFavourite,
                        rating: item.rating,
                        sourceUrl: item.sourceUrl,
                        status: .PLANNED,
                        title: item.title,
                        year: item.year,
                        isbn: item.isbn,
                        author: item.author,
                        sourceName: item.sourceName
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





#Preview {
    BookSearchItemCard(item: ExternalBookItem(
        description: "Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere",
        rating: 5.0,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.PLANNED,
        title: "title",
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: 1999,
        sourceName: "Test service"), isInLibrary: false)
    BookSearchItemCard(item: ExternalBookItem(
        description: nil,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        title: "title",
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: nil,
        sourceName: "Test service"), isInLibrary: false)
    BookSearchItemCard(item: ExternalBookItem(
        description: nil,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.DONE,
        title: "title",
        isbn: "12333333333",
        author: "Xxxx M.D.",
        year: nil,
        sourceName: "Test service"), isInLibrary: true)

}
