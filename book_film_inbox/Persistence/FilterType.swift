//
//  FilterStatus.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 24.11.2025.
//

import Foundation

enum FilterType: String, CaseIterable {
    case all
    case favorite
    case planned
    
    var iconName: String {
        switch self {
        case .all:
            return "list.bullet"
        case .favorite:
            return "heart.fill"
        case .planned:
            return "clock"
        }
    }
}
