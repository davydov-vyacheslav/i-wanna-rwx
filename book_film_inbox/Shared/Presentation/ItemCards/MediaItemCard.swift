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
    
    // MARK: - Accessibility helpers

    private var cardAccessibilityLabel: String {
        let itemStatus = MediaItemHelper.getStatus(from: item)
        var parts: [String] = []
        parts.append(item.title)
        if let year = item.year { parts.append(String(year)) }
        if let author = item.mainAuthor { parts.append(author) }
        if item.isFavorite { parts.append(String(localized: ".label.common.filter.favorite")) }
        switch itemStatus {
        case .planned: parts.append(String(localized: ".type.media_status.planned"))
        case .done:    parts.append(String(localized: ".type.media_status.seen"))
        }
        return parts.joined(separator: ", ")
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
                    .accessibilityLabel(Text(".accessibility.card.open_source \(item.sourceName)"))
                    .accessibilityHint(Text(".accessibility.card.open_source_hint"))
                    .accessibilityAddTraits(.isButton)

                // Right side
                VStack(alignment: .leading, spacing: 4) {

                    // Content + Buttons
                    HStack(alignment: .top, spacing: 8) {

                        // Content — нажатие открывает описание
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .top) {
                                Image(systemName: itemDetailedTypeIcon)
                                    .foregroundColor(isDraft(item) ? .gray : .orange)
                                    .accessibilityHidden(true)
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
                                    .accessibilityHidden(true)
                                Text(MediaItemHelper.getRatingText(from: item))
                                    .font(.caption)

                            }

                            Text(item.mainAuthor ?? String(localized: ".label.common_media.no_author"))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            extraMetaView(item)
                                .font(.caption)
                                .foregroundColor(.secondary)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if item.itemDescription != nil {
                                showDescription = true
                            }
                        }
                        .accessibilityLabel(Text(cardAccessibilityLabel))
                        .accessibilityHint(item.itemDescription != nil
                            ? Text(".accessibility.card.description_hint")
                            : Text(".label.common.empty_value")
                        )
                        .accessibilityAddTraits(item.itemDescription != nil ? .isButton : [])
                        .sheet(isPresented: $showDescription) {
                            ScrollView {
                                Text(item.itemDescription ?? "")
                                    .padding(24)
                            }
                            .presentationDetents([.medium, .large])
                            .onTapGesture {
                                showDescription = false
                            }
                            .accessibilityHint(Text(".accessibility.card.dismiss_description_hint"))
                        }

                        // Action buttons
                        VStack(spacing: 8) {
                            Button {
                                persistenceService.toggleFavorite(item)
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(item.isFavorite ? .red : .secondary)
                                    .frame(width: 32, height: 32)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .accessibilityHidden(true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(item.isFavorite
                                ? Text(".accessibility.card.remove_favorite")
                                : Text(".accessibility.card.add_favorite")
                            )

                            Button {
                                persistenceService.changeStatus(item, to: itemStatus == .done ? .planned : .done)
                            } label: {
                                Image(systemName: "eye")
                                    .foregroundColor(itemStatus == .done ? .green : .secondary)
                                    .frame(width: 32, height: 32)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .accessibilityHidden(true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(itemStatus == .done
                                ? Text(".accessibility.card.mark_planned")
                                : Text(".accessibility.card.mark_seen")
                            )
                        }
                    }

                    Spacer(minLength: 0)

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
                    .accessibilityHidden(true)
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
