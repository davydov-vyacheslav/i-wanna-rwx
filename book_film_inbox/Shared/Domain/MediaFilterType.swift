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
    var isDraft: Bool = false
    var isFavourite: Bool = false
    var isSeen: Bool = false
    var isNotSeen: Bool = false

    var isActive: Bool {
        itemType != .all || isDraft || isFavourite || isSeen || isNotSeen
    }

    var activeCount: Int {
        var count = 0
        if itemType != .all { count += 1 }
        if isDraft { count += 1 }
        if isFavourite { count += 1 }
        if isSeen { count += 1 }
        if isNotSeen { count += 1 }
        return count
    }
}
