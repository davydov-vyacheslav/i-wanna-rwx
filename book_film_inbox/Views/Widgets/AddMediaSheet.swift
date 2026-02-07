//
//  AddMediaSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 04.02.2026.
//

import SwiftUI


struct AddMediaSheet<Item: ExternalMediaItem, PersistenceService: MediaPersistenceService>: View
where PersistenceService.Item == Item.MediaItem
{
    @Environment(SettingsService.self) var settingsService: SettingsService
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var results: [Item] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedService: SettingsSourceEntity? = nil
    
    @Bindable private var settingsSearchStore = SettingsSourceStore.shared
    
    @FocusState private var isSearchFieldFocused: Bool
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    let title: LocalizedStringKey
    let cantFindMessage: LocalizedStringKey
    let emptyStateIcon: String //books.vertical | film.stack.fill
    let placeholderIcon: String // book.fill | film.fill
    let getItemDetailedTypeIcon: (Item?) -> String // tv | film | book
    let isItemInLibrary: (Item) -> Bool
    let getAuthorInfo: (Item) -> String?
    let getDraftItem: (String) -> Item
    let sourcesKeyPath: KeyPath<SettingsSourceStore, [SettingsSourceEntity]>
    let persistenceService: PersistenceService

    var availableServices: [SettingsSourceEntity] {
        settingsSearchStore[keyPath: sourcesKeyPath].filter { service in
            !type(of: service.instance).requiresToken || settingsService.hasToken(for: type(of: service.instance).serviceName)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar Component
                MediaSearchBar(
                    searchText: $searchText,
                    selectedService: $selectedService,
                    isSearching: $isSearching,
                    availableServices: availableServices,
                    onClear: {
                        results = []
                    },
                    isSearchFieldFocused: $isSearchFieldFocused
                )
                
                Divider()
                
                // Results Area
                resultsView
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(".button.close") { dismiss() }
                }
            }
            .task {
                await initializeView()
            }
            .onChange(of: searchText) { oldValue, newValue in
                handleSearchTextChange(newValue)
            }
            .onChange(of: selectedService) { oldValue, newValue in
                handleServiceChange()
            }
        }
        .sensoryFeedback(.error, trigger: showToast)
        .overlay(alignment: .bottom) {
            if showToast {
                toastView
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showToast)
    }
    
    // MARK: - Results View

    @ViewBuilder
    private var resultsView: some View {
        switch (isSearching, searchText.isEmpty) {
        case (true, _):
            VStack {
                Spacer()
                ProgressView(".placeholder.common.search")
                Spacer()
            }
        case (false, true):
            emptyState
        case (false, false):
            resultsList
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: emptyStateIcon)
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(".label.common.search.enter_text")
                .font(.headline)
                .foregroundColor(.secondary)
            if availableServices.isEmpty {
                Text(".label.common_media.search.no_service_available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Spacer()
        }
    }
    
    private var resultsList: some View {
        List {
            // Search results section
            if !results.isEmpty {
                Section {
                    ForEach(results) { item in
                        MediaSearchItemCard<Item, PersistenceService>(
                            persistenceService: persistenceService,
                            item: item,
                            isInLibrary: isItemInLibrary(item),
                            selectedService: selectedService?.instance as? any SearchService<Item>,
                            placeholderIcon: placeholderIcon,
                            itemDetailedTypeIcon: getItemDetailedTypeIcon(item),
                            authorInfo: getAuthorInfo(item)
                        )
                    }
                } header: {
                    Text(".label.common_media.search_results")
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Manual add section
            if !searchText.isEmpty {
                Section {
                    MediaSearchItemCard<Item, PersistenceService>(
                        persistenceService: persistenceService,
                        item: getDraftItem(searchText),
                        isInLibrary: false,
                        selectedService: nil,
                        placeholderIcon: placeholderIcon,
                        itemDetailedTypeIcon: getItemDetailedTypeIcon(nil),
                        authorInfo: nil
                    )
                } header: {
                    Text(cantFindMessage)
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var toastView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(toastMessage)
                .font(.subheadline)
        }
        .padding()
        .background(.red.gradient)
        .foregroundColor(.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - Event Handlers
    private func handleSearchTextChange(_ newValue: String) {
        searchTask?.cancel()
        
        guard newValue.count >= 3 else {
            results = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTask = Task { 
            if selectedService != nil {
                try? await Task.sleep(for: .seconds(UiConstants.searchDebounceInterval))
            }
            
            if !Task.isCancelled {
                await performSearch(query: newValue)
            }
        }
    }
    
    private func handleServiceChange() {
        if searchText.count >= 3 {
            Task {
                await performSearch(query: searchText)
            }
        }
    }
    
    private func initializeView() async {
        // Select first available service
        if !availableServices.isEmpty, selectedService == nil {
            selectedService = availableServices.first
        }
        
        // Autofocus on screen appear
        try? await Task.sleep(for: .seconds(UiConstants.autoFocusDelay))
        isSearchFieldFocused = true
    }
    
    // MARK: - Search Logic
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            results = []
            isSearching = false
            return
        }
        
        guard let service = selectedService else {
            await MainActor.run {
                results = []
                isSearching = false
            }
            return
        }
        
        do {
            
            let searchResults = try await service.instance.search(
                query: query,
                limit: 10
            )
            
            let itemsResults = searchResults.compactMap { $0 as? Item }
            
            await MainActor.run {
                results = itemsResults
                isSearching = false
            }
        } catch {
            await MainActor.run {
                results = []
                isSearching = false
            }
            if error.localizedDescription != "cancelled" {
                showToastMessage("Search error: \(error.localizedDescription)")
            }
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        Task {
            try? await Task.sleep(for: .seconds(UiConstants.toastDuration))
            showToast = false
        }
    }
}
