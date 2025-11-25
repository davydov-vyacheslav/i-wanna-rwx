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
    case PENDING
    case IN_PROGRESS
    case COMPLETED
}
