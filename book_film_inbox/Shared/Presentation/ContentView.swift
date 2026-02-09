//
//  ContentView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(NavigationManager.self) private var navigation
    
    var body: some View {
        @Bindable var navigation = navigation
        
        TabView(selection: $navigation.selectedTab) {
            BooksTab()
                .tabItem {
                    Label(Tab.books.title, systemImage: Tab.books.icon)
                }
                .tag(Tab.books)

            MoviesTab()
                .tabItem {
                    Label(Tab.movies.title, systemImage: Tab.movies.icon)
                }
                .tag(Tab.movies)
            
            RemindersTab()
                .tabItem {
                    Label(Tab.reminders.title, systemImage: Tab.reminders.icon)
                }
                .tag(Tab.reminders)

            SettingsTab()
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(.blue)
    }
}

// MARK: - Tab Views with Navigation

struct BooksTab: View {
    @Environment(NavigationManager.self) private var navigation
    
    var body: some View {
        @Bindable var navigation = navigation
        
        NavigationStack(path: $navigation.booksPath) {
            BooksView()
                .navigationDestination(for: BookRoute.self) { route in }
        }
    }
}

struct MoviesTab: View {
    @Environment(NavigationManager.self) private var navigation
    
    var body: some View {
        @Bindable var navigation = navigation
        
        NavigationStack(path: $navigation.moviesPath) {
            MoviesView()
                .navigationDestination(for: MovieRoute.self) { route in }
        }
    }
}

struct RemindersTab: View {
    @Environment(NavigationManager.self) private var navigation
    @Environment(ReminderPersistenceService.self) private var persistenceService
    
    var body: some View {
        @Bindable var navigation = navigation
        
        NavigationStack(path: $navigation.remindersPath) {
            RemindersView()
                .navigationDestination(for: ReminderRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ReminderRoute) -> some View {
        switch route {
        case .details(let id):
            if let item = persistenceService.findById(id) {
                ReadonlyReminderSheet(
                    persistenceService: persistenceService,
                    item: item
                )
            } else {
                Text(".error.reminder.not_found")
                    .foregroundColor(.secondary)
            }
            
        case .prolongateAndView(let id):
            if let item = persistenceService.findById(id) {
                ProlongateReminderView(
                    persistenceService: persistenceService,
                    item: item
                )
            } else {
                Text(".error.reminder.not_found")
                    .foregroundColor(.secondary)
            }
            
        case .edit(let id):
            if let item = persistenceService.findById(id) {
                AddEditReminderSheet(
                    persistenceService: persistenceService,
                    item: item
                )
            } else {
                Text(".error.reminder.not_found")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct SettingsTab: View {
    @Environment(NavigationManager.self) private var navigation
    
    var body: some View {
        @Bindable var navigation = navigation
        
        NavigationStack(path: $navigation.settingsPath) {
            SettingsView()
                .navigationDestination(for: SettingsRoute.self) { route in }
        }
    }
}
