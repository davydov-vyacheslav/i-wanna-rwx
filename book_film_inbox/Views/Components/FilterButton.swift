//
//  FilterButton.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct FilterButton: View {
    let iconName: String
    let count: Int
    let isSelected: Bool
    let isFavorite: Bool
    let action: () -> Void
    
    init(
        iconName: String,
        count: Int,
        isSelected: Bool,
        isFavorite: Bool = false,
        action: @escaping () -> Void
    ) {
        self.iconName = iconName
        self.count = count
        self.isSelected = isSelected
        self.isFavorite = isFavorite
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.callout)
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
            return isFavorite ? .red : .blue
        }
        return Color(uiColor: .secondarySystemBackground)
    }

}


#Preview {
    FilterButton(iconName: FilterType.ALL.iconName, count: 3, isSelected: false, isFavorite: true) {
        
    }
}
