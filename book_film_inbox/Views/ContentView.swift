//
//  ContentView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BooksView()
                .tabItem {
                    Label(".title.book.list", systemImage: "book")
                }
                .tag(0)

            MoviesView()
                .tabItem {
                    Label(".title.movie.list", systemImage: "film")
                }
                .tag(1)
            
            RemindersView()
                .tabItem {
                    Label(".title.reminder.list", systemImage: "repeat")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(".title.settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}
