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
                    Label(".titleMovies", systemImage: "film")
                }
                .tag(0)
            
            BooksView()
                .tabItem {
                    Label(".titleBooks", systemImage: "book")
                }
                .tag(1)

            RemindersView()
                .tabItem {
                    Label(".titleReminders", systemImage: "repeat")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label(".titleSettings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}
