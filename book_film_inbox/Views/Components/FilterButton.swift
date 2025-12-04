//
//  FilterButton.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct FilterButton: View {
    let filterType: FilterType
    let count: Int
    let isSelected: Bool
    let isFavorite: Bool
    let action: () -> Void
    
    init(
        filterType: FilterType,
        count: Int,
        isSelected: Bool,
        isFavorite: Bool = false,
        action: @escaping () -> Void
    ) {
        self.filterType = filterType
        self.count = count
        self.isSelected = isSelected
        self.isFavorite = isFavorite
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 16))
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
    
    private var iconName: String {
        switch filterType {
        case .ALL:
            return "list.bullet"
        case .FAVOURITES:
            return "heart.fill"
        case .PLANNED:
            return "clock"
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return isFavorite ? .red : .blue
        }
        return Color(uiColor: .secondarySystemBackground)
    }

}


#Preview {
    FilterButton(filterType: .ALL, count: 3, isSelected: false, isFavorite: true) {
        
    }
}
