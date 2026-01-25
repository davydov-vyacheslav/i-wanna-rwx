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
        .modelContainer(for: SchemaV102.BookItem.self)
    }
}

// TODO: remove cover url + from database model (migration) + collapse migration (something went wrong)
// TODO: [close to be done]
// На странице поиска в конце - добавить книгу- заглушку с названием из поисковой строки
// Добавить новый статус - draft
// !!! снова проблемы с удалением карточки
// /persistnece/book (service + model)

// FIXME: i18n in IOS 18 vs 26 ?
//  what is proper way for naming?
//  no fallback for some reasons :shrug: - on missing values want to have base translation, not keys
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

// -------
// TODO: Books. Hardcore
// Add another main search source
//   Add ability to change их (включить/выключить, вставить апикей)
// По этому полю к книге подключать источники : sourceUrl + sourceType
// В списке книг указать перечень иконок источников с возможностью линков на нужные ресурсы. Не больше 6?
