//
//  SettingsView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

// TODO: for openLibrary add status badge and note that sometimes it fails
// FIXME: if openlibrary is down - need workaround way to add book draft

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationStack {
            List {
                
                // Movie Sources Section
//                Section("settings.source.movie") {
//                    HStack {
//                        Text("IMDB")
//                    }
//                }
                
                // Book Sources Section
                Section("settings.source.books") {
                    HStack {
                        Text("OpenLibrary")
                    }
                }
                
                // About Section
                Section("settings.about") {
                    HStack {
                        Text("settings.version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("title.settings")
        }
    }
}
