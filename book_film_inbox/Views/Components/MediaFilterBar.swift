//
//  MediaFilterBar.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 06.02.2026.
//

import SwiftUI
import SwiftData

struct MediaFilterBar<PersistenceService: MediaPersistenceService, Item: CommonMediaItem>: View
where PersistenceService.Item == Item
{
    let persistenceService: PersistenceService
    @Binding var selectedFilter: FilterType
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FilterType.allCases, id: \.self) { filter in
                FilterButtonWithCount(
                    persistenceService: persistenceService,
                    filter: filter,
                    isSelected: selectedFilter == filter
                ) {
                    selectedFilter = filter
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Filter Button With Count (Private)
private struct FilterButtonWithCount<PersistenceService: MediaPersistenceService, Item: CommonMediaItem>: View
where PersistenceService.Item == Item
{
    let filter: FilterType
    let isSelected: Bool
    let onTap: () -> Void
    
    @Query private var items: [Item]
    
    init(persistenceService: PersistenceService, filter: FilterType, isSelected: Bool, onTap: @escaping () -> Void) {
        self.filter = filter
        self.isSelected = isSelected
        self.onTap = onTap
        
        let predicate: Predicate<Item>? = persistenceService.makeFilterPredicate(for: filter)
        _items = Query(filter: predicate ?? #Predicate { _ in true })
    }
    
    var body: some View {
        FilterButton(
            iconName: filter.iconName,
            count: items.count,
            isSelected: isSelected,
            isFavorite: filter == .favorite,
            action: onTap
        )
    }
}
