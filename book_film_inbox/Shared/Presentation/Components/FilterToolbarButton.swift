//
//  FilterToolbarButton.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 11.03.2026.
//

import SwiftUI

struct FilterToolbarButton<FS: CommonFilterState>: View {
    @Binding var filterState: FS
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(filterState.isActive ? .fill : .none)

                if filterState.activeCount > 0 {
                    Text(filterState.activeCount, format: .number)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color.accentColor, in: Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }
}
