//
//  SettingsView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    private let walletAddress = "0x0000000000000000000000000000000006000000"
    
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
                Section(".pageSettings_sourcebooks") {
                    HStack {
                        Text("OpenLibrary")
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
                        Text("pageSettings_support_openWallet")
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
