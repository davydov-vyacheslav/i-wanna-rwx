//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct BookItemCard: View {
    @EnvironmentObject var viewModel: BooksViewModel
    let item: BookItem
    @State private var showingProgressSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Poster
                CachedAsyncImage(
                    imageData: item.coverImageData,
                    url: item.coverUrl,
                    width: 80,
                    height: 112,
                    placeholder: "book.fill"
                )

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(.orange)
                        
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(2)
                    }
                    
                    // Meta
                    HStack(spacing: 8) {
                        Text(item.year.map(String.init) ?? "—")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", item.rating))
                                .font(.caption)
                        }
                    }
                    
                    Text(item.itemDescription ?? "N/A")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Badges
                    HStack(spacing: 6) {
                        if item.mediaStatus == .IN_PROGRESS {
                            StatusBadge(icon: "clock", text: String(localized: "status.in_progress"), color: .blue)
                        }
                        if item.mediaStatus == .DONE {
                            StatusBadge(icon: "checkmark", text: "Просмотрено", color: .green)
                        }
                    }
                }
            }
            
            // Actions
            HStack(spacing: 8) {
                Spacer()
                
                Button {
                    viewModel.toggleFavorite(item)
                } label: {
                    Image(systemName: item.isFavourite ? "heart.fill" : "heart")
                        .foregroundColor(item.isFavourite ? .red : .secondary)
                }
                .buttonStyle(.plain)
                
                if item.mediaStatus != .PENDING {
                    Button {
                        viewModel.changeStatus(item, to: .PENDING)
                    } label: {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                if item.mediaStatus != .IN_PROGRESS && item.mediaStatus != .DONE {
                    Button {
                        viewModel.changeStatus(item, to: .IN_PROGRESS)
                    } label: {
                        Image(systemName: "play.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
                
                if item.mediaStatus != .DONE {
                    Button {
                        viewModel.changeStatus(item, to: .DONE)
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    viewModel.deleteItem(item)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct StatusBadge: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}


#Preview {
    BookItemCard(item: BookItem(sourceUrl: URL(string: "https://google.com")!, title: "title", year: 1999))
}
