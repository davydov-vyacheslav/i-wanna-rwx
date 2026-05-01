//
//  FilterStatus.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation

struct MediaFilterState<TF: FilterTypeOption>: CommonFilterState {
    typealias FilterType = TF
    
    var itemType: TF = .all
    var draftState: TriState = .all
    var favouriteState: TriState = .all
    var seenState: TriState = .all

    var isActive: Bool {
        itemType != .all || draftState != .all || favouriteState != .all || seenState != .all
    }

    var activeCount: Int {
        var count = 0
        if itemType != .all { count += 1 }
        if draftState != .all { count += 1 }
        if favouriteState != .all { count += 1 }
        if seenState != .all { count += 1 }
        return count
    }
}
