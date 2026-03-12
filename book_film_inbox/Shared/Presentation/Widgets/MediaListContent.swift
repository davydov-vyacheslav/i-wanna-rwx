//
//  MediaListContent.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 06.02.2026.
//

import SwiftUI
import SwiftData

struct MediaListContent<Item: CommonMediaItem, PersistenceService: MediaPersistenceService>: View
where PersistenceService.Item == Item {
    
    let persistenceService: PersistenceService
    let onDelete: (Item) -> Void
    let placeholderIcon: String // book.fill | film.fill
    let itemDetailedTypeIconFunc: (Item) -> String // tv | film | book
    let isDraft: (_ item: Item) -> Bool
    let extraMetaView: (_ item: Item) -> AnyView

    @Query private var items: [Item]
    
    init(customPredicate: Predicate<Item>?, persistenceService: PersistenceService, sortDescriptors: [SortDescriptor<Item>], placeholderIcon: String,
         itemDetailedTypeIconFunc: @escaping (Item) -> String,
         isDraft: @escaping (Item) -> Bool,
         onDelete: @escaping (Item) -> Void,
         @ViewBuilder extraMetaView: @escaping (Item) -> some View) {
        self.persistenceService = persistenceService
        self.onDelete = onDelete
        self.placeholderIcon = placeholderIcon
        self.itemDetailedTypeIconFunc = itemDetailedTypeIconFunc
        self.isDraft = isDraft
        self.extraMetaView = { AnyView(extraMetaView($0)) }
        
        _items = Query(
            filter: customPredicate ?? #Predicate { _ in true },
            sort: sortDescriptors
        )
    }
    
    var body: some View {
        if items.isEmpty {
            Spacer()
            Text(".label.common.list_empty")
                .foregroundColor(.secondary)
            Spacer()
        } else {
            List {
                ForEach(items) { item in
                    MediaItemCard<Item, PersistenceService>(
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
        }
    }
}
