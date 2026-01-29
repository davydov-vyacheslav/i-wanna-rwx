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
    @StateObject private var moviesViewModel = MoviesViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var remindersViewModel = ReminderViewModel()
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(booksViewModel)
                .environmentObject(moviesViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(remindersViewModel)
                .environmentObject(appState)
            
            if appState.showDescription, let description = appState.selectedDescription {
                TextOverlay(description: description) {
                    appState.hideDescriptionOverlay()
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
    }
}

// TODO: Splash screen - some weirds going on, on first app start it doesn't appear :/ can't set it in project's properties
// TODO: sync database, keychain with iCloud

// -----
// TODO: Settings
// - for openLibrary add status badge and note that sometimes it fails
// - if openlibrary is down - need workaround way to add book draft

// -----
// TODO: Reminders:
// - system notification for expiration dates

// -------
// TODO: other
// About - add link to github ?! + create readme file with description

// FIXME: make common for book and video: ask AI ? Final stage
// FIXME: i18n - what is proper way for naming?

// первый запуск долгий (?)
// ?? при поиске книг какакя-то срань что не показываются результаты хотя они есть
// Бесячая надпись про сеть, когда отменяешь результаты поиска - need to ignore (?)
// swipes between sections

// move all ItemCard to subfolder
// merge SearchItemCard with correspond ItemCard
// use LazyVStack instead of VStack


