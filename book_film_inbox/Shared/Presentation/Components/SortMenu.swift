//
//  SortMenu.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 01.07.2026.
//

import SwiftUI

/// Compact navigation-bar control for choosing a list's sort order.
/// Renders as a menu whose embedded picker shows a checkmark next to the active option.
struct SortMenu: View {
    @Binding var selection: MediaSortOption

    var body: some View {
        Menu {
            Picker(".label.common.sort", selection: $selection) {
                ForEach(MediaSortOption.allCases) { option in
                    Label(option.label, systemImage: option.icon).tag(option)
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .accessibilityHidden(true)
        }
        .accessibilityLabel(Text(".label.common.sort"))
    }
}
