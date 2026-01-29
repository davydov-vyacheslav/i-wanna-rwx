//
//  AddMediaSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI


struct AddBookSheet: View {
    @EnvironmentObject var viewModel: BooksViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var results: [ExternalBookItem] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var hasSearched = false
    @State private var selectedService: SettingsSourceEntity? = nil
    
    @StateObject private var settingsSearchStore = SettingsSourceStore.shared
    
    @FocusState private var isSearchFieldFocused: Bool
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var availableServices: [SettingsSourceEntity] {
        settingsSearchStore.availableBookSources.filter { service in
            !service.instance.requiresToken || settingsViewModel.hasToken(for: service.instance.serviceName)
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
                        hasSearched = false
                    },
                    isSearchFieldFocused: $isSearchFieldFocused
                )
                
                Divider()
                
                // Results Area
                resultsView
            }
            .navigationTitle(".title.book.add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(".button.close") { dismiss() }
                }
            }
            .onChange(of: searchText) { oldValue, newValue in
                handleSearchTextChange(newValue)
            }
            .onChange(of: selectedService) { oldValue, newValue in
                handleServiceChange()
            }
            .task {
                await initializeView()
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
        if isSearching {
            searchingState
        } else if !hasSearched && searchText.isEmpty {
            emptyState
        } else {
            resultsList
        }
    }
    
    private var searchingState: some View {
        VStack {
            Spacer()
            ProgressView(".placeholder.common.search")
            Spacer()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "books.vertical")
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
                        BookSearchItemCard(
                            item: item,
                            isInLibrary: viewModel.isInLibrary(isbn: item.isbn ?? "NoISBN"),
                            selectedService: selectedService?.instance as? any SearchService<ExternalBookItem>
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
            Section {
                BookSearchItemCard(
                    item: ExternalBookItem.draft(searchText: searchText),
                    isInLibrary: false,
                    selectedService: nil
                )
            } header: {
                Text(".label.book.cant_find")
                    .textCase(nil)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
            try? await Task.sleep(nanoseconds: 500_000_000)
            
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
        try? await Task.sleep(nanoseconds: 100_000_000)
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
                hasSearched = true
            }
            showToastMessage("Service not available")
            return
        }
        
        do {
            let token = service.instance.requiresToken
            ? settingsViewModel.getToken(for: service.instance.serviceName)
                : nil
            
            let searchResults = try await service.instance.search(
                query: query,
                token: token,
                limit: 10
            )
            
            let bookResults = searchResults.compactMap { $0 as? ExternalBookItem }
            
            await MainActor.run {
                results = bookResults
                isSearching = false
                hasSearched = true
            }
        } catch {
            await MainActor.run {
                results = []
                isSearching = false
                hasSearched = true
            }
            showToastMessage("Search error: \(error.localizedDescription)")
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showToast = false
        }
    }
}
