//
//  FilterButton.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI
import SwiftData

struct FilterButton<Item: PersistentModel>: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    let postSearchFilter: (Item) -> Bool
    
    @Query private var items: [Item]
    
    init(
        iconName: String,
        predicate: Predicate<Item>?,
        postSearchFilter: @escaping (Item) -> Bool = { _ in true},
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.isSelected = isSelected
        self.action = action
        self.postSearchFilter = postSearchFilter
        _items = Query(filter: predicate ?? #Predicate { _ in true })
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.callout)
                    .frame(width: 16, height: 16)
                Text(verbatim: "\(count)")
                    .font(.caption)
            }
            .frame(minWidth: 60)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(backgroundColor)
            .foregroundColor(isSelected ? .white : .secondary)
            .cornerRadius(8)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        }
        return Color(uiColor: .secondarySystemBackground)
    }
    
    private var count: Int {
        items.filter(postSearchFilter).count
    }

}
