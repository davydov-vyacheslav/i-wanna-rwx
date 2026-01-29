//
//  FilterStatus.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation

enum FilterType: String, CaseIterable {
    case ALL
    case FAVOURITES
    case PLANNED
    
    var iconName: String {
        switch self {
        case .ALL:
            return "list.bullet"
        case .FAVOURITES:
            return "heart.fill"
        case .PLANNED:
            return "clock"
        }
    }
}
