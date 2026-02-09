//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 04.02.2026.
//

import SwiftUI
import Kingfisher

struct MediaItemCard<Item: CommonMediaItem, PersistenceService: MediaPersistenceService>: View
where PersistenceService.Item == Item {
    
    @Environment(\.modelContext) private var modelContext
    let persistenceService: PersistenceService

    @State private var showDescription = false
    let item: Item
    let placeholderIcon: String // book.fill | film.fill
    let itemDetailedTypeIcon: String // tv | film | book
    let isDraft: (_ item: Item) -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top, spacing: 8) {
                // Poster
                KFImage(item.coverImageUrl)
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
                    .frame(width: 80, height: 116)
                    .clipped()
                    .onTapGesture {
                        guard let source = SettingsSourceStore.shared.getSource(item.sourceName, for: item),
                              let url = try? source.instance.getSourceUrl(item: item)
                            else { return }
                        UIApplication.shared.open(url)
                    }
                
                // Content
                VStack(alignment: .leading, spacing: 1) {
                    let itemStatus = MediaItemHelper.getStatus(from: item)
                    // Title
                    HStack {
                        
                        Image(systemName: itemDetailedTypeIcon)
                            .foregroundColor(isDraft(item) ? .gray : .orange)
                        
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
                        Text(MediaItemHelper.getRatingText(from: item))
                            .font(.caption)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button {
                                persistenceService.toggleFavorite(item)
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(item.isFavorite ? .red : .secondary)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 16)
                            
                            if itemStatus == .done {
                                Button {
                                    persistenceService.changeStatus(item, to: .planned)
                                } label: {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .frame(width: 16)
                            }
                            
                            if itemStatus == .planned {
                                Button {
                                    persistenceService.changeStatus(item, to: .done)
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

                    Text(item.mainAuthor ?? String(localized: ".label.common_media.no_author") )
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                    
                    // Badges
                    HStack(spacing: 6) {
                        if itemStatus == .planned {
                            StatusBadge(icon: "clock", text: ".type.media_status.planned", color: .blue)
                        } else if itemStatus == .done {
                            StatusBadge(icon: "checkmark", text: ".type.media_status.seen", color: .green)
                        }
                        
                        Spacer()
                        
                        StatusBadge(icon: "magnifyingglass", text: .init(item.sourceName), color: .gray)
                    }
                }
                .onTapGesture {
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
