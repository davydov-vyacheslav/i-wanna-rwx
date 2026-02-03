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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(booksViewModel)
                .environmentObject(moviesViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(remindersViewModel)
            
        }
    }
}
