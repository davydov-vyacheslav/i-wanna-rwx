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
    
    let filter: FilterType
    let persistenceService: PersistenceService
    let onDelete: (Item) -> Void
    let placeholderIcon: String // book.fill | film.fill
    let itemDetailedTypeIconFunc: (Item) -> String // tv | film | book
    let isDraft: (_ item: Item) -> Bool

    @Query private var items: [Item]
    
    init(filter: FilterType, persistenceService: PersistenceService, sortDescriptors: [SortDescriptor<Item>], placeholderIcon: String,
         itemDetailedTypeIconFunc: @escaping (Item) -> String, isDraft: @escaping (Item) -> Bool, onDelete: @escaping (Item) -> Void) {
        self.filter = filter
        self.persistenceService = persistenceService
        self.onDelete = onDelete
        self.placeholderIcon = placeholderIcon
        self.itemDetailedTypeIconFunc = itemDetailedTypeIconFunc
        self.isDraft = isDraft
        
        let predicate: Predicate<Item>? = persistenceService.makeFilterPredicate(for: filter)
        
        _items = Query(
            filter: predicate ?? #Predicate { _ in true },
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
                        isDraft: isDraft
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
