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
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(booksViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(appState)
            
            if appState.showDescription, let description = appState.selectedDescription {
                TextOverlay(description: description) {
                    appState.hideDescriptionOverlay()
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
        .modelContainer(for: SchemaV101.BookItem.self)
    }
}

// TODO: Book functionality
// book unique not by title, but title+year (?) // sourceUrl
// list sorting by title
// soft delete? on delete - remove images, but keep evveything else + add menu 'removed items' to restore
// share link
// plus button to overlays title 'books' to reduce space waste
// UI/UX: when change from planned to done - in Card metadata and description 'dance'
// TODO: remove cover url

// FIXME: i18n in IOS 18 vs 26 ?
//  what is proper way for naming?
//  how can I use generated resources like R in android?
//  no fallback for some reasons :shrug:
// FIXME: overall system performance issue
// FIXME: services throw exception, not catch them
// On search when cancelled - dont show error message
// Application image
// Splash screen
// we my library contains a lot of items - images should be obtained consequently
// profile requests , especially on OLService


// -----
// TODO: Settings
// - for openLibrary add status badge and note that sometimes it fails
// - if openlibrary is down - need workaround way to add book draft

// -----
// TODO: Movie section afterall
// - load data from imdb / goodreads
// - for series movies that are not yet released full - add button 'sync'
// - for series movies add amount of seasons

// -----
// TODO: Reminders:
// can I send push noification from ohone cron? witout 3rd party server
// - licenses, subscriptions

// -------
// TODO: other
// About - donate button - extract wallet value
// About - add link to github ?!
