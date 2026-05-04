//
//  SettingsSourceRow.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import SwiftUI

struct SettingsSourceRow: View {
    let searchService: any SearchService
    
    @State private var isExpanded: Bool = false
    @State private var isEditing: Bool = false
    @State private var tempToken: String = ""
    @State private var showToken: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @Environment(SettingsService.self) private var settingsService

    private var serviceName: String {
        type(of: searchService).serviceName
    }
    
    private var hasToken: Bool {
        type(of: searchService).requiresToken && settingsService.hasToken(for: serviceName)
    }
    
    var body: some View {
        if type(of: searchService).requiresToken {
            // Expandable list for sources with tokens
            DisclosureGroup(isExpanded: $isExpanded) {
                DetailView(
                    searchService: searchService,
                    isEditing: $isEditing,
                    tempToken: $tempToken,
                    showToken: $showToken,
                    showError: $showError,
                    errorMessage: $errorMessage,
                    hasToken: hasToken,
                    onSave: handleSave,
                    onDelete: handleDelete,
                    onCancel: handleCancel
                )
            } label: {
                HeaderView(searchService: searchService, hasToken: hasToken)
            }
        } else {
            // Simple, non-expandable list item
            HStack {
                HeaderView(searchService: searchService, hasToken: hasToken)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func handleSave() async {
        guard !tempToken.isEmpty else { return }
        
        let isValid = await searchService.isTokenValid(token: tempToken)
        
        if isValid {
            settingsService.saveToken(for: serviceName, token: tempToken, .apiToken)
            isEditing = false
            tempToken = ""
            isExpanded = false
        } else {
            errorMessage = String(localized: ".error.wrong_api_key")
            showError = true
        }
    }
    
    private func handleDelete() {
        settingsService.removeToken(for: serviceName)
    }
    
    private func handleCancel() {
        isEditing = false
        tempToken = ""
    }
    
    // MARK: - Header View
    private struct HeaderView: View {
        let searchService: any SearchService
        let hasToken: Bool
        
        var body: some View {
            HStack {
                
                Text(type(of: searchService).serviceName)
                    .font(.body)
                
                Spacer()
                
                if type(of: searchService).requiresToken {
                    if hasToken {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .imageScale(.medium)
                    } else {
                        Image(systemName: "exclamationmark.circle")
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                    }
                }
            }
        }
    }
    
    // MARK: - Detail View
    private struct DetailView: View {
        let searchService: any SearchService
        @Binding var isEditing: Bool
        @Binding var tempToken: String
        @Binding var showToken: Bool
        @Binding var showError: Bool
        @Binding var errorMessage: String
        let hasToken: Bool
        let onSave: () async -> Void
        let onDelete: () -> Void
        let onCancel: () -> Void
        
        @Environment(SettingsService.self) private var settingsService
        
        private var serviceName: String {
            type(of: searchService).serviceName
        }
        
        private var displayToken: String {
            guard let token = settingsService.getToken(for: serviceName) else { return "" }
            
            if showToken {
                return token
            } else {
                return String(repeating: "•", count: min(token.count, 20))
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                
                // Current Token Display
                if hasToken && !isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(".label.settings.source.current_token")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(displayToken)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Button {
                                showToken.toggle()
                            } label: {
                                Image(systemName: showToken ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                                    .accessibilityHidden(true)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(showToken
                                ? Text(".accessibility.settings.hide_token")
                                : Text(".accessibility.settings.show_token")
                            )
                        }
                    }
                }
                
                // Token Input (Editing Mode)
                if isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(hasToken ? ".label.settings.source.new_token" : ".label.settings.source.api_token")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        SecureField(".placeholder.settings.source.enter_token", text: $tempToken)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                
                // Help Link
                if let helpURL = type(of: searchService).helpURL, let url = URL(string: helpURL) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text(".label.settings.source.token_howto")
                                .font(.subheadline)
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.borderless)
                }
                
                // Action Buttons
                if isEditing {
                    HStack(spacing: 12) {
                        Button(".button.cancel") {
                            onCancel()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button(".button.save") {
                            Task {
                                await onSave()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .disabled(tempToken.isEmpty)
                    }
                } else if hasToken {
                    HStack(spacing: 12) {
                        Button(".button.update") {
                            isEditing = true
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button(".button.delete") {
                            onDelete()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    Button(".button.add") {
                        isEditing = true
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .alert(".title.error", isPresented: $showError) {
                Button(".button.ok", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}
