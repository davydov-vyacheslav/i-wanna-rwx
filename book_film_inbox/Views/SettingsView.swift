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
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                // Support Us Section
                Section(".pageSettings_support") {

                    Text(".pageSettings_support_text")
                        .foregroundColor(.secondary)

                    // Address + Copy
                    HStack {
                        Text(walletAddress)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)

                        Button(action: {
                            UIPasteboard.general.string = walletAddress
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

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
