//
//  MediaItemCard.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 04.02.2026.
//

import SwiftUI
import Kingfisher

struct MediaItemCard<Item: CommonMediaItem, ExternalItem: ExternalMediaItem, PersistenceService: MediaPersistenceService>: View
where PersistenceService.Item == Item,
      ExternalItem.MediaItem == Item {

    @Environment(\.modelContext) private var modelContext
    let persistenceService: PersistenceService

    @State private var showDescription = false
    let item: Item
    let placeholderIcon: String
    let itemDetailedTypeIcon: String
    let isDraft: (_ item: Item) -> Bool
    let extraMetaView: (_ item: Item) -> AnyView

    init(
        persistenceService: PersistenceService,
        item: Item,
        placeholderIcon: String,
        itemDetailedTypeIcon: String,
        isDraft: @escaping (Item) -> Bool,
        extraMetaView: @escaping (_ item: Item) -> AnyView
    ) {
        self.persistenceService = persistenceService
        self.item = item
        self.placeholderIcon = placeholderIcon
        self.itemDetailedTypeIcon = itemDetailedTypeIcon
        self.isDraft = isDraft
        self.extraMetaView = extraMetaView
    }
    
    var body: some View {
        let itemStatus = MediaItemHelper.getStatus(from: item)

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
                    .frame(width: 80, height: 108)
                    .cornerRadius(8)
                    .clipped()
                    .onTapGesture {
                        guard let source = SettingsSourceStore.shared.getSource(item.sourceName, for: item, as: ExternalItem.self),
                              let url = try? source.instance.getSourceUrl(item: item)
                        else { return }
                        UIApplication.shared.open(url)
                    }

                // Right side
                VStack(alignment: .leading, spacing: 4) {

                    // Content + Buttons
                    HStack(alignment: .top, spacing: 8) {

                        // Content
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .top) {
                                Image(systemName: itemDetailedTypeIcon)
                                    .foregroundColor(isDraft(item) ? .gray : .orange)
                                Text(item.title)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            HStack(spacing: 8) {
                                Text(item.year.map(String.init) ?? "—")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                Text(MediaItemHelper.getRatingText(from: item))
                                    .font(.caption)
                                
                                extraMetaView(item)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text(item.mainAuthor ?? String(localized: ".label.common_media.no_author"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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

                        // Buttons
                        VStack(spacing: 8) {
                            Button {
                                persistenceService.toggleFavorite(item)
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(item.isFavorite ? .red : .secondary)
                                    .frame(width: 32, height: 32)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)

                            Button {
                                persistenceService.changeStatus(item, to: itemStatus == .done ? .planned : .done)
                            } label: {
                                Image(systemName: "eye")
                                    .foregroundColor(itemStatus == .done ? .green : .secondary)
                                    .frame(width: 32, height: 32)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer(minLength: 0)

                    // Badges — full right-side width
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
                .frame(minHeight: 108)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}
