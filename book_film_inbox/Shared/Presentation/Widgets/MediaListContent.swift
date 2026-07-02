//
//  MediaListContent.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 06.02.2026.
//

import SwiftUI
import SwiftData

struct MediaListContent<Item: CommonMediaItem, ExternalItem: ExternalMediaItem, PersistenceService: MediaPersistenceService>: View
where PersistenceService.Item == Item,
      ExternalItem.MediaItem == Item {
    
    let persistenceService: PersistenceService
    let onDelete: (Item) -> Void
    let onRefresh: (() async -> Void)?
    let placeholderIcon: String // draft_movie / draft_book
    let itemDetailedTypeIconFunc: (Item) -> String // tv | film | book
    let isDraft: (_ item: Item) -> Bool
    let extraMetaView: (_ item: Item) -> AnyView
    let searchText: String
    /// Optional in-memory narrowing applied on top of the SwiftData predicate. Use for
    /// conditions that are awkward or too expensive to express in a `#Predicate`.
    let inMemoryFilter: ((Item) -> Bool)?

    @Query private var items: [Item]
    /// Unfiltered query used only to report the total library size for the header count.
    @Query private var allItems: [Item]

    init(customPredicate: Predicate<Item>?, persistenceService: PersistenceService, sortDescriptors: [SortDescriptor<Item>], placeholderIcon: String,
         itemDetailedTypeIconFunc: @escaping (Item) -> String,
         isDraft: @escaping (Item) -> Bool,
         onDelete: @escaping (Item) -> Void,
         onRefresh: (() async -> Void)? = nil,
         searchText: String = "",
         inMemoryFilter: ((Item) -> Bool)? = nil,
         @ViewBuilder extraMetaView: @escaping (Item) -> some View) {
        self.persistenceService = persistenceService
        self.onDelete = onDelete
        self.onRefresh = onRefresh
        self.placeholderIcon = placeholderIcon
        self.itemDetailedTypeIconFunc = itemDetailedTypeIconFunc
        self.isDraft = isDraft
        self.searchText = searchText
        self.inMemoryFilter = inMemoryFilter
        self.extraMetaView = { AnyView(extraMetaView($0)) }

        _items = Query(
            filter: customPredicate ?? #Predicate { _ in true },
            sort: sortDescriptors
        )
    }

    private var displayedItems: [Item] {
        var result = items
        if let inMemoryFilter {
            result = result.filter(inMemoryFilter)
        }
        guard !searchText.isEmpty else { return result }
        return result.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        content
            .reportListCounts(total: allItems.count, shown: displayedItems.count)
    }

    @ViewBuilder
    private var content: some View {
        if displayedItems.isEmpty {
            Spacer()
            Text(".label.common.list_empty")
                .foregroundColor(.secondary)
            Spacer()
        } else {
            List {
                ForEach(displayedItems) { item in
                    MediaItemCard<Item, ExternalItem, PersistenceService>(
                        persistenceService: persistenceService,
                        item: item,
                        placeholderIcon: placeholderIcon,
                        itemDetailedTypeIcon: itemDetailedTypeIconFunc(item),
                        isDraft: isDraft,
                        extraMetaView: extraMetaView
                    )
                    .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onDelete(item)
                        } label: {
                            Label(".button.delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(.plain)
            .padding(.horizontal)
            .refreshable {
                await onRefresh?()
            }
        }
    }
}
