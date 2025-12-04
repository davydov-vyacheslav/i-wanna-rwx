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
    let item: BookItem
    let isInLibrary: Bool
    
    var body: some View {
        Button {
            Task {
                if !isInLibrary {
                    await viewModel.addItem(item)
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
                    
                    if let desc = item.itemDescription {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(4)
                    } else {
                        Text(".label_nodescription")
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
    BookSearchItemCard(item: BookItem(
        description: "Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere",
        isFavourite: true,
        rating: 5.0,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.PLANNED,
        title: "title",
        year: 1999), isInLibrary: false)
    BookSearchItemCard(item: BookItem(
        description: nil,
        isFavourite: false,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        title: "title",
        year: nil), isInLibrary: false)
    BookSearchItemCard(item: BookItem(
        description: nil,
        isFavourite: false,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.DONE,
        title: "title",
        year: nil), isInLibrary: true)

}
