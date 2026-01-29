//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct BookItemCard: View {
    @EnvironmentObject var viewModel: BooksViewModel
    @EnvironmentObject var appState: AppState
    let item: BookItem
    @State private var showingProgressSheet = false
    @State private var showDescription = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 8) {
                // Poster
                CachedAsyncImage(
                    imageData: item.coverImageData,
                    url: nil,
                    width: 80,
                    height: 116,
                    placeholder: "book.fill"
                )
                .onTapGesture {
                    UIApplication.shared.open(item.sourceUrl)
                }

                // Content
                VStack(alignment: .leading, spacing: 1) {
                    // Title
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(item.isDraft() ? .gray : .orange)
                        
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(2)
                    }
                    
                    // Meta + Actions Buttons
                    HStack(spacing: 8) {
                        
                        Text(item.year.map(String.init) ?? "—")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if item.rating > 0 {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", item.rating))
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button {
                                viewModel.toggleFavorite(item)
                            } label: {
                                Image(systemName: item.isFavourite ? "heart.fill" : "heart")
                                    .foregroundColor(item.isFavourite ? .red : .secondary)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 16)
                            
                            if item.mediaStatus == .DONE {
                                Button {
                                    viewModel.changeStatus(item, to: .PLANNED)
                                } label: {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .frame(width: 16)
                            }
                            
                            if item.mediaStatus == .PLANNED {
                                Button {
                                    viewModel.changeStatus(item, to: .DONE)
                                } label: {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                                .buttonStyle(.plain)
                                .frame(width: 16)
                            }
                        }
                    }
                    .frame(height: 16)
                    
                    if let author = item.mainAuthor {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text(item.isDraft() ? ".label.common_media.draft.no_author" : ".label.common_media.no_author")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    // Badges
                    HStack(spacing: 6) {
                        if item.mediaStatus == .PLANNED {
                            StatusBadge(icon: "clock", text: ".type.media_status.planned", color: .blue)
                        } else if item.mediaStatus == .DONE {
                            StatusBadge(icon: "checkmark", text: ".type.media_status.seen", color: .green)
                        }
                        StatusBadge(icon: "magnifyingglass", text: .init(item.sourceName), color: .gray)
                    }
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    if let description = item.itemDescription {
                        appState.showDescriptionOverlay(description)
                    }
                }
                
            }
            
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}


#Preview {
    BookItemCard(item: BookItem(
        description: "Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere Some long long long descirptooin to be done hrere",
        isFavourite: true,
        rating: 5.0,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.PLANNED.rawValue,
        title: "title",
        year: 1999,
        isbn: "1234567",
        author: "Auhor M.V.",
        sourceName: "Test service"))
    BookItemCard(item: BookItem(
        description: nil,
        isFavourite: false,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        title: "title",
        year: nil,
        isbn: "NONE",
        author: "N/A",
        sourceName: CommonConstants.DraftSourceType))
    BookItemCard(item: BookItem(
        description: nil,
        isFavourite: false,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.DONE.rawValue,
        title: "title",
        year: nil,
        isbn: "NONE",
        author: "N/A",
        sourceName: "Test service"))

}
