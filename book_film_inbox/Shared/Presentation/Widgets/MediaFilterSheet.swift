//
//  MediaFilterSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 10.03.2026.
//

import SwiftUI

struct MediaFilterSheet<TF: FilterTypeOption>: View
where TF.AllCases: RandomAccessCollection {
    @Binding var filterState: MediaFilterState<TF>

    var body: some View {
        CommonFilterSheet(
            filterState: $filterState,
            filterStateInstantiate: { MediaFilterState<TF>() },
            characteristicSectionContent: { _ in
                MediaCharacteristicsSection(filterState: $filterState)
            }
        )
    }
}

struct MediaCharacteristicsSection<TF: FilterTypeOption>: View {
    @Binding var filterState: MediaFilterState<TF>

    var body: some View {
        
        TriStateCheckbox(
            icon: "heart.fill",
            label: ".label.common.filter.favorite",
            iconTint: .red,
            state: $filterState.favouriteState
        )

        TriStateCheckbox(
            icon: "eye",
            label: ".label.common.filter.seen",
            iconTint: .green,
            state: $filterState.seenState
        )
        
        TriStateCheckbox(
            icon: "pencil.circle.fill",
            label: ".label.common.filter.draft",
            iconTint: .gray,
            state: $filterState.draftState
        )
        
    }
}
