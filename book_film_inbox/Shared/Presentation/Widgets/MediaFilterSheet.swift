//
//  MediaFilterSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 10.03.2026.
//

import SwiftUI

struct MediaFilterSheet<TF: FilterTypeOption, Extra: View>: View
where TF.AllCases: RandomAccessCollection {
    @Binding var filterState: MediaFilterState<TF>
    @ViewBuilder let extraCharacteristics: (Binding<MediaFilterState<TF>>) -> Extra

    init(
        filterState: Binding<MediaFilterState<TF>>,
        @ViewBuilder extraCharacteristics: @escaping (Binding<MediaFilterState<TF>>) -> Extra
    ) {
        self._filterState = filterState
        self.extraCharacteristics = extraCharacteristics
    }

    var body: some View {
        CommonFilterSheet(
            filterState: $filterState,
            filterStateInstantiate: { MediaFilterState<TF>.appDefault },
            characteristicSectionContent: { _ in
                MediaCharacteristicsSection(filterState: $filterState)
                extraCharacteristics($filterState)
            }
        )
    }
}

extension MediaFilterSheet where Extra == EmptyView {
    /// Convenience for lists without any extra, type-specific filter rows (e.g. Books).
    init(filterState: Binding<MediaFilterState<TF>>) {
        self.init(filterState: filterState, extraCharacteristics: { _ in EmptyView() })
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
