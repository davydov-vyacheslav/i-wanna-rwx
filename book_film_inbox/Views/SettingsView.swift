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
    
    var body: some View {
        NavigationStack {
            List {
                
                // Movie Sources Section
                Section(".pageSettings_source_movie") {
                    ForEach(settingsSearchStore.availableVideoSources) { source in
                        SettingsSourceRow(searchService: source.instance, viewModel: viewModel)
                    }
                }
                
                // Book Sources Section
                Section(".pageSettings_sourcebooks") {
                    ForEach(settingsSearchStore.availableBookSources) { source in
                        SettingsSourceRow(searchService: source.instance, viewModel: viewModel)
                    }
                }
                
                // About Section
                Section(".pageSettings_about") {
                    HStack {
                        Text(".pageSettings_version")
                        Spacer()
                        Text(".version")
                            .foregroundColor(.secondary)
                    }
                }
                // Support Us Section
                Section(".pageSettings_support") {

                    Text(".pageSettings_support_text")
                        .foregroundColor(.secondary)

                    CopyableText(text: walletAddress)
                    
                    Button(action: {
                        let urlString = "ethereum:\(walletAddress)"
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(".pageSettings_support_openWallet")
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                    }
                }

            }
            .navigationTitle(".titleSettings")
        }
    }
}



#Preview {
    SettingsView()
}
