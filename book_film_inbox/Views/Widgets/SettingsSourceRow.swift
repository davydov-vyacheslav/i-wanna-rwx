//
//  SettingsSourceRow.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 25.01.2026.
//

import SwiftUI

struct SettingsSourceRow: View {
    let searchService: any SearchService
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        if searchService.requiresToken {
            // Expandable list for sources with tokens
            DisclosureGroup(
                isExpanded: Binding(
                    get: { viewModel.expandedSources.contains(searchService.serviceName) },
                    set: { _ in viewModel.toggleExpanded(for: searchService.serviceName) }
                )
            ) {
                DetailView(searchService: searchService, viewModel: viewModel)
            } label: {
                HeaderView(searchService: searchService, viewModel: viewModel)
            }
        } else {
            // Simple, non-expandable list item
            HStack {
                HeaderView(searchService: searchService, viewModel: viewModel)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Header View
    private struct HeaderView: View {
        let searchService: any SearchService
        @ObservedObject var viewModel: SettingsViewModel
        
        var body: some View {
            HStack {
                
                Text(searchService.serviceName)
                    .font(.body)
                
                Spacer()
                
                if searchService.requiresToken {
                    if viewModel.hasToken(for: searchService.serviceName) {
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
        @ObservedObject var viewModel: SettingsViewModel
        
        var isEditing: Bool {
            viewModel.editingSource == searchService.serviceName
        }
        
        var hasToken: Bool {
            viewModel.hasToken(for: searchService.serviceName)
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
                            Text(viewModel.getDisplayToken(for: searchService.serviceName))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Button {
                                viewModel.toggleShowToken(for: searchService.serviceName)
                            } label: {
                                Image(systemName: viewModel.showToken.contains(searchService.serviceName) ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.borderless)
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

                        SecureField(".placeholder.settings.source.enter_token", text: $viewModel.tempToken)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                
                // Help Link
                if let helpURL = searchService.helpURL, let url = URL(string: helpURL) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Text(".label.settings.source.token_howto")
                                .font(.subheadline)
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                        }
                    }
                }
                
                // Action Buttons
                if isEditing {
                    HStack(spacing: 12) {
                        Button(".button.cancel") {
                            viewModel.cancelEditing()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button(".button.save") {
                            viewModel.saveEditing(for: searchService.serviceName)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .disabled(viewModel.tempToken.isEmpty)
                    }
                } else if hasToken {
                    HStack(spacing: 12) {
                        Button(".button.update") {
                            viewModel.startEditing(for: searchService.serviceName)
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button(".button.delete") {
                            viewModel.removeToken(for: searchService.serviceName)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    Button(".button.add") {
                        viewModel.startEditing(for: searchService.serviceName)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
        }
    }
}
