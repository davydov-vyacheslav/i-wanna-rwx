//
//  FilterStore.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 01.07.2026.
//

import Foundation

/// Persists per-list filter state to `UserDefaults`, mirroring the tab-persistence
/// pattern in `NavigationManager`. Device-local (not CloudKit-synced), like the
/// selected tab.
enum FilterStore {

    enum Key {
        static let books = "filter.books"
        static let movies = "filter.movies"
        static let reminders = "filter.reminders"
        static let booksSort = "sort.books"
        static let moviesSort = "sort.movies"
    }

    static func load<F: Codable>(_ key: String, default def: F) -> F {
        guard let data = UserDefaults.standard.data(forKey: key),
              let value = try? JSONDecoder().decode(F.self, from: data) else {
            return def
        }
        return value
    }

    static func save<F: Codable>(_ value: F, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
        Log.debug("💾 Saved filter", context: ["key": key])
    }
}
