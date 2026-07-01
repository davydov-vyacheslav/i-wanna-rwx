//
//  MediaSortOption.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 01.07.2026.
//

import SwiftUI

/// User-selectable sort order for media lists (books & movies).
/// Each list maps this to concrete `SortDescriptor`s for its own item type.
enum MediaSortOption: String, CaseIterable, Codable, Identifiable {
    case titleAsc
    case updatedDesc

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .titleAsc: return ".label.common.sort.title"
        case .updatedDesc: return ".label.common.sort.updated"
        }
    }

    var icon: String {
        switch self {
        case .titleAsc: return "textformat"
        case .updatedDesc: return "clock.arrow.circlepath"
        }
    }
}
