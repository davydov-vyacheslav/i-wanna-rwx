//
//  SettingsView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @StateObject private var settingsSearchStore = SettingsSourceStore.shared
    private let walletAddress = "0xB06095188DdCB0e1Acd8fDd16FaC96Fbac3d6882"
    private let projectLink = "https://github.com/davydov-vyacheslav/i-wanna-rwx"
    
    var body: some View {
        NavigationStack {
            List {
                
                // Movie Sources Section
                Section(".label.settings.source.movies") {
                    ForEach(settingsSearchStore.availableVideoSources) { source in
                        SettingsSourceRow(searchService: source.instance, viewModel: viewModel)
                    }
                }
                
                // Book Sources Section
                Section(".label.settings.source.books") {
                    ForEach(settingsSearchStore.availableBookSources) { source in
                        SettingsSourceRow(searchService: source.instance, viewModel: viewModel)
                    }
                }
                
                // About Section
                Section(".label.settings.about") {
                    HStack {
                        Text(".label.settings.version")
                        Spacer()
                        Text(".label.settings.version_value")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/davydov-vyacheslav/i-wanna-rwx")!) {
                            HStack {
                                Label(".label.settings.github", systemImage: "link")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                }
                // Support Us Section
                Section(".label.settings.support_us") {

                    Text(".label.settings.support_us_value")
                        .foregroundColor(.secondary)

                    CopyableText(text: walletAddress)
                    
                    Button(action: {
                        let urlString = "ethereum:\(walletAddress)"
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(".label.settings.support_us_open_wallet")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                    }
                }

            }
            .navigationTitle(".title.settings")
        }
    }
}



#Preview {
    SettingsView()
}
