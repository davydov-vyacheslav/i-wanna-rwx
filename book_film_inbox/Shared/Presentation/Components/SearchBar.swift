//
//  SearchBar.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 26.01.2026.
//

import SwiftUI

struct MediaSearchBar<ExternalItem: ExternalMediaItem>: View {
    @Binding var searchText: String
    @Binding var selectedService: SettingsSourceEntity<ExternalItem>?
    @Binding var isSearching: Bool

    let availableServices: [SettingsSourceEntity<ExternalItem>]
    let onClear: () -> Void

    @FocusState.Binding var isSearchFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                searchInputField

                if availableServices.count > 1, selectedService != nil {
                    servicePicker
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            if let service = selectedService {
                currentServiceIndicator(serviceName: type(of: service.instance).serviceName)
            }

            if availableServices.isEmpty {
                noServicesWarning
            }

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
                .accessibilityHidden(true)

            TextField(".placeholder.common.search", text: $searchText)
                .focused($isSearchFieldFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(".accessibility.search_bar.clear"))
            }

            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
                    .accessibilityLabel(Text(".accessibility.search_bar.searching"))
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Service Picker

    private var servicePicker: some View {
        Picker(".accessibility.search_bar.source_picker", selection: $selectedService) {
            ForEach(availableServices) { service in
                Text(type(of: service.instance).serviceName)
                    .tag(Optional(service))
            }
        }
        .pickerStyle(.menu)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .tint(.blue)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(".accessibility.search_bar.searching_in \(serviceName)"))
    }

    // MARK: - No Services Warning
    private var noServicesWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            Text(".label.common_media.search.no_services")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
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
