//
//  BooksView.swift
//  book_film_inbox
//
//  Created by Slava Davydov on 23.11.2025.
//

import SwiftUI

struct BooksView: View {
    @EnvironmentObject var viewModel: BooksViewModel
    @State private var selectedFilter: FilterType = .ALL
    @State private var showingAddSheet = false
    
    var filteredItems: [BookItem] {
        viewModel.filteredItems(filter: selectedFilter)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            FilterButton(
                                filterType: filter,
                                count: viewModel.count(filter: filter),
                                isSelected: selectedFilter == filter,
                                isFavorite: filter == .FAVOURITES
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(uiColor: .systemBackground))
                
                // List
                if filteredItems.isEmpty {
                    Spacer()
                    Text("common.label.list.empty")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                BookItemCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("title.books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddBookSheet()
            }
        }
    }
}


