//
//  ReminderFilterSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 10.03.2026.
//

import SwiftUI

struct ReminderFilterSheet: View {
    @Binding var filterState: ReminderFilterState

    var body: some View {
        CommonFilterSheet(
            filterState: $filterState,
            filterStateInstantiate: { ReminderFilterState() },
            characteristicSectionContent: { _ in
                ReminderCharacteristicsSection(filterState: $filterState)
            }
        )
    }
}

struct ReminderCharacteristicsSection: View {
    @Binding var filterState: ReminderFilterState

    var body: some View {
        Toggle(isOn: $filterState.isExpiringSoon) {
            Label(".label.subscription.filter.expiring_soon", systemImage: "hourglass.bottomhalf.fill")
        }
        .tint(.red)
    }
}
