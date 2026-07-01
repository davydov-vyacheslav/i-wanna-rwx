//
//  ListCountPreference.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 01.07.2026.
//

import SwiftUI

/// Item counts reported by a list's content view: the full library size (`total`)
/// and how many are currently visible after filtering/searching (`shown`).
struct ListCounts: Equatable {
    var total: Int = 0
    var shown: Int = 0

    /// True when the visible set is a strict subset of the library (a filter or search is narrowing it).
    var isNarrowed: Bool { shown != total }
}

/// Lets a list content view (which owns the `@Query`) surface its counts up to the
/// enclosing screen's toolbar without threading bindings through every call site.
struct ListCountsKey: PreferenceKey {
    static var defaultValue = ListCounts()
    static func reduce(value: inout ListCounts, nextValue: () -> ListCounts) {
        value = nextValue()
    }
}

extension View {
    /// Report the current list counts to an ancestor observing `ListCountsKey`.
    func reportListCounts(total: Int, shown: Int) -> some View {
        preference(key: ListCountsKey.self, value: ListCounts(total: total, shown: shown))
    }
}

/// Compact secondary label for a list's item count, shown in the navigation bar.
/// Renders nothing for an empty library.
struct ListCountLabel: View {
    let counts: ListCounts

    var body: some View {
        if counts.total > 0 {
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .padding(.leading, 8)
                .accessibilityLabel(text)
        }
    }

    private var text: LocalizedStringKey {
        counts.isNarrowed
            ? ".label.common.list.count_filtered \(counts.shown) \(counts.total)"
            : ".label.common.list.count \(counts.total)"
    }
}
