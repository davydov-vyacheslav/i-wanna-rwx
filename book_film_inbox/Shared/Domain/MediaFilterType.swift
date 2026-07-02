//
//  FilterStatus.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation

struct MediaFilterState<TF: FilterTypeOption>: CommonFilterState, Codable {
    typealias FilterType = TF

    /// The app-wide default for media lists: hide items already marked as "seen".
    /// Single source of truth used both for the initial state and the filter sheet's Reset action.
    static var appDefault: MediaFilterState<TF> {
        var state = MediaFilterState<TF>()
        state.seenState = .exclude
        return state
    }

    var itemType: TF = .all
    var draftState: TriState = .all
    var favouriteState: TriState = .all
    var seenState: TriState = .all
    /// Movies-only: filter TV series by whether they have ended. Only surfaced when the
    /// "series" type is selected; reset to `.all` otherwise (see MoviesView).
    var seriesStatusState: TriState = .all

    var isActive: Bool {
        itemType != .all || draftState != .all || favouriteState != .all || seenState != .all || seriesStatusState != .all
    }

    var activeCount: Int {
        var count = 0
        if itemType != .all { count += 1 }
        if draftState != .all { count += 1 }
        if favouriteState != .all { count += 1 }
        if seenState != .all { count += 1 }
        if seriesStatusState != .all { count += 1 }
        return count
    }
}
