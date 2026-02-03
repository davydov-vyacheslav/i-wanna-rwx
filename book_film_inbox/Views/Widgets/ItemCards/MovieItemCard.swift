//
//  MovieItemCard.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI
import Kingfisher

struct MovieItemCard: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    let item: MovieItem
    @State private var showDescription = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 8) {
                // Poster
                MediaCover(
                    imageUrl: item.coverImageUrl,
                    placeholderIcon: "film.fill",
                    sourceUrl: item.sourceUrl
                )

                // Content
                VStack(alignment: .leading, spacing: 1) {
                    // Title
                    HStack {
                        
                        Image(systemName: item.type == VideoType.tvSeries ? "tv" : "film")
                            .foregroundColor(DraftMovieService.shared.isDraft(item: item) ? .gray : .orange)
                        
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
                        Text(verbatim: item.ratingText)
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
                        Text(".label.common_media.no_author")
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
                    if item.itemDescription != nil {
                        showDescription = true
                    }
                }
                .sheet(isPresented: $showDescription) {
                    ScrollView {
                        Text(item.itemDescription ?? "")
                            .padding(24)
                    }
                    .presentationDetents([.medium, .large])
                    .onTapGesture {
                        showDescription = false
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
