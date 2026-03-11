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
        Toggle(isOn: $filterState.isFavourite) {
            Label(".label.common.filter.favorite", systemImage: "heart.fill")
        }
        .tint(.red)

        Toggle(isOn: $filterState.isSeen) {
            Label(".label.common.filter.seen", systemImage: "checkmark.circle.fill")
        }
        .tint(.green)
        .onChange(of: filterState.isSeen) { _, newValue in
            if newValue { filterState.isNotSeen = false }
        }

        Toggle(isOn: $filterState.isNotSeen) {
            Label(".label.common.filter.planned", systemImage: "circle")
        }
        .tint(.blue)
        .onChange(of: filterState.isNotSeen) { _, newValue in
            if newValue { filterState.isSeen = false }
        }

        Toggle(isOn: $filterState.isDraft) {
            Label(".label.common.filter.draft", systemImage: "pencil.circle.fill")
        }
        .tint(.orange)
    }
}
