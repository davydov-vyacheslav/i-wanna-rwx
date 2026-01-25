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
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(".placeholder_search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                    .focused($isSearchFieldFocused)
                    .onChange(of: searchText) { oldValue, newValue in
                            searchTask?.cancel()
                            
                            guard newValue.count >= 3 else {
                                results = []
                                return
                            }
                            
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                                
                                if !Task.isCancelled {
                                    await performSearch(query: newValue)
                                }
                            }
                        }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isSearchFieldFocused = true
                        }
                    }
                
                if isSearching {
                    ProgressView(".placeholder_search")
                } else if results.isEmpty && !searchText.isEmpty {
                    List {
                        BookSearchItemCard(
                            item: ExternalBookItem(
                                sourceUrl: URL(string: "https://google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!,
                                status: MediaStatus.PLANNED,
                                title: searchText,
                                isDraft: true
                            ),
                            isInLibrary: false
                        )
                    }

//                    ContentUnavailableView(".label_addsheet_notfound",
//                                         systemImage: "magnifyingglass")
                } else if results.isEmpty {
                    ContentUnavailableView(".label_addsheet_enter_text",
                                         systemImage: "magnifyingglass")
                } else {
                    List {
                        ForEach(results) { item in
                            BookSearchItemCard(
                                item: item,
                                isInLibrary: viewModel.isInLibrary(title: item.title))
                        }
                        
                        BookSearchItemCard(
                            item: ExternalBookItem(
                                sourceUrl: URL(string: "https://google.com/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!,
                                status: MediaStatus.PLANNED,
                                title: searchText,
                                isDraft: true
                            ),
                            isInLibrary: false
                        )
                    }
                }
            }
            .navigationTitle(".sheetAddBook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(".buttonClose") { dismiss() }
            }
        }
        .sensoryFeedback(.error, trigger: showToast) // Haptic feedback on error
        .overlay(alignment: .bottom) {
            if showToast {
                Text(toastMessage)
                    .font(.subheadline)
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
        .onAppear {
            isSearchFieldFocused = true
        }
    }
    
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        
        do {
            let olResults = try await olService.searchBooksWithDetails(query: query)
            await MainActor.run {
                results = olResults
                isSearching = false
            }
        } catch {
            await MainActor.run {
                results = []
                isSearching = false
            }
            showToastMessage("Search error: \(error)")
            print("Search error: \(error)")
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            showToast = false
        }
    }
}

