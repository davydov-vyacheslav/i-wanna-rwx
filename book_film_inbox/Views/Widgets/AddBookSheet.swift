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
    @State private var results: [BookItem] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    var olService: OpenLibraryService = OpenLibraryService.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Поиск...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
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
                
                if isSearching {
                    ProgressView("Поиск...")
                } else if results.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView("Ничего не найдено",
                                         systemImage: "magnifyingglass")
                } else if results.isEmpty {
                    ContentUnavailableView("Начните вводить название",
                                         systemImage: "magnifyingglass")
                } else {
                    List(results) { item in
                        Button {
                            Task {
                                if !viewModel.isInLibrary(title: item.title) {
                                    await viewModel.addItem(item)
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.largeTitle)
                                    .frame(width: 50)
                                
                                let yearText = item.year != nil ? String(item.year!) : "—"
                                let ratingText = String(format: "%.1f", item.rating)
                                
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.headline)
                                    Text(verbatim: "\(yearText) · ⭐️ \(ratingText)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if viewModel.isInLibrary(title: item.title) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .disabled(viewModel.isInLibrary(title: item.title))
                    }
                }
            }
            .navigationTitle("Добавить книгу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("common.button.close") { dismiss() }
            }
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
                print("Search error: \(error)")
            }
        }
}
