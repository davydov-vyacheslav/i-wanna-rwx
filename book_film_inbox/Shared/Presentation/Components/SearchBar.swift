//
//  SearchBar.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 26.01.2026.
//

import SwiftUI

struct MediaSearchBar: View {
    @Binding var searchText: String
    @Binding var selectedService: SettingsSourceEntity?
    @Binding var isSearching: Bool
    
    let availableServices: [SettingsSourceEntity]
    let onClear: () -> Void
    
    @FocusState.Binding var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Search field with service selector
            HStack(spacing: 8) {
                searchInputField
                
                if !availableServices.isEmpty {
                    serviceSelector
                }

            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Current service indicator (if multiple services available)
            if availableServices.count > 1, let service = selectedService {
                currentServiceIndicator(serviceName: type(of: service.instance).serviceName)
            }
            
            // No services warning
            if availableServices.isEmpty {
                noServicesWarning
            }
            
            // Character count hint
            if !searchText.isEmpty && searchText.count < 3 {
                characterCountHint
            }
        }
    }
    
    // MARK: - Search Input Field
    private var searchInputField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(".placeholder.common.search", text: $searchText)
                .focused($isSearchFieldFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            // Clear button
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Live search indicator
            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // MARK: - Service Selector Menu
    private var serviceSelector: some View {

        var selectedServiceName: String? = nil
        if let service = selectedService?.instance {
            selectedServiceName = type(of: service).serviceName
        }
        
        return Menu {
            ForEach(availableServices) { service in
                Button {
                    selectedService = service
                } label: {
                    HStack {
                        Text(type(of: service.instance).serviceName)
                        if selectedServiceName == type(of: service.instance).serviceName {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedServiceName ?? "Select")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Current Service Indicator
    private func currentServiceIndicator(serviceName: String) -> some View {
        HStack {
            Text(".label.common_media.search_in")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(serviceName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    // MARK: - No Services Warning
    private var noServicesWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(".label.common_media.search.no_services")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Character Count Hint
    private var characterCountHint: some View {
        HStack {
            Text(".label.common_media.search.min_3_char")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}
