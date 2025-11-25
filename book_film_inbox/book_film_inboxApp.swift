//
//  book_film_inboxApp.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI
import SwiftData

@main
struct InboxApp: App {
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(booksViewModel)
                .environmentObject(settingsViewModel)
        }
        .modelContainer(for: BookItem.self)
    }
}

// FIXME: why `Release It!` isn't found?
// FIXME: extend search results count

// TODO: i18n

// TODO: real load data from imdb / goodreads

// CLeanup:
// - TODO: remove MediaItem.poster

// Comments:
// - languge switch is not supported: only device locale to be used

// f-ty:
// - for series movies that are not yet released full - add button 'sync'
// - for series movies add amount of seasons

