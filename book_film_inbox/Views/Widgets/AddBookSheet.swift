//
//  AddMediaSheet.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct AddBookSheet: View {
    @EnvironmentObject var viewModel: BooksViewModel
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var results: [ExternalBookItem] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    var olService: OpenLibraryService = OpenLibraryService.shared
    @FocusState private var isSearchFieldFocused: Bool
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var hasSearched = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search field with better styling
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField(".placeholder_search", text: $searchText)
                        .focused($isSearchFieldFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    // Clear button
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            results = []
                            hasSearched = false
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
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Character count hint
                if !searchText.isEmpty && searchText.count < 3 {
                    Text(".hint_search_min_3_char")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }
                
                Divider()
                
                // Results
                if isSearching {
                    VStack {
                        Spacer()
                        ProgressView(".placeholder_search")
                        Spacer()
                    }
                } else if !hasSearched && searchText.isEmpty {
                    // Initial state
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "books.vertical")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text(".label_addsheet_enter_text")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    // Results list
                    List {
                        // Search results section
                        if !results.isEmpty {
                            Section {
                                ForEach(results) { item in
                                    BookSearchItemCard(
                                        item: item,
                                        isInLibrary: viewModel.isInLibrary(isbn: item.isbn ?? "NoISBN")
                                    )
                                }
                            } header: {
                                Text(".label_search_results")
                                    .textCase(nil)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Manual add section - always at the bottom
                        Section {
                            BookSearchItemCard(
                                item: ExternalBookItem(
                                    sourceUrl: URL(string: "https://google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!,
                                    status: MediaStatus.PLANNED,
                                    title: searchText,
                                    isbn: nil,
                                    author: nil,
                                    isDraft: true
                                ),
                                isInLibrary: false
                            )
                        } header: {
                            Text(".label_cant_find_book")
                                .textCase(nil)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(".sheetAddBook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(".buttonClose") { dismiss() }
                }
            }
            .onChange(of: searchText) { oldValue, newValue in
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
            .task {
                // Автофокус при показе окна
                try? await Task.sleep(nanoseconds: 100_000_000)
                isSearchFieldFocused = true
            }
        }
        .sensoryFeedback(.error, trigger: showToast)
        .overlay(alignment: .bottom) {
            if showToast {
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
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showToast)
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            results = []
            isSearching = false
            return
        }
        
        do {
            let olResults = try await olService.searchBooksWithDetails(query: query)
            await MainActor.run {
                results = olResults
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
