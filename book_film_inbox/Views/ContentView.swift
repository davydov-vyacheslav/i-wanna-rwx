//
//  ContentView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MoviesView()
                .tabItem {
                    Label(".title.movie.list", systemImage: "film")
                }
                .tag(0)
            
            BooksView()
                .tabItem {
                    Label(".title.book.list", systemImage: "book")
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
