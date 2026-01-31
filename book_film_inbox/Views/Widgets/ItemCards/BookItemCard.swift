//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI
import Kingfisher

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
                KFImage(item.coverImageUrl)
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

                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(item.ratingText)
                            .font(.caption)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button {
                                viewModel.toggleFavorite(item)
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(item.isFavorite ? .red : .secondary)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 16)
                            
                            if item.status == .done {
                                Button {
                                    viewModel.changeStatus(item, to: .planned)
                                } label: {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .frame(width: 16)
                            }
                            
                            if item.status == .planned {
                                Button {
                                    viewModel.changeStatus(item, to: .done)
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
                        if item.status == .planned {
                            StatusBadge(icon: "clock", text: ".type.media_status.planned", color: .blue)
                        } else if item.status == .done {
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
        isFavorite: true,
        rating: 5.0,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.planned,
        title: "title",
        year: 1999,
        isbn: "1234567",
        author: "Auhor M.V.",
        sourceName: "Test service"))
    BookItemCard(item: BookItem(
        description: nil,
        isFavorite: false,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        title: "title",
        year: nil,
        isbn: "NONE",
        author: "N/A",
        sourceName: CommonConstants.draftSourceType))
    BookItemCard(item: BookItem(
        description: nil,
        isFavorite: false,
        rating: nil,
        sourceUrl: URL(string: "https://google.com")!,
        status: MediaStatus.done,
        title: "title",
        year: nil,
        isbn: "NONE",
        author: "N/A",
        sourceName: "Test service"))

}
