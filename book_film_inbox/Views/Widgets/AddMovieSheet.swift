//
//  AddMovieSheet.swift
//  IWannaRWX
//
//  Created by Slava Davydov on 27.01.2026.
//

import SwiftUI


struct AddMovieSheet: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var results: [ExternalMovieItem] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedService: SettingsSourceEntity? = nil
    
    @StateObject private var settingsSearchStore = SettingsSourceStore.shared
    
    @FocusState private var isSearchFieldFocused: Bool
    
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var availableServices: [SettingsSourceEntity] {
        settingsSearchStore.availableVideoSources.filter { service in
            !type(of: service.instance).requiresToken || settingsViewModel.hasToken(for: type(of: service.instance).serviceName)
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
            .navigationTitle(".title.movie.add")
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
        } else if searchText.isEmpty {
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
            Image(systemName: "film.stack.fill")
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
                        MovieSearchItemCard(
                            item: item,
                            isInLibrary: viewModel.isInLibrary(sourceId: item.sourceId, sourceName: item.sourceName),
                            selectedService: selectedService?.instance as? any SearchService<ExternalMovieItem>
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
                    MovieSearchItemCard(
                        item: DraftMovieService.shared.single(query: searchText),
                        isInLibrary: false,
                        selectedService: nil
                    )
                } header: {
                    Text(".label.movie.cant_find")
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
                try? await Task.sleep(nanoseconds: 500_000_000)
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
            }
            return
        }
        
        do {
            
            let searchResults = try await service.instance.search(
                query: query,
                limit: 10
            )
            
            let moviesResults = searchResults.compactMap { $0 as? ExternalMovieItem }
            
            await MainActor.run {
                results = moviesResults
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
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            showToast = false
        }
    }
}
